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
				
				i_data : in std_logic_vector(7 downto 0);
				i_spi : in type_to_spi;
				i_enable : in std_logic;
				
				o_data : out std_logic_vector(7 downto 0);
				o_spi : out type_from_spi;
				o_received : out std_logic;
				o_busy	: out std_logic
			);
	end component spi;

	signal  received_internal : std_logic := '0';
	signal  busy_internal : std_logic := '0';
	
	signal i_data_spi : std_logic_vector(7 downto 0):= (others => 'Z');
	signal o_data_spi : std_logic_vector(7 downto 0);
	signal busy_spi : std_logic;
	signal en_spi : std_logic;
	signal received_spi : std_logic;
	
begin	

		spi_function : spi
			generic map ( 
		 	freq => freq,
			bound => bound )
				
			port map(
					res => res,		
					clk => clk,
					
					i_data => i_data_spi,
					i_spi => i_spi,
					i_enable => en_spi,
					
					o_data => o_data_spi,
					o_spi => o_spi,
					o_received =>received_spi,
					o_busy	=> busy_spi
				);


process(clk)
							
		constant enter_write_cycle : unsigned(7 downto 0) := x"06";
		constant read_command : unsigned(7 downto 0) := x"03";
		constant write_command : unsigned(7 downto 0) := x"02";
		constant sector_erase_command : unsigned(7 downto 0) := x"20";
		constant status_command : unsigned(7 downto 0) := x"05";
		
				
		variable  separate : integer range 30 downto 0 := 0;
		
		type type_flash_operation is (no_flash_operation, flash_write, flash_read, flash_erase, status_read);
		type type_write_flash is (write_idle , write_enable, write_code, write_address, write_data, write_conclude);
		type type_read_flash is (read_idle , read_code, read_address, read_data, read_conclude);		
		type type_erase_flash is (erase_idle , erase_enable, erase_code, erase_address, erase_conclude);		
		type type_read_status is (status_idle , status_code, status_word, status_conclude);		
				
		type type_write_control is (wr_control_idle , wr_control_erase, wr_control_status_erase,wr_control_write, wr_control_status_write);		
		type type_read_erase_control is (rd_er_idle , rd_er_progress, rd_er_done);		
		type type_erase_control is (erase_control_idle , erase_control_progress, erase_control_status);	
				
		variable read_status : type_read_status := status_idle;
	
		variable flash_operation : type_flash_operation := no_flash_operation;
		variable write_flash : type_write_flash := write_idle;
		variable read_flash : type_read_flash := read_idle;
		variable erase_flash : type_erase_flash := erase_idle;
		variable write_control : type_write_control := wr_control_idle;
		variable read_erase_control : type_read_erase_control := rd_er_idle;
		variable erase_control : type_erase_control;
		variable cnt : integer  range 3 downto 0 := 0;
		
		variable busy_bit : std_logic;
