

library IEEE;
use IEEE.std_logic_1164.all;

use ieee.numeric_std.all;
use work.interface_data.all;
use work.all;
use work.motor_auxiliary.all;

entity bikeDriver is

	port(
		clk : in std_logic;
		res : in std_logic;
		i_hal_data : in std_logic_vector(2 downto 0);
		
		i_spi : in type_to_spi;
		o_spi : out type_from_spi;
		
		i_pedal_imp : in std_logic;

		i_brk_1 : in std_logic;
		i_brk_2 : in std_logic;
		
		i_control_mode : in std_logic;
		
		i_adc_spi : in type_to_spi;
		o_adc_spi : out type_from_spi;
		
		leds : out std_logic_vector(3 downto 0);
		
		o_motor_transistors : out type_motor_transistors;
		
		rx : in std_logic;		
		tx	: out  std_logic
		);
end bikeDriver;



architecture behaviour of bikeDriver is
	component my_clock IS
		PORT
		(
			inclk0		: IN STD_LOGIC ;
			c0		: OUT STD_LOGIC 
		);
	END component my_clock;
 	
 
		component control_unit is
			port(
			clk : in  std_logic;
			res : in  std_logic;
			
			
			i_flash_spi : in type_to_spi;
			i_hal_data : in std_logic_vector(2 downto 0);
				
			i_pedal_imp : in std_logic;
			i_brk_1 : in std_logic;
			i_brk_2 : in std_logic;
		
			i_control_mode : in std_logic;
		
			i_busy_uart : in std_logic;
			i_from_uart : in std_logic_vector(7 downto 0);
			i_received_uart : in std_logic;
			
			i_adc_spi : in type_to_spi;
				
				
			o_flash_spi : out type_from_spi;
				
			o_adc_spi : out type_from_spi;
			
			o_to_uart : out std_logic_vector(7 downto 0);
			o_en_uart : out std_logic;
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
	end  component uart;
	
 
		signal internal_clk		: STD_LOGIC;
		signal bus_data :  std_logic;

		
		signal data : std_logic_vector(15 downto 0);
		signal address : std_logic_vector(6 downto 0);
		signal reg_addr : std_logic_vector(1 downto 0);
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
		signal err_uart : std_logic;	
begin	

pll_module: my_clock 
		port map (
				inclk0	=> clk,
				c0		=> internal_clk
		);
								
		control_func: control_unit
		port map (
				res => res,
				clk => internal_clk,
				
				i_pedal_imp => i_pedal_imp,
				i_brk_1 => i_brk_1,
				i_brk_2 => i_brk_2,
				
				i_control_mode => i_control_mode,
				
				i_hal_data => i_hal_data,
				i_flash_spi => i_spi,
				o_flash_spi => o_spi,

						
		
				i_adc_spi =>i_adc_spi,
				o_adc_spi =>o_adc_spi,
				
				leds => leds,
				o_motor_transistors => o_motor_transistors,
				
				i_received_uart => received_uart,
				i_from_uart => from_uart,
				i_busy_uart => busy_uart,
				o_to_uart => to_uart,
				o_en_uart => en_uart
				);

		to_display : uart
    generic map (
          freq => 1000000,
          bound => 9600 ) 
			
		port map (
			res => res,		
			clk => internal_clk,
			i_data => to_uart,
			i_enable => en_uart,		
			i_rx => rx,	
			o_data => from_uart,
			o_error => err_uart,
			o_received => received_uart,
			o_busy => busy_uart,
			o_tx => tx
			);


end behaviour;
