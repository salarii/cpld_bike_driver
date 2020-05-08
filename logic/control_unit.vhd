

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
		
		i_impulse : in std_logic;
		
		i_spi : in type_to_spi;
		o_spi : out type_from_spi;
	

		i_from_i2c : in type_from_i2c;
		i2c_bus : inout std_logic_vector(7 downto 0);
		o_to_i2c : out type_to_i2c;
			
					
		i_busy_uart : in std_logic;
		i_from_uart : in std_logic_vector(7 downto 0);
		i_received_uart : in std_logic;
		o_to_uart : out std_logic_vector(7 downto 0);
		o_en_uart : out std_logic;
		o_wave : out std_logic;
		o_motor_transistors : out type_motor_transistors;
		leds : out std_logic_vector(4 downto 0)
		);
end control_unit;

architecture behaviour of control_unit is


		component poly is

		
			port(
				res : in std_logic;
				clk : in std_logic;
				i_enable : in std_logic;
				i_val	: in  std_logic_vector(15  downto 0);
				o_temp : out std_logic_vector(7  downto 0)
				);
		end component;
		
		component trigger is
			generic ( 
				CONSTANT time_divider : integer
				);
				
		port(
				res : in std_logic;		
				clk : in std_logic;	
				i_enable : in std_logic;
				i_stop : in std_logic;
				i_period : in unsigned(15 downto 0);
				i_pulse : in unsigned(15 downto 0);
				
				o_trigger : out std_logic;
				o_current_time : out unsigned(15 downto 0)
				);
		end component;

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
					i_put_bus_high : in std_logic;
					
					o_received : out std_logic;
					o_spi : out type_from_spi;
					o_busy	: out std_logic
				);
				
		end component flash_controller;

		component motor_driver is
		
			port( 
				res : in std_logic;		
				clk : in std_logic;		
				i_req_speed : in unsigned(7 downto 0);
				i_work_wave : in std_logic;
				i_motor_control_setup : in type_motor_control_setup;
		
				o_motor_transistors : out type_motor_transistors
				);
		end component motor_driver;


		component speed_impulse is
			generic ( 
				CONSTANT main_clock : integer;
				CONSTANT work_period : integer
				);
				
			port(
					res : in std_logic;		
					clk : in std_logic;	
					
					i_impulse : in std_logic;
					
					o_speed : out unsigned(15 downto 0)
				);
		end component speed_impulse;

		signal data : std_logic_vector(15 downto 0);	
		signal enable_uart  : std_logic;
		
		signal blink_1  : std_logic := '1';
		signal blink_2  : std_logic := '1';	
		
		signal poly_enable : std_logic;	
		signal poly_temperature : unsigned(7  downto 0);	
		signal poly_val : unsigned(15 downto 0) := (others => '0');

		signal en_trigger : std_logic;	
		signal out_trigger : std_logic;
		signal time_trigger : unsigned(15  downto 0);
		signal period_trigger : unsigned(15 downto 0);
		signal pulse_trigger : unsigned(15 downto 0);	
		signal stop_trigger : std_logic;
		
		
		signal data_flash : std_logic_vector(23 downto 0);
		signal address_flash : std_logic_vector(7 downto 0);
		signal busy_flash : std_logic;
		signal en_flash : std_logic;
		signal received_flash : std_logic;	
		signal transaction_flash : transaction_type;
		signal put_bus_high_flash : std_logic;
		
		signal req_speed_motor : unsigned(7 downto 0);
		signal motor_control_setup : type_motor_control_setup;
		signal motor_transistors : type_motor_transistors;
		
		signal speed : unsigned(15 downto 0);
