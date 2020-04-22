use work.functions.all;
use work.interface_data.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity flash_controller is
	generic ( 
		freq : integer;
		bound : integer
		);
		
	port(
			res : in std_logic;		
			clk : in std_logic;	
			
			io_data : inout std_logic_vector(23 downto 0);
			i_address : in std_logic_vector(7 downto 0);
			i_transaction : in transaction_type;
			i_enable : in std_logic;
			i_spi : in type_to_spi;
			
			
			o_received : out std_logic;
			o_spi : out type_from_spi;
			o_busy	: out std_logic
		);
end flash_controller;

architecture behaviour of flash_controller is


	component spi is
		generic ( 
			freq : integer;
			bound : integer
			);
			
		port(
				res : in std_logic;		
				clk : in std_logic;	
				
				io_data : inout std_logic_vector(7 downto 0);
				i_spi : in type_to_spi;
				i_transaction : transaction_type;
				i_enable : in std_logic;
				
				o_spi : out type_from_spi;
				o_received : out std_logic;
				o_busy	: out std_logic
			);
	end component spi;

	signal  received_internal : std_logic := '0';
	signal  busy_internal : std_logic := '0';
	
	signal data_spi : std_logic_vector(7 downto 0);
	signal busy_spi : std_logic;
	signal en_spi : std_logic;
	signal received_spi : std_logic;
	signal transaction_spi : transaction_type;
	
begin	

		spi_function : spi
			generic map ( 
		 	freq => freq,
			bound => bound )
				
			port map(
					res => res,		
					clk => clk,
					
					io_data => data_spi,
					i_spi => i_spi,
					i_transaction =>transaction_spi,
					i_enable => en_spi,
					
					o_spi => o_spi,
					o_received =>received_spi,
					o_busy	=> busy_spi
				);


process(clk)
							
		constant enter_write_cycle : unsigned(7 downto 0) := unsigned(revert_byte(x"06"));
		constant read_command : unsigned(7 downto 0) := unsigned(revert_byte(x"03"));
		constant write_command : unsigned(7 downto 0) := unsigned(revert_byte(x"02"));
		
		variable  separate : integer range 30 downto 0 := 0;
		
		type type_flash_operation is (no_flash_operation, flash_write, flash_read);
		type type_write_flash is (write_idle , write_enable, write_code, write_address, write_data, write_conclude);
		type type_read_flash is (read_idle , read_code, read_address, read_data, read_conclude);		
		
		variable flash_operation : type_flash_operation := no_flash_operation;
		variable write_flash : type_write_flash := write_idle;
		variable read_flash : type_read_flash := read_idle;
		
		
		variable cnt : integer  range 3 downto 0 := 0;
begin
		

	if rising_edge(clk)  then
			
		if res = '0' then
			
				busy_internal <= '0';
				received_internal <= '0';
				flash_operation := no_flash_operation;
		 		write_flash := write_idle;
				read_flash := read_idle;
				data_spi <= (others => 'Z');
				io_data <= (others => 'Z');
		else		
		
				if  received_internal = '1' then
					received_internal <= '0';
				end if;
				
				
				if i_enable = '1' or  busy_internal = '1' then	
				
					if  busy_internal = '0' then
						busy_internal <= '1';
						flash_operation := no_flash_operation;
					else
						
						if flash_operation = no_flash_operation then
							if  i_transaction = Read then
								flash_operation := flash_read;
							elsif i_transaction = Write then
								io_data <= (others => 'Z');
								flash_operation := flash_write;
							end if;
						
						elsif flash_operation =  flash_write then
							if  write_flash = write_idle then
								if busy_spi = '0' then
									en_spi <= '1';
									data_spi <= std_logic_vector(enter_write_cycle);
									transaction_spi <= Write;
								elsif busy_spi = '1' then
									en_spi <= '0';	
									write_flash := write_enable;
									separate := 30;
								end if;
							elsif write_flash = write_enable then
								if busy_spi = '0' then
									if separate = 0 then
										write_flash := write_code;
									else
										separate := separate - 1;
									end if;
									
								end if;					
					
							elsif write_flash = write_code then
								if busy_spi = '0' then
									en_spi <= '1';
									data_spi <= std_logic_vector(write_command);
									cnt := 2;
								elsif busy_spi = '1' then
									write_flash := write_address;
								end if;
							elsif write_flash = write_address then
								if busy_spi = '0' then
									if cnt = 0 then
										data_spi <= i_address;
										write_flash := write_data;
										cnt := 2;
									else
										data_spi <= x"00";
										cnt := cnt - 1;
									end if;
									
									
									
								end if;
							
							elsif write_flash = write_data then							
								if busy_spi = '0' then
									data_spi <= io_data(8*(3-cnt)-1 downto 8*(2-cnt));
									if cnt = 2 then
										write_flash := write_conclude;
										en_spi <= '0';
									else
										cnt := cnt - 1;
									end if;
									
								end if;
							elsif write_flash = write_conclude then	
								if busy_spi = '0' then
									flash_operation := no_flash_operation;
									write_flash := write_idle;
									
									data_spi <= (others => 'Z');
									busy_internal <= '0';
								end if;
							end if;
						
						
						elsif flash_operation = flash_read then
							if  read_flash = read_idle then
								if busy_spi = '0' then
									transaction_spi <= Write;
									en_spi <= '1';
									
								elsif busy_spi = '1' then
									read_flash := read_code;
								end if;	
							elsif read_flash = read_code then
								
								data_spi <= std_logic_vector(read_command);
								cnt := 2;
								
								read_flash := read_address;
								
							elsif read_flash = read_address then
								if busy_spi = '0' then
									if cnt = 0 then
										data_spi <= i_address;
										read_flash := read_data;
										cnt := 2;
										
										
									else
										cnt := cnt - 1;
										data_spi <= x"00";
									
									end if;
									
								end if;
							elsif read_flash = read_data then
								if busy_spi = '0' then
									transaction_spi <= Read;
									data_spi <= (others => 'Z');
								end if;						
								if received_spi = '1' then
									io_data(8*(3-cnt)-1 downto 8*(2-cnt))<= data_spi;
									if cnt = 0 then
										read_flash := read_conclude;
									else
										if cnt = 1 then
											en_spi <= '0';
										end if;
									
										cnt := cnt - 1;
									end if;

								end if;
								
							elsif read_flash = read_conclude then
								flash_operation := no_flash_operation;
								read_flash := read_idle;
								
								busy_internal <= '0';
								received_internal <= '1';
							end if;
						end if;						
						

					end if;
				
				
				end if;
		end if;
				
	end if;
	

end  process;

process(busy_internal,received_internal)
begin
	o_busy <= busy_internal;
	o_received <= received_internal;
end process;



end behaviour;
