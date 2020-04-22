

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.interface_data.all;
use work.functions.all;
		


entity control_unit is
	generic (CONSTANT period : integer := 1000000);

	port(
		clk : in  std_logic;
		res : in  std_logic;
		
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
					
					
					o_received : out std_logic;
					o_spi : out type_from_spi;
					o_busy	: out std_logic
				);
		end component flash_controller;


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
						
					o_received => received_flash,
					o_spi => o_spi,
					o_busy => busy_flash
				);
	
	
	process(clk)
		variable uart_sized : boolean := False; 
	
		type state_type is (Setup, Index_Read,Standby, Cycle, Empty);
		
		type type_i2c_operations is ( i2c_index, i2c_data_H, i2c_data_L );
		
		type type_user_commands is (no_command,wave_and_termistor,  flash_write, flash_read );
		
		type type_init_trigger_phase is ( unit_step_freq_h,unit_step_freq_l, unit_step_pulse_h,unit_step_pulse_l);
		
		type type_flash_write_state is ( get_flash_write_addr, get_flash_write_byte2, get_flash_write_byte1, get_flash_write_byte0, execute_flash_write );
		type type_flash_read_state is ( get_flash_read_addr, execute_flash_read,progress_flash_read, read_flash_done, send_flash_data );
				
		constant stop_command : unsigned(7 downto 0) := x"00";
		constant measure_command : unsigned(7 downto 0) := x"01";
		constant flash_write_command : unsigned(7 downto 0) := x"02";				
		constant flash_read_command : unsigned(7 downto 0) := x"03";
		
		constant termistor_data_code : unsigned(7 downto 0) := x"00";
		constant flash_data_code : unsigned(7 downto 0) := x"01";
		
		
		constant config_register_h : unsigned(7 downto 0) := "01000100";
		constant config_register_l : unsigned(7 downto 0) := "01100011";
		constant short_break : integer := 50;
		variable cnt : integer := 0;			
		variable val_cnt : integer  range 7 downto 0 := 0;
		variable state : state_type := Setup;
		variable i2c_state : type_i2c_operations := i2c_index;
		variable enable_pc_write : std_logic;
		
		variable flash_read_state : type_flash_read_state;
		variable flash_write_state : type_flash_write_state; 
		variable user_command : type_user_commands := no_command;
		variable trigger_phase : type_init_trigger_phase;
		
		variable uart_dev_status : type_uart_dev_status  := (False,False);
	begin
		leds(0) <= blink_1;
		leds(1) <= blink_2;	
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
				uart_dev_status := (False,False);
		else

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
					
						if i_busy_uart = '0' and
						   uart_take(uart_dev_status, flash_uart_dev) = true  then
							
							uart_dev_status.flash := True;
							case val_cnt is
							  when 0 =>   o_to_uart <= x"05"; -- size
							  when 1 =>   o_to_uart <= std_logic_vector(flash_data_code);
							  when 2 =>   o_to_uart <= std_logic_vector(address_flash);
							  when 3 =>   o_to_uart <= std_logic_vector(data_flash(23 downto 16));
							  when 4 =>   o_to_uart <= std_logic_vector(data_flash(15 downto 8));
							  when 5 =>   o_to_uart <= std_logic_vector(data_flash(7 downto 0));
							  when others => o_to_uart <=  (others=>'Z');
							end case;
						
							if val_cnt = 5 then
								uart_dev_status.flash := False;
								user_command := no_command; 
								val_cnt := 0;
							else
								if enable_uart = '1' then
									val_cnt := val_cnt + 1;
								end if;
							end if;
							
								
						end if;								
					end if;
					
				end if;
	
				if en_trigger = '1' then
				
					en_trigger <= '0';
				end if;
				if stop_trigger <= '1' then
					stop_trigger <= '0';
				end if;
	
				if 	i_received_uart = '1' then
						blink_1 <= '0';
					if user_command = no_command then 
							
						if i_from_uart = std_logic_vector(measure_command) then
								blink_2 <= '0';
								user_command := wave_and_termistor;
								trigger_phase := unit_step_freq_h;
						elsif i_from_uart = std_logic_vector(flash_write_command) then
							
								user_command := flash_write; 
								flash_write_state := get_flash_write_addr;
						elsif i_from_uart = std_logic_vector(flash_read_command) then
							
								user_command := flash_read;
								flash_read_state := get_flash_read_addr;
						elsif i_from_uart = std_logic_vector(stop_command)  then 
								stop_trigger <= '1';
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
								
						elsif user_command = flash_write then
							if flash_write_state = get_flash_write_addr then
								address_flash <= revert_byte(i_from_uart);									flash_write_state := get_flash_write_byte2;
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




				if i_busy_uart = '0' and
				   uart_any_taken(uart_dev_status) = True then
				
				   enable_uart <= '1';	
				else
				   enable_uart <= '0';
							
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
					
					
					if i_busy_uart = '0' and
					   uart_take(uart_dev_status, termistor_uart_dev) = true and
					   enable_pc_write = '1' then
						
						uart_dev_status.termistor := True;
						
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
						report integer'image(val_cnt);
						if val_cnt = 6 then
							uart_dev_status.termistor := False; 
							val_cnt := 0;
							state := Standby;
						else
							if enable_uart = '1' then
								val_cnt := val_cnt + 1;
							end if;
						end if;
						
							
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
	

	process(  enable_uart,out_trigger)
	begin
		o_wave <= out_trigger;
		o_en_uart <= enable_uart;
	end process;

	
end behaviour;