begin	
	o_to_i2c.address <= "1001000";
	
	module_poly: poly

	port map (
		res => res,
		clk => clk,
		i_enable => poly_enable,
		i_val	=> std_logic_vector(poly_val),
		unsigned(o_temp) => poly_temperature 
		);	


	speed_impulse_func : speed_impulse 
	generic map ( 
		 main_clock =>1000000,
		 work_period =>2
		)
				
		port map(
				res => res, 	
				clk => clk,	
				
				i_impulse => i_impulse,
				
				o_speed => speed
				);

	trigger_func : trigger
	generic map (
	 	time_divider => 100000 )
				
		port map(
				res => res, 		
				clk => clk,	
				i_enable => en_trigger,
				i_stop => stop_trigger,
				i_period => period_trigger,
				i_pulse => pulse_trigger,
				
				o_trigger => out_trigger,
				o_current_time => time_trigger
		);

		motor_driver_func : motor_driver
		
			port map( 
				res => res, 	
				clk => clk,		
				i_req_speed => req_speed_motor,
				i_work_wave => out_trigger,
				i_motor_control_setup => motor_control_setup,
		
				o_motor_transistors => motor_transistors
				);
	
		flash_function : flash_controller
			generic map ( 
		 	freq => 1000000,
			bound => 100000 )
				
			port map(
					res => res,		
					clk => clk,
					 
					io_data => data_flash,
					i_address => address_flash,
					i_transaction => transaction_flash,
					i_enable => en_flash,
					i_spi => i_spi,
					i_put_bus_high =>	put_bus_high_flash,
					
					o_received => received_flash,
					o_spi => o_spi,
					o_busy => busy_flash
				);
	
	
	process(clk)
		variable uart_sized : boolean := False; 
	
		type state_type is (Setup, Index_Read,Standby, Cycle, Empty);
		
		type type_i2c_operations is ( i2c_index, i2c_data_H, i2c_data_L );
		
		type type_user_commands is (no_command,wave_and_termistor,  flash_write, flash_read, flash_erase, run_motor );
		
		type type_init_trigger_phase is ( unit_step_freq_h,unit_step_freq_l, unit_step_pulse_h,unit_step_pulse_l);
		
		type type_flash_write_state is ( get_flash_write_addr, get_flash_write_byte2, get_flash_write_byte1, get_flash_write_byte0, execute_flash_write );
		type type_flash_read_state is ( get_flash_read_addr, execute_flash_read,progress_flash_read, read_flash_done, send_flash_data );
		type type_flash_erase_state is ( get_flash_erase_addr, get_flash_erase_byte2, get_flash_erase_byte1, get_flash_erase_byte0, execute_flash_erase );
		type type_run_motor_state is ( run_motor_get_speed, run_motor_get_pulse_width, execute_run_motor );
			
				
		constant stop_command : unsigned(7 downto 0) := x"00";
		constant measure_command : unsigned(7 downto 0) := x"01";
		constant flash_write_command : unsigned(7 downto 0) := x"02";				
		constant flash_read_command : unsigned(7 downto 0) := x"03";
		constant flash_erase_command : unsigned(7 downto 0) := x"04";
		constant run_motor_command : unsigned(7 downto 0) := x"05";		
				
		constant termistor_data_code : unsigned(7 downto 0) := x"00";
		constant flash_data_code : unsigned(7 downto 0) := x"01";
		constant motor_data_code : unsigned(7 downto 0) := x"02";
		
		constant config_register_h : unsigned(7 downto 0) := "01000100";
		constant config_register_l : unsigned(7 downto 0) := "01100011";
		constant short_break : integer := 50;
		variable cnt : integer := 0;			
		variable val_cnt : integer  range 7 downto 0 := 0;
		variable state : state_type := Setup;
		variable i2c_state : type_i2c_operations := i2c_index;
		variable enable_pc_write : std_logic;
		
		variable flash_erase_state : type_flash_erase_state;
		variable flash_read_state : type_flash_read_state;
		variable flash_write_state : type_flash_write_state; 
		variable user_command : type_user_commands := no_command;
		variable trigger_phase : type_init_trigger_phase;
		variable run_motor_state : type_run_motor_state;
		variable uart_dev_status : type_uart_dev_status  := (False,False,False);
		
		constant glob_clk_denom : integer := 1000;
		constant send_motor_data_wait : integer := 500;
		variable glob_clk_counter : integer := 0;
		variable glob_small_clk_counter : integer range glob_clk_denom downto 0  := 0;
	
		variable last_motor_action : integer := 0;
		
		variable time_tmp : unsigned(15 downto 0);
	begin
		leds(0) <= blink_1;
		leds(1) <= blink_2;
		leds(2) <= motor_transistors.A_p;
		if rising_edge(clk)  then
			if res = '0' then
				state := Setup;
				cnt :=0;
				val_cnt := 0;
				i2c_bus <= (others=>'Z');
				enable_pc_write := '0';
				enable_uart <= '0';
				o_to_i2c.continue <= '0';
				--leds(4 downto 2) <= (others=>'1');
				i2c_state := i2c_index; 
				blink_1  <= '1';
				blink_2  <= '1';
				user_command := no_command;	
				uart_dev_status := (False,False,False);
				glob_clk_counter := 0;
				glob_small_clk_counter := 0;
				last_motor_action := 0;
		else
				if glob_small_clk_counter = glob_clk_denom  then
					glob_small_clk_counter := 0;
					glob_clk_counter := glob_clk_counter + 1; 
				else  
					glob_small_clk_counter := glob_small_clk_counter + 1; 				
				end if;

					
				if glob_clk_counter - last_motor_action > send_motor_data_wait then
					
					uart_dev_status.motor := True;
					last_motor_action := glob_clk_counter;
				end if;
							
						
				if en_trigger = '1' then
					en_trigger <= '0';
				end if;
				
				if stop_trigger <= '1' then
					stop_trigger <= '0';
				end if;
				
				
				if user_command = flash_write then
					
					if flash_write_state = execute_flash_write then
						en_flash <= '1';
						transaction_flash <= Write;
						if busy_flash = '1' then
							en_flash <= '0';
							user_command := no_command;
							 
							
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
							val_cnt := 0;
							
						end if;
					elsif flash_read_state = send_flash_data then
					
							uart_dev_status.flash := True;
										
					end if;
					
				elsif user_command = run_motor then	
					if run_motor_state = execute_run_motor then
						last_motor_action := glob_clk_counter;
						en_trigger <= '1';
				
						motor_control_setup.hal <= '0';
						motor_control_setup.enable <= '1';
						user_command := no_command; 
					end if;
					
				end if;
	

	
				if 	i_received_uart = '1' then
						blink_1 <= '0';
					if user_command = no_command then 
							
						if i_from_uart = std_logic_vector(measure_command) then
								
								user_command := wave_and_termistor;
								trigger_phase := unit_step_freq_h;
						elsif i_from_uart = std_logic_vector(flash_write_command) then
								put_bus_high_flash <= '1';
								user_command := flash_write; 
								flash_write_state := get_flash_write_addr;
						elsif i_from_uart = std_logic_vector(flash_read_command) then
								put_bus_high_flash <= '0';
								user_command := flash_read;
								flash_read_state := get_flash_read_addr;
						
						elsif i_from_uart = std_logic_vector(run_motor_command) then
								user_command := run_motor;
								
								run_motor_state := run_motor_get_speed;
						elsif i_from_uart = std_logic_vector(flash_erase_command) then
								put_bus_high_flash <= '1';
								user_command := flash_erase;
								flash_erase_state := get_flash_erase_addr;
						
						elsif i_from_uart = std_logic_vector(stop_command)  then 
							stop_trigger <= '1';
							motor_control_setup.enable <= '0';
							last_motor_action := glob_clk_counter;
						end if;
					else	
							
						if user_command = wave_and_termistor then
							
							if trigger_phase = unit_step_freq_h then
							
								period_trigger(15 downto 8) <= unsigned(i_from_uart);
								trigger_phase := unit_step_freq_l;
							elsif trigger_phase = unit_step_freq_l then
							
								period_trigger(7 downto 0) <= unsigned(i_from_uart);
								trigger_phase := unit_step_pulse_h;
							elsif trigger_phase = unit_step_pulse_h then
								pulse_trigger(15 downto 8) <= unsigned(i_from_uart);					
										
								trigger_phase := unit_step_pulse_l;
							elsif trigger_phase = unit_step_pulse_l then
							
								pulse_trigger(7 downto 0) <= unsigned(i_from_uart);					
										
								en_trigger <= '1';
							end if;
						elsif user_command = run_motor then
						
							
							if run_motor_state = run_motor_get_speed then
   								req_speed_motor <= unsigned(i_from_uart);
								run_motor_state := run_motor_get_pulse_width;	
							elsif run_motor_state = run_motor_get_pulse_width then
								period_trigger(7 downto 0) <= x"fe";
								period_trigger(15 downto 8) <= x"01";
								
								pulse_trigger <= (others => '0');
								pulse_trigger(8 downto 1) <= unsigned(i_from_uart);
								run_motor_state := execute_run_motor;	
							end if;								
						elsif user_command = flash_erase then
							
							if flash_erase_state = get_flash_erase_addr then
								address_flash <= revert_byte(i_from_uart);									
								flash_erase_state := get_flash_erase_byte2;
							elsif flash_erase_state = get_flash_erase_byte2 then
								data_flash(23 downto 16) <= i_from_uart;
								flash_erase_state := get_flash_erase_byte1;
							elsif flash_erase_state = get_flash_erase_byte1 then
								data_flash(15 downto 8) <= i_from_uart;
								flash_erase_state := get_flash_erase_byte0;
							elsif flash_erase_state = get_flash_erase_byte0 then
								data_flash(7 downto 0) <= i_from_uart;
								flash_erase_state := execute_flash_erase;
							end if;		
						elsif user_command = flash_write then
							
							if flash_write_state = get_flash_write_addr then
								address_flash <= revert_byte(i_from_uart);									
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
							if flash_read_state = get_flash_read_addr then
								
								address_flash <= revert_byte(i_from_uart);
								flash_read_state := execute_flash_read;
							end if;
						end if;
					end if;
	
	
				end if;




				if uart_any_taken(uart_dev_status) = True then
							
							

					if uart_dev_status.flash = True  then
						if i_busy_uart = '0' then 
							case val_cnt is
								  when 0 =>   o_to_uart <= x"05"; -- size
								  when 1 =>   o_to_uart <= std_logic_vector(flash_data_code);
								  when 2 =>   o_to_uart <= revert_byte(std_logic_vector(address_flash));
								  when 3 =>   o_to_uart <= std_logic_vector(data_flash(23 downto 16));
								  when 4 =>   o_to_uart <= std_logic_vector(data_flash(15 downto 8));
								  when 5 =>   o_to_uart <= std_logic_vector(data_flash(7 downto 0));
								  when others => o_to_uart <=  (others=>'Z');
							end case;
							enable_uart <= '1';
						elsif val_cnt = 6 and i_busy_uart = '1' then
								
								uart_dev_status.flash := False;
								user_command := no_command; 
								val_cnt := 0;	
								
						end if;	
					
					
					elsif uart_dev_status.motor = True  then
					 
						if i_busy_uart = '0' then 					
							time_tmp := to_unsigned(glob_clk_counter, time_tmp'length );

							case val_cnt is
							  when 0 =>   o_to_uart <= x"05"; -- size
							  when 1 =>   o_to_uart <= std_logic_vector(motor_data_code);
							  when 2 =>   o_to_uart <= std_logic_vector(speed(15 downto 8));
							  when 3 =>   o_to_uart <= std_logic_vector(speed(7 downto 0));
							  when 4 =>   o_to_uart <= std_logic_vector(time_tmp(15 downto 8));
							  when 5 =>   o_to_uart <= std_logic_vector(time_tmp(7 downto 0));
							  when others => o_to_uart <=  (others=>'Z');
							end case;
							enable_uart <= '1';
						elsif val_cnt = 6 and i_busy_uart = '1' then

								uart_dev_status.motor := False;
								
								val_cnt := 0;	
								
						end if;
					
					
					elsif uart_dev_status.termistor = True  then 
					
						if i_busy_uart = '0' then 
						
							case val_cnt is
							  when 0 =>   o_to_uart <= x"06";
							  when 1 =>   o_to_uart <= std_logic_vector(termistor_data_code);
							  when 2 =>   o_to_uart <= data(15 downto 8);
							  when 3 =>   o_to_uart <= data(7 downto 0);
							  when 4 =>   o_to_uart <= std_logic_vector(time_trigger(15 downto 8));
							  when 5 =>   o_to_uart <= std_logic_vector(time_trigger(7 downto 0));
							  when 6 =>   o_to_uart <= std_logic_vector(poly_temperature);
							  when others => o_to_uart <=  (others=>'Z');
							end case;
							enable_uart <= '1';
						elsif val_cnt = 7 and i_busy_uart = '1' then
							
							uart_dev_status.termistor := False; 
							val_cnt := 0;
							state := Standby;							
						end if;
					end if;
					if i_busy_uart = '1' then
						if enable_uart = '1'  then
							val_cnt := val_cnt + 1;
							 enable_uart <= '0';
						end if;
					end if;
				end if;
						
					 
				if  state = Setup then
					
					o_to_i2c.transaction <= Write;
					data <= (others => '0');	
					if i2c_state = i2c_index then
						
					
						i2c_bus <= x"01";
						o_to_i2c.continue <= '1'; 
						
						if i_from_i2c.done = '1' then
								
							i2c_bus <= std_logic_vector(config_register_h);	
							i2c_state := i2c_data_H;
						end if;
					
					elsif i2c_state = i2c_data_H then
						
						if i_from_i2c.done = '1' then	
								

							i2c_bus <= std_logic_vector(config_register_l);
							i2c_state := i2c_data_L;
							o_to_i2c.continue <= '0'; 
						end if;
						
					elsif i2c_state = i2c_data_L then
						if i_from_i2c.done = '1' then
							

							state := Index_Read;	
							cnt := short_break;	
						end if;
					end if;
					
					if i_from_i2c.busy = '0' and state /= Index_Read then	
						
						o_to_i2c.enable <= '1';
					elsif i_from_i2c.busy = '1' then
						
						o_to_i2c.enable <= '0';
					end if;
					
					
				elsif state = Index_Read then
					if  i_from_i2c.done = '1' then
						

						cnt := short_break;
						state := Standby;
					elsif cnt = 0 and  i_from_i2c.busy = '0' then
						i2c_bus <= x"00";	
						o_to_i2c.enable <= '1';
					elsif i_from_i2c.busy = '1' then
						
						o_to_i2c.enable <= '0';
					end if;
					
				elsif state = Standby then		
						
					if cnt = 0 then
						
						i2c_bus <= (others=>'Z');
						state := Cycle;
						poly_enable <= '0';	
						enable_pc_write := '0';
						i2c_state := i2c_data_H;
						cnt := period;
						val_cnt := 0;
					end if;
					
					
					
				elsif state = Cycle then
					
					
					if i_busy_uart = '0' and enable_pc_write = '1' then
						
						uart_dev_status.termistor := True;
								
						--state := Standby;							
					end if;
					
					
					if i2c_state = i2c_data_H and i_from_i2c.done = '1'  then	
						
						i2c_state := i2c_data_H;
						o_to_i2c.continue <= '0';
						o_to_i2c.enable <= '1';
						i2c_state := i2c_data_L;	
						data(15 downto 8) <= i2c_bus;
					elsif i2c_state = i2c_data_H and i_from_i2c.busy = '0' then
						
						o_to_i2c.transaction <= Read;
						o_to_i2c.enable <= '1';
						o_to_i2c.continue <= '1';	
					elsif i2c_state = i2c_data_L and i_from_i2c.done = '1'  then
						
						data(7 downto 0) <= i2c_bus;
						poly_enable <= '1';	
		
						poly_val <= unsigned(data);						
						enable_pc_write := '1';
							
					elsif i_from_i2c.busy = '1' then
						o_to_i2c.enable <= '0';
					end if;
					
								
				end if;	
				cnt := cnt - 1;	
				
					
			end if;

		end if;

	end process;
	

	process(  enable_uart,out_trigger,motor_transistors)
	begin
		o_wave <= out_trigger;
		o_en_uart <= enable_uart;
		o_motor_transistors <= motor_transistors;
	end process;

	
end behaviour;