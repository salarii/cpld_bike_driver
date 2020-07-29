

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.interface_data.all;
use work.functions.all;
use work.motor_auxiliary.all;



entity control_unit is
	generic (CONSTANT period : integer := 1000000);

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
end control_unit;

architecture behaviour of control_unit is



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
					i_alfa : in  unsigned(7 downto 0);
					o_speed : out unsigned(7 downto 0)
				);
				
		end component speed_estimator;


		component flash_controller is
			generic ( 
				freq : integer;
				bound : integer
				);
				
			port(
					res : in std_logic;		
					clk : in std_logic;	
					
					io_data : inout std_logic_vector(23 downto 0);
					i_address : in std_logic_vector(7 downto 0);
					i_transaction : in transaction_type;
					i_enable : in std_logic;
					i_spi : in type_to_spi;
					
					o_received : out std_logic;
					o_spi : out type_from_spi;
					o_busy	: out std_logic
				);
				
		end component flash_controller;


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


		component speed_impulse is
			generic ( 
				CONSTANT main_clock : integer;
				CONSTANT work_period : integer;
				CONSTANT shift_impulses : integer := 0
				);
				
			port(
					res : in std_logic;		
					clk : in std_logic;	
					
					i_impulse : in std_logic;
					i_alfa : in  unsigned(7 downto 0);
					
					o_speed : out unsigned(15 downto 0)
				);
		end component speed_impulse;

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
				o_spi : out type_from_spi;
				o_temp  : out unsigned( 9 downto 0 );
				o_throttle  : out unsigned( 9 downto 0 )
				);
		end component adc;
	
		signal enable_uart  : std_logic;

		signal data_flash : std_logic_vector(23 downto 0);
		signal page_address_flash : std_logic_vector(7 downto 0);
		signal busy_flash : std_logic;
		signal en_flash : std_logic;
		signal received_flash : std_logic;	
		signal transaction_flash : transaction_type;
		
		signal throttle : unsigned(9 downto 0);
		signal speed : unsigned(15 downto 0);
		signal adc_channel : unsigned(2 downto 0);
		signal adc_measurement : unsigned(15 downto 0) := (others => '0');
		signal adc_temp : unsigned(9 downto 0);

		signal  hal_err : std_logic := '0';
		

		signal req_speed : unsigned(7 downto 0);
		signal control_box_setup : type_control_box_setup :=
			(  hal => '1',
				enable => '0',	
				temperature => '1',
				manual => '0',	
				pulse_trigger => (others => '0'),		
				req_speed_motor => (others => '0'));
	
	
		signal motor_transistors : type_motor_transistors;
		signal speed_impulse_sig : std_logic := '0';	
		
		signal manu_speed : unsigned(7 downto 0);
		signal host_enable : std_logic := '0';

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

		constant max_speed_1 : unsigned(15 downto 0) := x"0200";--512 /256 hal clicks 2 round per sec
		constant max_speed_2 : unsigned(15 downto 0) := x"0200";--512 /256 hal clicks 2 round per sec

		constant wave_limit : unsigned(15 downto 0) := x"0ff0";--255 , 100% wave equvalent
		constant max_temperature : unsigned(15 downto 0) := x"0200";-- Celsius
		constant offset_tmp_wave : unsigned(15 downto 0) := x"0000";--
		constant wave_user_limit : unsigned(15 downto 0) := x"0C00";-- 50% wave user  cap
		
		constant alfa_speed : unsigned(15 downto 0):= x"0035";
		constant alfa_pedal_assist : unsigned(15 downto 0):= x"00a5";
				
		signal profile_1_pid : type_settings_pid;
		signal profile_2_pid : type_settings_pid;
		signal	max_speed1 : unsigned(15 downto 0);
	    signal	max_speed2 : unsigned(15 downto 0);
		
	    signal	offset_speed1 : unsigned(15 downto 0);
	    signal	offset_speed2 : unsigned(15 downto 0);  
	
	    signal	alpha_pedal_assist : unsigned(15 downto 0);
	    signal	alpha_speed : unsigned(15 downto 0);
		
		
		
		signal settings_control_box : type_settings_control_box;
