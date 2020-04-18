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
			i_miso : in std_logic;
			i_transaction : in transaction_type;
			i_enable : in std_logic;
			i_stall : in std_logic;
			
			o_sck : out std_logic;
			o_ss : out std_logic;	
			o_mosi : out std_logic;
			o_received : out std_logic;
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
				i_miso : in std_logic;
				i_write : in std_logic;
				i_enable : in std_logic;
				i_stall : in std_logic;
				
				o_sck : out std_logic;
				o_ss : out std_logic;	
				o_mosi : out std_logic;
				o_received : out std_logic;
				o_busy	: out std_logic
			);
	end component spi;

	signal  received_internal : std_logic := '0';
	signal  busy_internal : std_logic := '0';
	
	
	signal bit_cnt_debug  : unsigned(3 downto 0);	
	signal cycle_cnt_debug  : unsigned(4 downto 0);
	signal shift_reg_debug  : unsigned(7 downto 0);
begin	


process(clk)
		constant enter_write_cycle : unsigned(7 downto 0) := x"01";
		constant read_command : unsigned(7 downto 0) := x"02";
		constant write_command : unsigned(7 downto 0) := x"03";
		
		type type_flash_operation is (no_flash_operation, flash_write, flash_read);
		type type_write_flash is (idle , enable_write,address, write_data);
		type type_read_flash is (idle ,address, read_data);		
		
		variable flash_operation : type_flash_operation;
		variable write_flash : type_write_flash;
		variable read_flash : type_read_flash;
		
		variable shift_reg: unsigned(7 downto 0);-- := (others => '0');
		

begin
		

	if rising_edge(clk)  then
			
		if res = '0' then
			
				busy_internal <= '0';
				received_internal <= '0';
				flash_operation := no_flash_operation;
		 		write_flash := idle;
				read_flash := idle;
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
								flash_operation := flash_write;
							end if;
						
						elsif flash_operation =  flash_write then
							if  write_flash = idle then
					
							elsif write_flash = enable_write then
							elsif write_flash = address then
							elsif write_flash = write_data then							
							end if;
						
						
						elsif flash_operation = flash_read then
							if  read_flash = idle then
					
							elsif read_flash = address then
							
							elsif read_flash = read_data then						
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
