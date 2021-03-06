

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.interface_data.all;
use work.functions.all;
use work.motor_auxiliary.all;



entity control_box is
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
end control_box;

architecture behaviour of control_box is

		component mul
			generic (CONSTANT IntPart : integer;
		  			 CONSTANT FracPart : integer );
		port  (
			A : in  unsigned(IntPart + FracPart - 1  downto 0);
			B : in  unsigned(IntPart + FracPart - 1  downto 0);
			outMul : out unsigned(IntPart + FracPart - 1  downto 0));
		end component;
	
		component div is
			generic (CONSTANT size : integer);
		
			port(
				res : in std_logic;
				clk : in std_logic;
				i_enable : in std_logic;
				
				i_divisor	: in  unsigned(size - 1  downto 0);
				i_divident : in  unsigned(size - 1  downto 0);
				o_valid : out std_logic;
				o_quotient : out unsigned(size - 1  downto 0)
				);
		end component div;	

		
		component trigger is
				
		port(
				res : in std_logic;		
				clk : in std_logic;	
				i_enable : in std_logic;
				i_pulse : in unsigned(7 downto 0);
				
				o_trigger : out std_logic
				);
		end component;

		component pd is
			generic (CONSTANT IntPart : integer := 8;
		   			 CONSTANT FracPart : integer := 8);
		
			port(
				res : in std_logic;
				clk : in std_logic;
				i_enable : in std_logic;
				i_val	: in  signed(IntPart + FracPart -1  downto 0);
				i_settings_pd : type_settings_pd;
				
				o_reg : out signed(IntPart + FracPart -1  downto 0)
				);
		end component pd;

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


--
--		component pid is
--			generic (CONSTANT IntPart : integer := 8;
--		   			 CONSTANT FracPart : integer := 8);
--		
--			port(
--				res : in std_logic;
--				clk : in std_logic;
--				i_enable : in std_logic;
--				i_n_clear : in std_logic;
--				i_val	: in  signed(IntPart + FracPart -1  downto 0);
--				i_settings_pid : type_settings_pid;
--				
--				o_reg : out signed(IntPart + FracPart -1  downto 0)
--				);
--		end component pid;

		constant IntPart : integer := 8;
		constant FracPart : integer := 8;
		constant upper_limit : integer := IntPart + FracPart - 1;
		
		
		signal data : std_logic_vector(upper_limit downto 0);	
		

		signal poly_temperature : signed(15  downto 0) := (others => '0');

		signal out_trigger : std_logic;
		signal pulse_trigger : unsigned(7 downto 0) := (others => '0');	


		signal enable_pid : std_logic;
		--signal enable_pd : std_logic;
		signal enable_div : std_logic;
		signal valid : std_logic;
		

		signal req_speed_motor : unsigned(upper_limit downto 0):=(others=>'0');
		signal motor_control_setup : type_motor_control_setup;
		signal motor_transistors : type_motor_transistors;
		

		signal in_temperature_reg: signed(upper_limit  downto 0);
		signal out_temperature_reg: signed(upper_limit  downto 0);

		signal in_reg : signed(upper_limit  downto 0);
		signal out_reg : signed(upper_limit  downto 0);
		signal quot : unsigned(upper_limit downto 0);

		signal mul_a : unsigned(31  downto 0);
		signal mul_b : unsigned(31  downto 0);
		signal mul_out : unsigned(31  downto 0);
		
		
		signal divisor : unsigned(upper_limit  downto 0);
		
		constant clk_freq : integer := 1000000;
		constant periods_per_sec : integer := 2;


begin	
	

--			
--	module_mul_1: mul
--	generic map(
--			 IntPart =>16,
--			 FracPart => 16
--		 )
--		port map (
--			A => mul_a,
--			B => mul_b,
--			outMul => mul_out);



	temperature_pd_module : pd 
	generic map (
		 	IntPart => IntPart,
			FracPart => FracPart )
		
	port map (
			res =>res,
			clk =>clk,
			i_enable =>enable_pid,
			i_val => in_temperature_reg,
			i_settings_pd => i_settings_control_box.settings_pd,
			o_reg => out_temperature_reg
			);

