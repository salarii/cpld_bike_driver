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

		
		component motor_driver is
			port(
				res : in std_logic;		
				clk : in std_logic;		
				i_req_speed : in std_logic_vector(7 downto 0);
				i_work_wave : in std_logic_vector(7 downto 0);
				i_motor_sensors_setup : type_motor_control_setup;
				i_enable  : in std_logic;
		
				o_motor_transistors : out type_motor_transistors
				);
		end component;

		signal motor_control_setup : type_motor_control_setup;
		
		signal req_speed : std_logic_vector(7 downto 0);
		signal work_wave : std_logic_vector(7 downto 0);
		signal enable  : std_logic;
		
		signal motor_transistors : type_motor_transistors;
	begin	
		clk <= not clk after 1 ns;


		module_motor: motor_driver

		port map (
		res => res,
		clk => clk,
		i_req_speed => req_speed,
		i_work_wave => work_wave,
		i_motor_sensors_setup => motor_control_setup,
		i_enable => enable,
		
		o_motor_transistors => motor_transistors
		);

		process
		
			begin
				
				--
				
				res <= '0';
		
				wait for 1 ns;
				res <= '1';
				
				wait for 100 ns;	

					

			end process;
		--
	--
--
end t_behaviour;