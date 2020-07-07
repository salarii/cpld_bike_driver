

library IEEE;
use IEEE.std_logic_1164.all;

use work.interface_data.all;
use ieee.numeric_std.all;

use work.interface_data.all;
use ieee.numeric_std.all;


entity speed_estimator_tb is
end speed_estimator_tb;

architecture t_behaviour of speed_estimator_tb is

		component speed_estimator is
			generic ( 
				CONSTANT main_clock : integer;
				CONSTANT work_period : integer
				);
			port(
					res : in std_logic;		
					clk : in std_logic;	
					i_manu_speed : in unsigned(11 downto 0);
					
					i_throttle_meas : in unsigned(9 downto 0);
					i_impulse : in std_logic;
					
					o_speed : out unsigned(7 downto 0)
				);
		end component speed_estimator;

		signal res :  std_logic;		
		signal clk :  std_logic;	
		signal manu_speed : unsigned(11 downto 0);
					
		signal throttle_meas :  unsigned(9 downto 0);
		signal impulse :  std_logic;
					
		signal speed :  unsigned(7 downto 0);
		
		constant clk_period : time := 1 us;
	begin	
		
		speed_func: speed_estimator
		generic map( 
				main_clock =>1000000,
				work_period =>2
					)
		port map (
				res => res,
				clk => clk,
				
				i_manu_speed => manu_speed,
				i_throttle_meas => throttle_meas,
				i_impulse => impulse,
					
				o_speed => speed
				);
		process	
		begin
			res <= '1';
			throttle_meas <= "0000000111";
			manu_speed <= (others => '0');
			impulse <= '1';
			wait for 100 ms;
			impulse <= '0';				
			wait for 100 ms;
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