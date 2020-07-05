

library IEEE;
use IEEE.std_logic_1164.all;

use work.interface_data.all;
use ieee.numeric_std.all;

use work.interface_data.all;
use ieee.numeric_std.all;
use work.motor_auxiliary.all;


entity speed_tb is
end speed_tb;

architecture t_behaviour of speed_tb is

		
		component control_unit is
			port(
				clk : in  std_logic;
				res : in  std_logic;
				
				i_hal_data : in std_logic_vector(2 downto 0);
				
				i_flash_spi : in type_to_spi;
				
					
							
				i_busy_uart : in std_logic;
				i_from_uart : in std_logic_vector(7 downto 0);
				i_received_uart : in std_logic;
				
				i_adc_spi : in type_to_spi;
					
					
				o_flash_spi : out type_from_spi;
					
				o_adc_spi : out type_from_spi;
				
				o_to_uart : out std_logic_vector(7 downto 0);
				o_en_uart : out std_logic;
				o_wave : out std_logic;
				o_motor_transistors : out type_motor_transistors;
				leds : out std_logic_vector(3 downto 0)
			);
		end component control_unit;
	 
 
	 
	 	signal leds : std_logic_vector(3 downto 0);
	 
		
		signal res : std_logic;	
		signal clk : std_logic;		
		signal bus_clk	: std_logic;
		signal bus_data :  std_logic;
		signal o_slave_data :  std_logic;
		signal o_data_en :  std_logic;
		signal i_slave_data :  std_logic;

		signal ready	: std_logic;
		
		signal motor_transistors : type_motor_transistors;
		signal impulse : std_logic;
		constant clk_period : time := 1 us;
		constant hal_period : time := 50 us;
		
		signal data : std_logic_vector(15 downto 0);
		signal address : std_logic_vector(6 downto 0);
		signal hal_data : std_logic_vector(2 downto 0):= "100";
		
		signal enable : std_logic;		
		signal busy	: std_logic;
		signal done	: std_logic;
		signal error : std_logic;
		signal continue : std_logic;
					
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
		signal to_adc_spi : type_to_spi;
		signal from_adc_spi : type_from_spi;
		signal wave : std_logic;
		
		
	begin	
		
		control_func: control_unit
		port map (
				res => res,
				clk => clk,
				
				i_flash_spi => to_spi,
				o_flash_spi => from_spi,
				
				i_adc_spi => to_adc_spi,
				o_adc_spi => from_adc_spi,

				i_hal_data => hal_data,

				leds => leds,
				o_wave => wave,
		
				i_received_uart => received_uart,
				i_from_uart => from_uart,
				i_busy_uart => busy_uart,
				o_to_uart => to_uart,
				o_en_uart => en_uart,
				o_motor_transistors => motor_transistors
				);
		process	
		begin
				res <= '1';
	

				case hal_data is
						when "101" =>  
							hal_data<="100";
						when "100"  =>  
							hal_data<="110";
						when "110"  =>  
							hal_data<="010";
						when "010"  =>  
							hal_data<="011";
						when "011"  =>  
							hal_data<="001";
						when "001"  =>  
							hal_data<="101";
						when others => 
							hal_data<="100";
						end case;

			
			wait for hal_period;
				
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


end t_behaviour;