begin
		

	if rising_edge(clk)  then
			
		if res = '0' then
			
				busy_internal <= '0';
				received_internal <= '0';
				flash_operation := no_flash_operation;
		 		write_flash := write_idle;
				read_flash := read_idle;
				read_status := status_idle;
				write_control := wr_control_idle;
				read_erase_control := rd_er_idle;
		
				io_data <= (others => 'Z');
				en_spi <= '0';
		else		
		
				if  received_internal = '1' then
					received_internal <= '0';
				end if;
				
				if i_enable = '1' or  busy_internal = '1' then	
				
					if  busy_internal = '0' then
						busy_internal <= '1';
						flash_operation := no_flash_operation;

					else
						
						if  i_transaction = Read then
										if read_erase_control = rd_er_idle then
											flash_operation := flash_read;
											
										elsif read_erase_control = rd_er_progress then
										elsif read_erase_control = rd_er_done then
											busy_internal <= '0';
											read_erase_control := rd_er_idle;
											flash_operation := no_flash_operation;
											read_flash := read_idle;
										end if;
								
						elsif i_transaction = Write then
							
								io_data <= (others => 'Z');
								
								if write_control = wr_control_idle then
									flash_operation := flash_erase;
									write_control := wr_control_erase;
								elsif write_control = wr_control_erase then
										if erase_flash = erase_conclude then
											erase_flash := erase_idle;
											flash_operation := status_read;
											write_control := wr_control_status_erase;
										end if;
								elsif write_control = wr_control_status_erase then
										if read_status = status_conclude then
								
											read_status := status_idle;
											if busy_bit = '1' then
												flash_operation := status_read;
												
											else
												flash_operation := flash_write;
												write_control := wr_control_write;
												
											end if;
										end if;
								elsif write_control = wr_control_write then
									if write_flash = write_conclude then
										write_flash := write_idle;
										write_control := wr_control_status_write;
										flash_operation := status_read;
									end if;
								elsif write_control = wr_control_status_write then
										if read_status = status_conclude then
								
											read_status := status_idle;
											if busy_bit = '1' then
												flash_operation := status_read;
											else
												write_control := wr_control_idle;
												flash_operation := no_flash_operation;
												write_flash := write_idle;
												busy_internal <= '0';
											end if;
										end if;
								end if;
								
							
						elsif i_transaction = Erase then
								io_data <= (others => 'Z');
								
								if erase_control = erase_control_idle then
										flash_operation := flash_erase;	
										erase_control := erase_control_progress;
								elsif erase_control = erase_control_progress then
									if erase_flash = erase_conclude then
										flash_operation := status_read;
										erase_control := erase_control_status;
									end if;
								elsif erase_control = erase_control_status then
										if read_status = status_conclude then
								
											read_status := status_idle;
											if busy_bit = '1' then
												flash_operation := status_read;
											else
												busy_internal <= '0';
												erase_control := erase_control_idle;
												flash_operation := no_flash_operation;
												erase_flash := erase_idle;
											end if;
										end if;
								end if;
						end if;
						
						if flash_operation =  flash_erase then
								
							if  erase_flash = erase_idle then
								if busy_spi = '0' then
									en_spi <= '1';
									i_data_spi <= std_logic_vector(enter_write_cycle);
									
								elsif busy_spi = '1' and en_spi <= '1' then
									en_spi <= '0';	
									erase_flash := erase_enable;
									separate := 30;
								end if;
							elsif erase_flash = erase_enable then
								if busy_spi = '0' then
									if separate = 0 then
										erase_flash := erase_code;
									else
										separate := separate - 1;
									end if;
									
								end if;
					
							elsif erase_flash = erase_code then
								if busy_spi = '0' then
									en_spi <= '1';
									i_data_spi <= std_logic_vector(sector_erase_command);
									cnt := 2;
								elsif busy_spi = '1' then
									erase_flash := erase_address;
								end if;
							elsif erase_flash = erase_address then
								if busy_spi = '0' then

									if cnt = 0 then
										erase_flash := erase_conclude;
										i_data_spi <= x"00";
										en_spi <= '0';
									elsif cnt = 1 then
										cnt := 0;
										i_data_spi <= i_address;
									elsif cnt = 2 then
										cnt := 1;
										i_data_spi <= x"00";
									end if;
								end if;
							
							end if;
						elsif flash_operation =  status_read then

						
							if  read_status = status_idle then
								if busy_spi = '0' then
									
									en_spi <= '1';
									
								elsif busy_spi = '1' and en_spi = '1' then
									read_status := status_code;
								end if;	
							elsif read_status = status_code then
								
								i_data_spi <= std_logic_vector(status_command);
						
								if busy_spi = '0' then
									
									en_spi <= '0';
									read_status := status_word;
								end if;
							elsif read_status = status_word then
										
								if received_spi = '1' then
									
									busy_bit := o_data_spi(0);
									read_status := status_conclude;
									
								end if;
								
							end if;
						
						
						elsif flash_operation =  flash_write then
							if  write_flash = write_idle then
								if busy_spi = '0' then
									en_spi <= '1';
									i_data_spi <= std_logic_vector(enter_write_cycle);
									
								elsif busy_spi = '1' and en_spi = '1' then
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
									i_data_spi <= std_logic_vector(write_command);
									cnt := 2;
								elsif busy_spi = '1' and en_spi = '1' then
									write_flash := write_address;
								end if;
							elsif write_flash = write_address then
								if busy_spi = '0' then

									if cnt = 0 then
										write_flash := write_data;
										cnt := 2;
										i_data_spi <= x"00";
									elsif cnt = 1 then
										cnt := 0;
										i_data_spi <= i_address;
									elsif cnt = 2 then
										cnt := 1;
										i_data_spi <= x"00";
									end if;
									
								end if;
							
							elsif write_flash = write_data then
								if busy_spi = '0' then
									i_data_spi <= io_data(8*(3-cnt)-1 downto 8*(2-cnt));
									if cnt = 0 then
										write_flash := write_conclude;
										en_spi <= '0';
									else
										cnt := cnt - 1;
									end if;
									
								end if;
							end if;
						
						
						elsif flash_operation = flash_read then
							if  read_flash = read_idle then
								if busy_spi = '0' then
									
									en_spi <= '1';
									
								elsif busy_spi = '1' and en_spi <= '1' then
									read_flash := read_code;
								end if;	
							elsif read_flash = read_code then
								
								i_data_spi <= std_logic_vector(read_command);
								cnt := 3;
								
								read_flash := read_address;
								
							elsif read_flash = read_address then
								if busy_spi = '0' then
									if cnt = 0 then
										read_flash := read_data;
										cnt := 2;
									elsif cnt = 2 then
                    cnt := cnt - 1;
										i_data_spi <= i_address;
									else
										cnt := cnt - 1;
										i_data_spi <= x"00";
									
									end if;
									
								end if;
							elsif read_flash = read_data then
												
								if received_spi = '1' then

									io_data(8*(3-cnt)-1 downto 8*(2-cnt))<= o_data_spi;

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
								
								read_erase_control := rd_er_done;
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
