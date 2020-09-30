

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
		i_speed : unsigned(15 downto 0);
		i_control_box_setup : in type_control_box_setup;
		i_hal_data : in std_logic_vector(2 downto 0);
		i_settings_control_box : type_settings_control_box;
		o_motor_transistors : out type_motor_transistors
				);
		end component control_box;
	 
		constant clk_period : time := 1 us;

	 	signal clk : std_logic;
	 	signal res : std_logic;
		constant hal_period : time := 1 ms;

		signal temp_transistors : unsigned(9 downto 0);
		signal req_temperature : unsigned(7 downto 0);
		signal req_speed : unsigned(7 downto 0) := x"7f";
		signal control_box_setup : type_control_box_setup;
		signal motor_transistors : type_motor_transistors;
		signal hal_data : std_logic_vector(2 downto 0):="100";
		signal speed : unsigned(15 downto 0);



		constant Kp_pid_1 : signed(15 downto 0) := x"ffe1";
		constant Ki_pid_1 : signed(15 downto 0) := x"001f";
		constant Kd_pid_1 : signed(15 downto 0) := x"000f";

		constant Kp_pid_2 : signed(15 downto 0) := x"ffe1";
		constant Ki_pid_2 : signed(15 downto 0) := x"001f";
		constant Kd_pid_2 : signed(15 downto 0) := x"000f";
		
		constant Kp_pd : signed(15 downto 0) := x"009d";
		constant Kd_pd : signed(15 downto 0) := x"0027";
		
		constant offset_speed_wave_1 : unsigned(15 downto 0) := x"0000";-- 
		constant offset_speed_wave_2 : unsigned(15 downto 0) := x"0000";

		constant max_speed_1 : unsigned(15 downto 0) := x"0600";--512 /256 hal clicks 2 round per sec
		constant max_speed_2 : unsigned(15 downto 0) := x"0600";--512 /256 hal clicks 2 round per sec

		constant wave_limit : unsigned(15 downto 0) := x"0ff0";--255 , 100% wave equvalent
		constant max_temperature : unsigned(15 downto 0) := x"4000";-- Celsius
		constant offset_tmp_wave : unsigned(15 downto 0) := x"0000";--
		constant wave_user_limit : unsigned(15 downto 0) := x"0C00";-- 50% wave user  cap
		
		constant alfa_speed : unsigned(15 downto 0):= x"0035";
		constant alfa_pedal_assist : unsigned(15 downto 0):= x"00a5";


		signal settings_pid : type_settings_pid := (
		Kp => Kp_pid_1,
		Ki => Ki_pid_1,
		Kd => Kd_pid_1 );

		signal settings_pd : type_settings_pd := (
			Kp => Kp_pd,
			Kd => Kd_pd		
		);
		signal settings_control_box : type_settings_control_box := (
		settings_pid => settings_pid,
		settings_pd => settings_pd,
		max_speed =>max_speed_1,
		max_temperature =>max_temperature,
--				
		offset_speed =>offset_speed_wave_1,
		offset_term =>offset_tmp_wave,
user_limit => wave_user_limit
		);




begin
		
			module_control_box: control_box
			port map (
						res => res,	
						clk => clk,	
						
						i_temp_transistors => temp_transistors,
						i_req_speed => req_speed,
						i_speed => speed,
						i_control_box_setup => control_box_setup,
						i_hal_data => hal_data,
						i_settings_control_box => settings_control_box,
						o_motor_transistors => motor_transistors 
					);
			
		process	
		begin
				res <= '1';
				control_box_setup.enable <= '1';
				control_box_setup.hal <= '1';
				speed <=(others => '0');
				temp_transistors <= "0001111111";
				req_temperature <= x"50";
				wait;
	


				
		end process;


		hal_process:
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
		end  process;

		clk_process:
		process
		begin
			clk  <=  '0';
			wait  for clk_period/2;
			clk  <=  '1';
			wait  for clk_period/2;
		end  process;


end t_behaviour;