--	motor_pid_module : pid 
--	generic map (
--		 	IntPart => IntPart,
--			FracPart => FracPart )
--		
--	port map (
--			res =>res,
--			clk =>clk,
--			i_enable =>enable_pid,
--			i_n_clear => i_control_box_setup.enable,
--			i_val => in_reg,
--			i_settings_pid => i_settings_control_box.settings_pid,
--			o_reg => out_reg
--			);

	trigger_func : trigger	
		port map(
				res => res, 		
				clk => clk,	
				i_enable => i_control_box_setup.enable,
				i_pulse => pulse_trigger,
				
				o_trigger => out_trigger
		);

	motor_driver_func : motor_driver
		port map( 
				res => res, 	
				clk => clk,		
				i_req_speed => req_speed_motor(7 downto 0),
				i_work_wave => out_trigger,
				i_motor_control_setup => motor_control_setup,
		
				o_motor_transistors => motor_transistors
				);


	process(clk)
		variable uart_sized : boolean := False; 
	
		type type_regulator_state is ( regulator_idle, determine_start_limit,regulator_speed_check,regulator_init,regulator_valid );
			
		constant config_register_h : unsigned(7 downto 0) := "01000100";
		constant config_register_l : unsigned(7 downto 0) := "01100011";

		variable cnt : integer := 0;			
		variable val_cnt : integer  range 7 downto 0 := 0;

		variable regulator_state : type_regulator_state := regulator_idle;

		constant glob_clk_denom : integer := clk_freq/periods_per_sec;
		constant send_motor_data_wait : integer := 500;
		variable glob_clk_counter : integer := 0;
		variable glob_small_clk_counter : integer range glob_clk_denom downto 0  := 0;
	
		variable last_motor_action : integer := 0;
		
		variable time_tmp : unsigned(15 downto 0);
	
		variable sp : unsigned(15 downto 0);
		
		variable last_hal_data : std_logic_vector(2 downto 0);
	
		variable modified_reg : signed(upper_limit  downto 0);
		variable modified_temp_reg : signed(upper_limit  downto 0);
		variable tmp : unsigned(upper_limit downto 0):= (others => '0');
	begin

	--i_settings_control_box.max_temperature ;
		if rising_edge(clk)  then
			if res = '0' then
				pulse_trigger <= (others => '0');
				regulator_state := regulator_idle;
			else
				if i_control_box_setup.enable = '1' then
				
					if i_control_box_setup.manual = '1' then 
						pulse_trigger <= i_control_box_setup.pulse_trigger;
						req_speed_motor(7 downto 0) <= i_control_box_setup.req_speed_motor;
	
					else
						if cnt = glob_clk_denom then
							cnt := 0;
							regulator_state := regulator_speed_check; 
	
						else 
							cnt := cnt + 1;
						end if;
							
		
						if regulator_state = regulator_speed_check  then
							--mul_a <= (others => '0');
							--mul_b <= (others => '0');
							--mul_a(23 downto 8) <= i_settings_control_box.max_speed;
							--mul_b(15 downto 8) <= i_req_speed;
							tmp(7 downto 0):= i_req_speed;
							regulator_state := regulator_init;	
	
						elsif regulator_state = regulator_init then
							
							in_temperature_reg <= (signed(i_settings_control_box.max_temperature) - poly_temperature);

							--req_speed_motor <= mul_out(23 downto 8 );
							--in_reg <= signed(mul_out(23 downto 8 )) - signed(i_speed);
							
							if enable_pid = '1' then
								regulator_state := regulator_valid;
								enable_pid <= '0';
							else
								enable_pid <= '1';
							end if;
							
							
							if i_settings_control_box.start_limit + i_speed <  tmp  then
								tmp:= i_settings_control_box.start_limit + i_speed;

							end if;
							req_speed_motor <= shift_left(unsigned(tmp), 4);
							
						elsif regulator_state = regulator_valid then
								
							modified_reg := signed(req_speed_motor) + signed(i_settings_control_box.offset_speed);
							modified_temp_reg := out_temperature_reg + signed(i_settings_control_box.offset_term);
							
							if modified_temp_reg < 0 then  
								modified_temp_reg := (others => '0');
							elsif modified_temp_reg > signed(i_settings_control_box.user_limit) then
								modified_temp_reg := signed(i_settings_control_box.user_limit);
							end if;
													
							if modified_reg < 0 then  
								modified_reg := (others => '0');
							elsif modified_reg > signed(i_settings_control_box.user_limit) then
								modified_reg := signed(i_settings_control_box.user_limit);
							end if;
							
							
							if modified_temp_reg < modified_reg then
								pulse_trigger <= unsigned(modified_temp_reg(11 downto 4));
							else
								pulse_trigger <= unsigned(modified_reg(11 downto 4));
							end if;
					
							regulator_state := regulator_idle;
						end if;
					end if;
				else
					pulse_trigger <= (others => '0');
				end if;
					
			end if;

		end if;

	end process;

process(i_temp_transistors,motor_transistors,i_hal_data,i_control_box_setup)
begin
	
	poly_temperature(15 downto 6) <= signed(i_temp_transistors);
	motor_control_setup.hal <= i_control_box_setup.hal;
	motor_control_setup.enable <= i_control_box_setup.enable;
	motor_control_setup.hal_data <= i_hal_data;
	
	o_motor_transistors <= motor_transistors;
	

end process;
	
end behaviour;