--		 :=
--			(  
--				settings_pid => (Kp =>Kp_pid, Ki =>Ki_pid, Kd =>Kd_pid),
--				settings_pd => (Kp =>Kp_pd, Kd =>Kd_pd),
--				max_speed =>max_speed,
--				max_temperature =>max_temperature,
--				
--				offset_speed =>offset_speed_wave,
--				offset_term =>offset_tmp_wave,
--				user_limit => wave_user_limit
--				);
begin	
	
	module_control_box: control_box
	port map (
				res => res,	
				clk => clk,	
						
				i_temp_transistors => adc_temp,
				i_req_speed => req_speed,
				i_speed => speed,
				i_control_box_setup => control_box_setup,
				i_hal_data => i_hal_data,
				i_settings_control_box => settings_control_box,
				o_motor_transistors => motor_transistors 
		);


		speed_estimator_module : speed_estimator 
			generic map( 
					 main_clock =>1000000,
					 work_period =>2
					)
			port map(
					res => res, 	
					clk => clk,	
		
					i_manu_speed(11 downto  8) =>(others =>'0'),
					i_manu_speed(7 downto  0) =>manu_speed,			
					i_throttle_meas => throttle,
					i_impulse => i_pedal_imp,
					i_alfa => alpha_speed(7 downto 0),
					o_speed => req_speed
				);

		speed_impulse_module : speed_impulse 
		generic map ( 
			 main_clock =>1000000,
			 work_period =>2
			)
					
			port map(
					res => res, 	
					clk => clk,	
					
					i_impulse => speed_impulse_sig,
					i_alfa => alpha_pedal_assist(7 downto 0),
					o_speed => speed
					);

		flash_module : flash_controller
			generic map ( 
		 	freq => 1000000,
			bound => 100000 )
				
			port map(
					res => res,		
					clk => clk,
					 
					io_data => data_flash,
					i_address => page_address_flash,
					i_transaction => transaction_flash,
					i_enable => en_flash,
					i_spi => i_flash_spi,
					
					o_received => received_flash,
					o_spi => o_flash_spi,
					
					o_busy => busy_flash
				);
	
		
		adc_module :  adc
			generic map(
				adc_mesur_per_sec => 10,	
				freq => 1000000,
				spi_bound => 12000 )
		
			port map(
					res => res,		
					clk => clk,
				
					i_channel => adc_channel,
				
					i_spi => i_adc_spi,
					o_measurement => adc_measurement(9 downto 0),
					o_spi => o_adc_spi,
					o_temp => adc_temp,
					o_throttle => throttle
				);
		
	process(clk)
		variable uart_sized : boolean := False; 
	
		type state_type is (state_read_settings, state_operate);
		
		type type_i2c_operations is ( i2c_index, i2c_data_H, i2c_data_L );
		
		type type_user_commands is (no_command, disable_comm, adc_channel_change, flash_write, flash_read, flash_erase, run_motor );
		
		type type_init_trigger_phase is ( unit_step_freq_h,unit_step_freq_l, unit_step_pulse_h,unit_step_pulse_l);
		
		type type_flash_write_state is ( get_setting_write_id,get_flash_write_byte2, get_flash_write_byte1, get_flash_write_byte0, execute_flash_write,reload_settings_write );
		type type_flash_read_state is ( get_flash_read_addr, execute_flash_read,progress_flash_read, read_flash_done, send_flash_data );
		type type_flash_erase_state is ( get_flash_erase_addr, execute_flash_erase,reload_settings_erase );
		type type_run_motor_state is ( run_motor_get_speed, run_motor_get_pulse_width, run_motor_max_temp,run_motor_hal,run_motor_manual,execute_run_motor );
			
				
		constant stop_command : unsigned(7 downto 0) := x"00";
		constant measure_command : unsigned(7 downto 0) := x"01";
		constant flash_write_command : unsigned(7 downto 0) := x"02";				
		constant flash_read_command : unsigned(7 downto 0) := x"03";
		constant flash_erase_command : unsigned(7 downto 0) := x"04";
		constant run_motor_command : unsigned(7 downto 0) := x"05";		
				
		constant adc_data_code : unsigned(7 downto 0) := x"00";
		constant flash_data_code : unsigned(7 downto 0) := x"01";
		constant motor_data_code : unsigned(7 downto 0) := x"02";
		
		constant config_register_h : unsigned(7 downto 0) := "01000100";
		constant config_register_l : unsigned(7 downto 0) := "01100011";
		constant short_break : integer := 50;
		variable cnt : integer := 0;			
		variable val_cnt : integer  range 15 downto 0 := 0;
		variable state : state_type := state_read_settings;
		variable enable_pc_write : std_logic;
		
		variable flash_erase_state : type_flash_erase_state;
		variable flash_read_state : type_flash_read_state := execute_flash_read;
		variable flash_write_state : type_flash_write_state; 
		variable tmp_sol : type_user_commands := no_command;
		variable user_command : type_user_commands := tmp_sol;--disable_comm;
		variable trigger_phase : type_init_trigger_phase;
		variable run_motor_state : type_run_motor_state;
		variable uart_dev_status : type_uart_dev_status  := (False,False,False,uart_no_device);
		
		variable	hal_work : unsigned(4 downto 0);
		
		constant glob_clk_denom : integer := 1000;
		constant send_motor_data_wait : integer := 500;
		constant send_adc_data_wait : integer := 500;
		variable glob_clk_counter : integer := 0;
		variable glob_small_clk_counter : integer range glob_clk_denom downto 0  := 0;
	
		variable last_motor_action : integer := 0;
		variable last_adc_data_send : integer := 0;
				
		variable time_tmp : unsigned(31 downto 0);
		
		variable prev_hal : std_logic_vector(2 downto 0):= (others=> '0');
		variable hal_imp_cnt : unsigned(23 downto 0):= (others=> '0');
		
		variable setting_val : unsigned(23 downto 0);
		variable setting_id : unsigned(7 downto 0) := x"00";
		variable update_setting_flag : std_logic;	
		
  
	begin

		if rising_edge(clk)  then
			if res = '0' then
				state := state_read_settings;
				setting_id:= x"00";
				cnt :=0;
				val_cnt := 0;
				enable_pc_write := '0';
				enable_uart <= '0';
				host_enable <= '1';
				

				user_command := tmp_sol;	
				uart_dev_status := (False,False,False,uart_no_device);
				glob_clk_counter := 0;
				glob_small_clk_counter := 0;
				last_motor_action := 0;
				last_adc_data_send := 0;
				hal_imp_cnt := (others=>'0');
				control_box_setup.hal <= '1';
				flash_read_state := execute_flash_read;
				hal_err <= '0'; 
			else
				
				
				if  update_setting_flag = '1'  then
					if setting_val(15 downto 0) /= x"ffff" then
					
						case setting_id is
							when x"00" =>  profile_1_pid.Kp <= signed(setting_val(15 downto 0));
							when x"01" =>  profile_2_pid.Kp <= signed(setting_val(15 downto 0));							
							when x"02" =>  profile_1_pid.Ki <= signed(setting_val(15 downto 0));
							when x"03" =>  profile_2_pid.Ki <= signed(setting_val(15 downto 0));							
							when x"04" =>  profile_1_pid.Kd <= signed(setting_val(15 downto 0));
							when x"05" =>  profile_2_pid.Kd <= signed(setting_val(15 downto 0));
							when x"06" =>  max_speed1 <= unsigned(setting_val(15 downto 0));
							when x"07" =>  max_speed2 <= unsigned(setting_val(15 downto 0));
							when x"08" =>  offset_speed1 <= unsigned(setting_val(15 downto 0));	
							when x"09" =>  offset_speed2 <= unsigned(setting_val(15 downto 0));
							when x"0a" =>  settings_control_box.settings_pd.Kp <= signed(setting_val(15 downto 0));
							when x"0b" =>  settings_control_box.settings_pd.Kd <= signed(setting_val(15 downto 0)); 
							when x"0c" =>  settings_control_box.max_temperature <= unsigned(setting_val(15 downto 0));
							when x"0d" =>  settings_control_box.offset_term <= unsigned(setting_val(15 downto 0));
							when x"0e" =>  settings_control_box.user_limit <= unsigned(setting_val(15 downto 0));
							when x"0f" =>  alpha_pedal_assist <= unsigned(setting_val(15 downto 0));
							when x"10" =>  alpha_speed <= unsigned(setting_val(15 downto 0));
							when others => update_setting_flag :=  '0';
						end case;
					else
					
						case setting_id is
							when x"00" =>  profile_1_pid.Kp <= Kp_pid_1;
							when x"01" =>  profile_2_pid.Kp <= Kp_pid_2;							
							when x"02" =>  profile_1_pid.Ki <= Ki_pid_1;
							when x"03" =>  profile_2_pid.Ki <= Ki_pid_2;							
							when x"04" =>  profile_1_pid.Kd <= Kd_pid_1;
							when x"05" =>  profile_2_pid.Kd <= Kd_pid_2;
							when x"06" =>  max_speed1 <= max_speed_1;
							when x"07" =>  max_speed2 <= max_speed_2;
							when x"08" =>  offset_speed1 <= offset_speed_wave_1;	
							when x"09" =>  offset_speed2 <= offset_speed_wave_2;
							when x"0a" =>  settings_control_box.settings_pd.Kp <= Kp_pd;
							when x"0b" =>  settings_control_box.settings_pd.Kd <= Kd_pd; 
							when x"0c" =>  settings_control_box.max_temperature <= max_temperature;
							when x"0d" =>  settings_control_box.offset_term <= offset_tmp_wave;
							when x"0e" =>  settings_control_box.user_limit <= wave_user_limit;
							when x"0f" =>  alpha_pedal_assist <= alfa_pedal_assist;
							when x"10" =>  alpha_speed <= alfa_speed;
							when others => update_setting_flag :=  '0';
						end case;
					end if;
					update_setting_flag := '0'; 
				end if;
				
				 
				if state = state_read_settings then
				
					--leds(0) <= '0';
					if flash_read_state = execute_flash_read  then
						if busy_flash = '0' then
							en_flash <= '1';
							transaction_flash <= Read;
							data_flash <= (others => 'Z');
							page_address_flash <= std_logic_vector(shift_left(unsigned(setting_id), 4));
							               
                			en_flash <= '1';
						elsif busy_flash = '1' then
							
								en_flash <= '0';
								flash_read_state := progress_flash_read;
						 
						end if;		
					elsif flash_read_state = progress_flash_read then
							if received_flash = '1' then
							     
								flash_read_state := send_flash_data;
								setting_val(15 downto 0) := unsigned(data_flash(15 downto 0));
								update_setting_flag := '1';
							end if;
						elsif flash_read_state = send_flash_data then
							if setting_id <= x"10" then
								flash_read_state := execute_flash_read;
								setting_id := setting_id + 1;
							else
                
								state := state_operate; 
							end if;	

						end if;
				
					
				elsif state = state_operate then
					--leds(0) <= '1';
					if prev_hal /= i_hal_data then
						hal_imp_cnt := hal_imp_cnt + 1;
						prev_hal := i_hal_data;
						speed_impulse_sig <= '1';
					else
						speed_impulse_sig <= '0';
					end if;
				
					if glob_small_clk_counter = glob_clk_denom  then
						glob_small_clk_counter := 0;
						glob_clk_counter := glob_clk_counter + 1; 
					else  
						glob_small_clk_counter := glob_small_clk_counter + 1; 				
					end if;
	
						
					if glob_clk_counter - last_motor_action > send_motor_data_wait then
						
						uart_dev_status.motor := True;
						last_motor_action := glob_clk_counter;
					elsif glob_clk_counter - last_adc_data_send > send_adc_data_wait then
						uart_dev_status.adc_data := True;
						last_adc_data_send := glob_clk_counter;
					end if;
								
					
					
					if user_command = flash_write then
						
						if flash_write_state = execute_flash_write then
              
							if busy_flash = '1' then
								en_flash <= '0';
								flash_write_state := reload_settings_write;

							else
				                en_flash <= '1';
				                transaction_flash <= Write;
				                
				                setting_val := unsigned(data_flash);
							end if;
						elsif flash_write_state = reload_settings_write then	
							if busy_flash = '0' then
								user_command := no_command;
								state := state_read_settings;
								setting_id:= x"00";
								flash_read_state := execute_flash_read;
							end if;
						end if;
					elsif user_command = flash_erase then	
						if flash_erase_state = execute_flash_erase  then
							if busy_flash = '0' then
								en_flash <= '1';
								transaction_flash <= Erase;
								
							elsif busy_flash = '1' then
							
								en_flash <= '0';
								flash_erase_state := reload_settings_erase; 
							end if;		
							
						elsif flash_erase_state = reload_settings_erase then	
							if busy_flash = '0' then
									user_command := no_command;
									state := state_read_settings;
									setting_id:= x"00";
									flash_read_state := execute_flash_read;
							end if;
						end if;	
					elsif user_command = flash_read then								
	
						if flash_read_state = execute_flash_read  then
							if busy_flash = '0' then
								en_flash <= '1';
								transaction_flash <= Read;
								data_flash <= (others => 'Z');
								
							elsif busy_flash = '1' then
							
								en_flash <= '0';
								flash_read_state := progress_flash_read;
						
							end if;		
						elsif flash_read_state = progress_flash_read then
							if received_flash = '1' then
							
								flash_read_state := send_flash_data;
								
							end if;
						elsif flash_read_state = send_flash_data then
						
								uart_dev_status.flash := True;
											
						end if;
						
					elsif user_command = run_motor then	
						if run_motor_state = execute_run_motor then
							last_motor_action := glob_clk_counter;
							
							host_enable <= '1';
							control_box_setup.temperature <= '1';
							
							user_command := no_command; 
						end if;
						
					end if;
		
	
		
					if 	i_received_uart = '1' and user_command /= disable_comm then
						
						if user_command = no_command then 
								
							if i_from_uart = std_logic_vector(measure_command) then
									
									user_command := adc_channel_change;
							elsif i_from_uart = std_logic_vector(flash_write_command) then
									user_command := flash_write; 
									flash_write_state := get_setting_write_id;
							elsif i_from_uart = std_logic_vector(flash_read_command) then
									user_command := flash_read;
									flash_read_state := get_flash_read_addr;
							
							elsif i_from_uart = std_logic_vector(run_motor_command) then
									user_command := run_motor;
									
									run_motor_state := run_motor_get_speed;
							elsif i_from_uart = std_logic_vector(flash_erase_command) then
									user_command := flash_erase;
									flash_erase_state := get_flash_erase_addr;
							
							elsif i_from_uart = std_logic_vector(stop_command)  then 
								
								host_enable <= '0';
								last_motor_action := glob_clk_counter;
							end if;
						else	
								
	
							if user_command = adc_channel_change then
						
								adc_channel <= unsigned(i_from_uart(2 downto 0));
								user_command := no_command;
							elsif user_command = run_motor then
							
								
								if run_motor_state = run_motor_get_speed then
	   								control_box_setup.req_speed_motor <= unsigned(i_from_uart);
									manu_speed <= unsigned(i_from_uart);
									run_motor_state := run_motor_get_pulse_width;	
								elsif run_motor_state = run_motor_get_pulse_width then
	
	
									control_box_setup.pulse_trigger(7 downto 0) <= unsigned(i_from_uart);
									run_motor_state := run_motor_max_temp;
								elsif run_motor_state = run_motor_max_temp then
									settings_control_box.max_temperature(15 downto 8) <= unsigned(i_from_uart);
									run_motor_state := run_motor_hal;
								elsif run_motor_state = run_motor_hal then
									if i_from_uart = x"00" then
										control_box_setup.hal <= '0';
									else
										control_box_setup.hal <= '1';
									end if;
									run_motor_state := run_motor_manual;
								elsif run_motor_state = run_motor_manual then
									if i_from_uart = x"00" then
										control_box_setup.manual <= '0';
									else
										control_box_setup.manual <= '1';
									end if;
									
									run_motor_state := execute_run_motor;	
								end if;								
							elsif user_command = flash_erase then
								
								if flash_erase_state = get_flash_erase_addr then								
									page_address_flash <= std_logic_vector(shift_left(unsigned(i_from_uart), 4));
									flash_erase_state := execute_flash_erase;
								end if;		
							elsif user_command = flash_write then
								
								if flash_write_state = get_setting_write_id then
									page_address_flash <= std_logic_vector(shift_left(unsigned(i_from_uart), 4));
									setting_id := unsigned(i_from_uart);
									flash_write_state := get_flash_write_byte2;
								elsif flash_write_state = get_flash_write_byte2 then
									data_flash(23 downto 16) <= i_from_uart;
									flash_write_state := get_flash_write_byte1;
								elsif flash_write_state = get_flash_write_byte1 then
									data_flash(15 downto 8) <= i_from_uart;
									flash_write_state := get_flash_write_byte0;
								elsif flash_write_state = get_flash_write_byte0 then
									data_flash(7 downto 0) <= i_from_uart;
									flash_write_state := execute_flash_write;
								end if;
							
							elsif user_command = flash_read then
							
									setting_id := unsigned(i_from_uart);
									
									case setting_id is
										when x"00" =>  setting_val(15 downto 0) := unsigned(profile_1_pid.Kp);
										when x"01" =>  setting_val(15 downto 0) := unsigned(profile_2_pid.Kp);							
										when x"02" =>  setting_val(15 downto 0) := unsigned(profile_1_pid.Ki);
										when x"03" =>  setting_val(15 downto 0) := unsigned(profile_2_pid.Ki);							
										when x"04" =>  setting_val(15 downto 0) := unsigned(profile_1_pid.Kd);
										when x"05" =>  setting_val(15 downto 0) := unsigned(profile_2_pid.Kd);
										when x"06" =>  setting_val(15 downto 0) := unsigned(max_speed1);
										when x"07" =>  setting_val(15 downto 0) := unsigned(max_speed2);
										when x"08" =>  setting_val(15 downto 0) := unsigned(offset_speed1);	
										when x"09" =>  setting_val(15 downto 0) := unsigned(offset_speed2);
										when x"0a" =>  setting_val(15 downto 0) := unsigned(settings_control_box.settings_pd.Kp);
										when x"0b" =>  setting_val(15 downto 0) := unsigned(settings_control_box.settings_pd.Kd); 
										when x"0c" =>  setting_val(15 downto 0) := unsigned(settings_control_box.max_temperature);
										when x"0d" =>  setting_val(15 downto 0) := unsigned(settings_control_box.offset_term);
										when x"0e" =>  setting_val(15 downto 0) := unsigned(settings_control_box.user_limit);
										when x"0f" =>  setting_val(15 downto 0) := unsigned(alpha_pedal_assist);
										when x"10" =>  setting_val(15 downto 0) := unsigned(alpha_speed);
										when others => update_setting_flag :=  update_setting_flag;
									end case;
								
									uart_dev_status.flash := True;
							
							end if;
						end if;
		
		
					end if;
	
					if uart_any_taken(uart_dev_status) = True then
						
						if uart_dev_status.flash = True and
							 (uart_dev_status.serviced = uart_no_device or uart_dev_status.serviced = flash_uart_dev) then
						
							if i_busy_uart = '0' then
								uart_dev_status.serviced := flash_uart_dev; 
								case val_cnt is
									  when 0 =>   o_to_uart <= x"05"; -- size
									  when 1 =>   o_to_uart <= std_logic_vector(flash_data_code);
									  when 2 =>   o_to_uart <= std_logic_vector(setting_id);
									  when 3 =>   o_to_uart <= std_logic_vector(setting_val(23 downto 16));
									  when 4 =>   o_to_uart <= std_logic_vector(setting_val(15 downto 8));
									  when 5 =>   o_to_uart <= std_logic_vector(setting_val(7 downto 0));
									  when others => o_to_uart <=  (others=>'Z');
								end case;
								enable_uart <= '1';
							elsif val_cnt = 6 and i_busy_uart = '1' then
									uart_dev_status.serviced := uart_no_device;
									uart_dev_status.flash := False;
									user_command := no_command; 
									val_cnt := 0;	
									
							end if;	
						
						
						elsif uart_dev_status.motor = True  and
							 (uart_dev_status.serviced = uart_no_device or uart_dev_status.serviced = motor_uart_dev) then
						 
							if i_busy_uart = '0' then 	
								uart_dev_status.serviced := motor_uart_dev; 				
								time_tmp := to_unsigned(glob_clk_counter, time_tmp'length );
	
								case val_cnt is
								  when 0 =>   o_to_uart <= x"09"; -- size
								  when 1 =>   o_to_uart <= std_logic_vector(motor_data_code);
								  when 2 =>   o_to_uart <= std_logic_vector(speed(15 downto 8));
								  when 3 =>   o_to_uart <= std_logic_vector(speed(7 downto 0));
								  when 4 =>   o_to_uart <= std_logic_vector(time_tmp(23 downto 16));
								  when 5 =>   o_to_uart <= std_logic_vector(time_tmp(15 downto 8));
								  when 6 =>   o_to_uart <= std_logic_vector(time_tmp(7 downto 0));
								  when 7 =>   o_to_uart <= std_logic_vector(hal_imp_cnt(23 downto 16));
								  when 8 =>   o_to_uart <= std_logic_vector(hal_imp_cnt(15 downto 8));
								  when 9 =>   o_to_uart <= std_logic_vector(hal_imp_cnt(7 downto 0));
								  
								  when others => o_to_uart <=  (others=>'Z');
								end case;
								enable_uart <= '1';
							elsif val_cnt = 10 and i_busy_uart = '1' then
									uart_dev_status.serviced := uart_no_device;
									uart_dev_status.motor := False;
									
									val_cnt := 0;	
									
							end if;
						
						
						elsif uart_dev_status.adc_data = True and
							 (uart_dev_status.serviced = uart_no_device or uart_dev_status.serviced = termistor_uart_dev) then 
						
							if i_busy_uart = '0' then
								uart_dev_status.serviced := termistor_uart_dev; 				 
								time_tmp := to_unsigned(glob_clk_counter, time_tmp'length );
							
								case val_cnt is
								  when 0 =>   o_to_uart <= x"07";
								  when 1 =>   o_to_uart <= std_logic_vector(adc_data_code);
								  when 2 =>   o_to_uart <= std_logic_vector(adc_measurement(15 downto 8));
								  when 3 =>   o_to_uart <= std_logic_vector(adc_measurement(7 downto 0));
								  when 4 =>   o_to_uart <= std_logic_vector(time_tmp(23 downto 16));
								  when 5 =>   o_to_uart <= std_logic_vector(time_tmp(15 downto 8));
								  when 6 =>   o_to_uart <= std_logic_vector(time_tmp(7 downto 0));
								  when 7 =>   o_to_uart <= std_logic_vector(adc_temp(9 downto 2));
								  when others => o_to_uart <=  (others=>'Z');
								end case;
								enable_uart <= '1';
							elsif val_cnt = 8 and i_busy_uart = '1' then
								uart_dev_status.serviced := uart_no_device;
								uart_dev_status.adc_data := False; 
								val_cnt := 0;							
							end if;
						end if;
						if i_busy_uart = '1' then
							if enable_uart = '1'  then
								val_cnt := val_cnt + 1;
								 enable_uart <= '0';
							end if;
						end if;
					end if;
						
					cnt := cnt - 1;	
					
				end if;
					
			case i_hal_data is
				when "101" =>  
					if hal_work = "00000" or hal_work = "10000" then
						hal_work := "10000";	
					else
						hal_err <= '1';
					end if;
				when "100"  =>  
					if hal_work = "10000" or hal_work = "11000" then
						hal_work := "11000";	
					else
						hal_err <= '1';
					end if;
				when "110"  =>  
					if hal_work = "11000" or hal_work = "11100" then
						hal_work := "11100";	
					else
						hal_err <= '1';
					end if;
				when "010"  =>  
					if hal_work = "11100" or hal_work = "11110" then
						hal_work := "11110";	
					else
						hal_err <= '1';
					end if;
				when "011"  =>  
					if hal_work = "11110" or hal_work = "11111" then
						hal_work := "11111";	
					else
						hal_err <= '1';
					end if;
				when "001"  =>  
					
					if hal_work = "11111" then
												
						hal_err <= '0';
					elsif hal_work /= "00000" then 
					
							hal_err <= '1';
					end if;
					hal_work := "00000";
				when others => 
					hal_err <= '0';
				end case;
				
				
			end if;
		end if;



			
	end process;
	

	process( i_control_mode,enable_uart,motor_transistors,i_pedal_imp,
          profile_1_pid,profile_2_pid,host_enable, i_brk_1, i_brk_2,
          offset_speed1,offset_speed2,max_speed1,max_speed2,hal_err,
			 i_hal_data )
	begin
		leds(3) <= hal_err;
		o_en_uart <= enable_uart;
		o_motor_transistors <= motor_transistors;
		--leds(2) <= i_brk_1 and i_brk_2 and host_enable;
		leds(2 downto 0 ) <= i_hal_data;
		control_box_setup.enable <=   i_brk_1 and i_brk_2 and host_enable;

				case i_control_mode is
		   when '1' =>
				settings_control_box.settings_pid <= profile_1_pid;
				settings_control_box.max_speed <= max_speed1;				
				settings_control_box.offset_speed <= offset_speed1;
		   when '0' =>
				settings_control_box.settings_pid <= profile_2_pid;
				settings_control_box.max_speed <= max_speed2;				
				settings_control_box.offset_speed <= offset_speed2;
			when others => settings_control_box.max_speed <= max_speed1;
			end case; 
	end process;
	
end behaviour;