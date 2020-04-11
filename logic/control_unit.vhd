

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.interface_data.all;

entity control_unit is
	generic (CONSTANT period : integer := 1000000);

	port(
		clk : in  std_logic;
		res : in  std_logic;
		

		i_from_i2c : in type_from_i2c;
		i2c_bus : inout std_logic_vector(7 downto 0);
		o_to_i2c : out type_to_i2c;
				
		i_busy_uart : in std_logic;
		i_from_uart : in std_logic_vector(7 downto 0);
		i_received_uart : in std_logic;
		o_to_uart : out std_logic_vector(7 downto 0);
		o_en_uart : out std_logic
		--leds : out std_logic_vector(4 downto 0);
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

	
	process(clk)
		type state_type is (Setup, Index_Read,Standby, Cycle, Empty);
		
		type type_i2c_operations is ( i2c_index, i2c_data_H, i2c_data_L );
		
		type type_user_commands is (no_command,trigger_unit_step_setup, command_active );
		type type_init_trigger_phase is ( unit_step_freq_h,unit_step_freq_l, unit_step_pulse_h,unit_step_pulse_l);
		
		constant config_register_h : unsigned(7 downto 0) := "01000100";
		constant config_register_l : unsigned(7 downto 0) := "01100011";
		constant short_break : integer := 50;
		variable cnt : integer := 0;			
		variable val_cnt : integer  range 5 downto 0 := 0;
		variable state : state_type := Setup;
		variable i2c_state : type_i2c_operations := i2c_index;
		variable enable_pc_write : std_logic;
		
		variable user_command : type_user_commands := no_command;
		variable trigger_phase : type_init_trigger_phase;
	begin
	
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
		else

				if  state = Setup then
					
					o_to_i2c.transaction <= Write;
					data <= (others => '0');	
					if i2c_state = i2c_index then
						
					
						i2c_bus <= x"01";
						o_to_i2c.continue <= '1'; 
						blink_1 <= not blink_1;
						if i_from_i2c.done = '1' then
								
							blink_2 <= not blink_2;
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
					end if;
					
					
					
				elsif state = Cycle then
					
					
					if i_busy_uart = '0' and
					   enable_uart = '0' and
					   enable_pc_write = '1' then
						
						case val_cnt is
						  when 0 =>   o_to_uart <= data(15 downto 8);
						  when 1 =>   o_to_uart <= data(7 downto 0);
						  when 2 =>   o_to_uart <= std_logic_vector(time_trigger(15 downto 8));
						  when 3 =>   o_to_uart <= std_logic_vector(time_trigger(7 downto 0));
						  when 4 =>   o_to_uart <= std_logic_vector(poly_temperature);
						  when others => o_to_uart <=  (others=>'Z');
						end case;
					
						if val_cnt = 5 then
							
							
							val_cnt := 0;
							state := Standby;
						else
							
							val_cnt := val_cnt + 1;
							enable_uart <= '1';
						end if;
						
					else
						enable_uart <= '0';
							
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
					
				if en_trigger = '1' then
				
					en_trigger <= '0';
				end if;
				
							
				if 	i_received_uart = '1' then
					if user_command = no_command then 
						if i_from_uart = x"01" then
							user_command := trigger_unit_step_setup;
							trigger_phase := unit_step_freq_h;
							
						end if;
					else	
						
						if i_from_uart = x"00" and user_command = command_active then 
						
							user_command := no_command;
						else
							if user_command = trigger_unit_step_setup then
						
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
									user_command := command_active;
								end if;
							end if;
						end if;

					end if;

				end if;

		 	
					
			end if;

		end if;

	end process;
	

	process(  enable_uart)
	begin
		
		o_en_uart <= enable_uart;
	end process;

	
end behaviour;