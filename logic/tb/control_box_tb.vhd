

library IEEE;
use IEEE.std_logic_1164.all;

use work.interface_data.all;
use ieee.numeric_std.all;
use work.motor_auxiliary.all;

entity control_box_tb is
end control_box_tb;

architecture t_behaviour of control_box_tb is

		
		component control_box is
		port(
				clk : in  std_logic;
				res : in  std_logic;
				
				i_temp_transistors : in unsigned(9 downto 0);
				i_req_speed : in unsigned(7 downto 0);
				i_req_temperature : in unsigned(7 downto 0);
				i_control_box_setup : in type_control_box_setup;
				i_hal_data : in std_logic_vector(2 downto 0);
				o_motor_transistors : out type_motor_transistors
				);
		end component control_box;
	 
		constant clk_period : time := 1 us;

	 	signal clk : std_logic;
	 	signal res : std_logic;
	 
		constant hal_period : time := 20 ms;

		signal temp_transistors : unsigned(9 downto 0);
		signal req_temperature : unsigned(7 downto 0);
		signal req_speed : unsigned(7 downto 0) := x"7f";
		signal control_box_setup : type_control_box_setup;
		signal motor_transistors : type_motor_transistors;
		signal hal_data : std_logic_vector(2 downto 0);
		
begin
		
			module_control_box: control_box
			port map (
						res => res,	
						clk => clk,	
						
						i_temp_transistors => temp_transistors,
						i_req_speed => req_speed,
						i_req_temperature => req_temperature,
						i_control_box_setup => control_box_setup,
						i_hal_data => hal_data,
						o_motor_transistors => motor_transistors 
					);
			
		process	
		begin
				
	

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
		clk_process:
		process
		begin
			clk  <=  '0';
			wait  for clk_period/2;
			clk  <=  '1';
			wait  for clk_period/2;
		end  process;


end t_behaviour;