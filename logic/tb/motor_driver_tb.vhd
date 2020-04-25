library IEEE;
use IEEE.std_logic_1164.all;
use work.interface_data.all;
use ieee.numeric_std.all;
use work.motor_auxiliary.all;

entity motor_driver_tb is
end motor_driver_tb;

architecture t_behaviour of motor_driver_tb is

		signal res :  std_logic;
		signal clk :  std_logic := '0';
		
		constant size : integer := 12;
		

		component motor_driver is
			port(
				res : in std_logic;		
				clk : in std_logic;		
				i_req_speed : in unsigned(7 downto 0);
				i_work_wave : in std_logic;
				i_motor_control_setup : in type_motor_control_setup;
		
				o_motor_transistors : out type_motor_transistors
				);
		end component;

		signal motor_control_setup : type_motor_control_setup;
		
		signal req_speed : unsigned(7 downto 0);
		signal work_wave : std_logic;
		
		signal motor_transistors : type_motor_transistors;
		
		signal debug_a_p : std_logic; 
		signal debug_a_n : std_logic; 
		signal debug_b_p : std_logic; 
		signal debug_b_n : std_logic;
		signal debug_c_p : std_logic; 
		signal debug_c_n : std_logic;
				
	begin	
		clk <= not clk after 1 ns;

		module_motor: motor_driver

		port map (
		res => res,
		clk => clk,
		i_req_speed => req_speed,
		i_work_wave => work_wave,
		i_motor_control_setup => motor_control_setup,
		
		o_motor_transistors => motor_transistors
		);

		process
		
			begin
				
 
				motor_control_setup.hal <= '0';		
				motor_control_setup.enable <= '1';
				
				work_wave <= '1';
				req_speed <= x"aa";
				res <= '0';
				wait for 1 ns;
				res <= '1';
											
				wait for 50000 ns;	

					

		end process;
		--
		
		debug_a_p <= motor_transistors.A_p; 
		debug_a_n <= motor_transistors.A_n;
		debug_b_p <= motor_transistors.B_p;
		debug_b_n <= motor_transistors.B_n;
		debug_c_p <= motor_transistors.C_p;
		debug_c_n <= motor_transistors.C_n;
--
end t_behaviour;