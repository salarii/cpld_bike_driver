

library IEEE;
use IEEE.std_logic_1164.all;

use work.interface_data.all;
use ieee.numeric_std.all;
use work.motor_auxiliary.all;

entity adc_tb is
end adc_tb;

architecture t_behaviour of adc_tb is

		
		component adc is
			generic (
				adc_mesur_per_sec	: integer;	
				freq : integer;
				spi_bound : integer);
		
			port(
				clk : in  std_logic;
				res : in  std_logic;
				
				i_channel : in unsigned( 2 downto 0 );
				
				i_spi : in type_to_spi;
				o_measurement : out unsigned( 9 downto 0 );
				o_spi : out type_from_spi
		
				);
		end component adc;
	

		signal res : std_logic;	
		signal clk : std_logic;		
	

		signal channel : unsigned( 2 downto 0 );				
		signal measurement : unsigned( 9 downto 0 );

		signal to_spi : type_to_spi;
		signal from_spi : type_from_spi;
		
		signal miso : std_logic;

		signal sck : std_logic;
		signal ss : std_logic;	
		signal mosi : std_logic;
		
	begin	
		
		module_adc : adc
		generic map (
				adc_mesur_per_sec => 50,
				freq => 1000000,
				spi_bound => 10000 )
			
		port map (
			res => res,		
			clk => clk,
				
			i_channel => channel,
			i_spi => to_spi,
			o_measurement => measurement,
			o_spi => from_spi
		);

	process
		begin
					
		
			--res <= '0';	
			--wait for 10 us;				
			--res <= '1';
			miso <= '1';
	
	
			wait;
	end process;
	
	
	clk_process :
	process
		constant clk_period : time := 1 us;
	begin
		clk  <=  '0';
		wait  for clk_period/2;
		clk  <=  '1';
		wait  for clk_period/2;
	end  process;
	
	to_spi.miso <= miso;
	sck <= from_spi.sck;
	ss <= from_spi.ss;	
	mosi <= from_spi.mosi;
			
end t_behaviour;