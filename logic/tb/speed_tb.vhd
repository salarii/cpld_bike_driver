

library IEEE;
use IEEE.std_logic_1164.all;

use work.interface_data.all;
use ieee.numeric_std.all;

entity speed_tb is
end speed_tb;

architecture t_behaviour of speed_tb is

		
		component speed_impulse is
			generic ( 
				CONSTANT main_clock : integer;
				CONSTANT work_period : integer;
				CONSTANT out_period : integer
				);
				
			port(
					res : in std_logic;		
					clk : in std_logic;	
					
					i_impulse : in std_logic;
					o_speed : out unsigned(15 downto 0)
				);
				
		end component speed_impulse;
	 
		constant clk_period : time := 1 us;

	 	signal clk : std_logic;
	 	signal res : std_logic;
	 	signal impulse : std_logic;
	 	
	 	signal speed : unsigned(15 downto 0);
	 

	begin	
		
		module_speed: speed_impulse
		generic map (
			main_clock => 1000,
			work_period => 100,
			out_period => 10 )
		
		port map (
					res => res,	
					clk => clk,	
					
					i_impulse => impulse,
					o_speed => speed 
				);

		process
			begin
				
	
				--res <= '0';	
				--wait for 10 us;				
				res <= '1';

				impulse <= '0';
			
				wait for 4 us;
				
				impulse <= '1';		
				
				wait for 8 us;


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


end t_behaviour;