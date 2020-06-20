

library IEEE;
use IEEE.std_logic_1164.all;

use work.interface_data.all;
use ieee.numeric_std.all;
use work.motor_auxiliary.all;

entity uart_flash_tb is
end uart_flash_tb;

architecture t_behaviour of uart_flash_tb is

		
		component control_unit is
			port(
				clk : in  std_logic;
				res : in  std_logic;
				
				i_impulse : in std_logic;
				
				i_spi : in type_to_spi;
				o_spi : out type_from_spi;
					
							
				i_busy_uart : in std_logic;
				i_from_uart : in std_logic_vector(7 downto 0);
				i_received_uart : in std_logic;
				o_to_uart : out std_logic_vector(7 downto 0);
				o_en_uart : out std_logic;
				o_wave : out std_logic;
				o_motor_transistors : out type_motor_transistors;
				leds : out std_logic_vector(3 downto 0)
			);
		end component control_unit;
	
	
		component uart is
			generic ( 
				freq : integer;
				bound : integer
				);
			
		port(
			res : in std_logic;		
			clk : in std_logic;	
			
			i_data : in std_logic_vector(7 downto 0);
			i_enable : in std_logic;
			i_rx : in std_logic;	
			
			o_data : out std_logic_vector(7 downto 0);	
			o_error : out std_logic;
			o_received : out std_logic;
			o_busy	: out std_logic;
			o_tx	: out  std_logic
			);
		end component uart;
	 

	 
	 
	 	signal leds : std_logic_vector(3 downto 0);
	 
		signal res : std_logic;	
		signal clk : std_logic;		
		signal bus_clk	: std_logic;
		signal bus_data :  std_logic;
		signal o_slave_data :  std_logic;
		signal o_data_en :  std_logic;
		signal i_slave_data :  std_logic;

		signal ready	: std_logic;
		
		
		constant clk_period : time := 100 ns;
		
		signal data : std_logic_vector(15 downto 0);
		signal address : std_logic_vector(6 downto 0);
		
		signal enable : std_logic;		
		signal busy	: std_logic;
		signal done	: std_logic;
		signal error : std_logic;
		signal continue : std_logic;
					
			
		signal motor_transistors : type_motor_transistors;
				
			
		signal to_uart : std_logic_vector(7 downto 0);
		signal from_uart : std_logic_vector(7 downto 0);
		signal received_uart : std_logic; 
		signal busy_uart : std_logic;
		signal en_uart : std_logic;
		signal tx_uart : std_logic;
		signal rx_uart : std_logic;
		signal err_uart : std_logic;		

		signal to_spi : type_to_spi;
		signal from_spi : type_from_spi;
		signal wave : std_logic;
	begin	
		

		control_func: control_unit
		port map (
				res => res,
				clk => clk,
				
				i_spi => to_spi,
				o_spi => from_spi,

				i_impulse => '0',

				leds => leds,
				o_wave => wave,
		
				i_received_uart => received_uart,
				i_from_uart => from_uart,
				i_busy_uart => busy_uart,
				o_to_uart => to_uart,
				o_en_uart => en_uart,
				o_motor_transistors => motor_transistors
				);

 
		to_display : uart
		generic map (
		 	freq => 100,
			bound => 10 )
			
		port map (
			res => res,		
			clk => clk,
			i_data => to_uart,
			i_enable => en_uart,		
			i_rx => rx_uart,	
			o_data => from_uart,
			o_error => err_uart,
			o_received => received_uart,
			o_busy => busy_uart,
			o_tx => tx_uart
			);

		process
			begin
				
	
				res <= '0';	
				wait for 10 us;				
				res <= '1';


				
				-- 0x02  0 1100 0000 0
				
				to_spi.miso <= '0';
				
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 2 us;
				rx_uart <= '0';
				wait for 7 us;
				rx_uart <= '1';
				wait for 5 us;
				
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 2 us;
				rx_uart <= '0';
				wait for 7 us;
				rx_uart <= '1';
				wait for 4 us;

				wait for 32 us;
				to_spi.miso <= '1';				
				wait for 120 us;
			-- 0x02  0 0100 0000 1
				-- 0x00  0 1100 0000 0
				-- 0xaa  0 0101 0101 0
				-- 0xff  0 1111 1111 0
				-- 0xaa  0 0101 0101 0


				wait for 10 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 6 us;
				rx_uart <= '1';
				wait for 3 us;

				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 2 us;
				rx_uart <= '0';
				wait for 7 us;
				rx_uart <= '1';
				wait for 4 us;


				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 5 us;
				
								
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 8 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 3 us;
				
				
				
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				
				
				wait for 265 us;
				res <= '0';
				wait for 195 us;				
				res <= '1';
				wait for 1 ms;

				wait;
			end process;
		--
clk_process :
process
begin
	clk  <=  '0';
	wait  for clk_period/2;
	clk  <=  '1';
	wait  for clk_period/2;
end  process;

			
			
	i_slave_data <= bus_data;
	bus_data <=  o_slave_data when o_data_en = '1' else  'Z'; 

			
end t_behaviour;