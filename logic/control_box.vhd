

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
		
		i_temp_transistors : in unsigned(15 downto 0);
		i_req_speed : in unsigned(7 downto 0);
		i_req_temperature : in unsigned(7 downto 0);
		i_control_box_setup : in type_control_box_setup;
		i_hal_data : in std_logic_vector(2 downto 0);
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

		component pd is
			generic (CONSTANT IntPart : integer := 8;
		   			 CONSTANT FracPart : integer := 8);
		
			port(
				res : in std_logic;
				clk : in std_logic;
				i_enable : in std_logic;
				i_val	: in  signed(IntPart + FracPart -1  downto 0);
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

		component pid is
			generic (CONSTANT IntPart : integer := 8;
		   			 CONSTANT FracPart : integer := 8);
		
			port(
				res : in std_logic;
				clk : in std_logic;
				i_enable : in std_logic;
				i_val	: in  signed(IntPart + FracPart -1  downto 0);
				o_reg : out signed(IntPart + FracPart -1  downto 0)
				);
		end component pid;

		constant IntPart : integer := 8;
		constant FracPart : integer := 8;
		constant upper_limit : integer := IntPart + FracPart - 1;
		
		
		signal data : std_logic_vector(upper_limit downto 0);	
		
		signal poly_enable : std_logic;	
		signal poly_temperature : unsigned(7  downto 0);	
		signal poly_val : unsigned(upper_limit downto 0) := (others => '0');

		signal en_trigger : std_logic;	
		signal out_trigger : std_logic;
		signal time_trigger : unsigned(upper_limit  downto 0);
		signal pulse_trigger : unsigned(upper_limit downto 0) := (others => '0');	
		signal stop_trigger : std_logic;


		signal enable_pid : std_logic;
		--signal enable_pd : std_logic;
		signal enable_div : std_logic;
		signal valid : std_logic;
		
		
		signal impulse : std_logic;
		

		constant offset_voltage : unsigned(upper_limit downto 0) := x"0300";--3V 

		constant max_speed : unsigned(upper_limit downto 0) := x"2800";--40km/h
		constant battery_voltage : unsigned(upper_limit downto 0) := x"2400";--36V

		constant max_temperature : unsigned(upper_limit downto 0) := x"0200";-- Celsius
		constant offset_temperature : unsigned(upper_limit downto 0) := x"0200";-- 80
		constant offset_tmp_voltage : unsigned(upper_limit downto 0) := x"0300";--10V 
		
		constant period_trigger : unsigned(upper_limit downto 0) := x"01fe";
		
		signal req_speed_motor : unsigned(upper_limit downto 0);
		signal motor_control_setup : type_motor_control_setup;
		signal motor_transistors : type_motor_transistors;
		
		signal speed : unsigned(15 downto 0);

		signal in_temperature_reg: signed(upper_limit  downto 0);
		signal out_temperature_reg: signed(upper_limit  downto 0);

		signal in_reg : signed(upper_limit  downto 0);
		signal out_reg : signed(upper_limit  downto 0);
		signal quot : unsigned(upper_limit downto 0);

		signal mul_a : unsigned(31  downto 0);
		signal mul_b : unsigned(31  downto 0);
		signal mul_out : unsigned(31  downto 0);
		
		--signal mul_a_2 : unsigned(31  downto 0);
		--signal mul_b_2 : unsigned(31  downto 0);
		--signal mul_out_2 : unsigned(31  downto 0);
		
		signal divisor : unsigned(upper_limit  downto 0);
		
		constant clk_freq : integer := 1000000;
		constant periods_per_sec : integer := 10;


begin	
	

			
	module_mul_1: mul
	generic map(
			 IntPart =>16,
			 FracPart => 16
		 )
		port map (
			A => mul_a,
			B => mul_b,
			outMul => mul_out);

--	module_mul_2: mul
--	generic map(
--			 IntPart =>16,
--			 FracPart => 16
--		 )
--		port map (
--			A => mul_a_2,
--			B => mul_b_2,
--			outMul => mul_out_2);
	
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
		 main_clock =>clk_freq,
		 work_period =>periods_per_sec
		)
				
		port map(
				res => res, 	
				clk => clk,	
				
				i_impulse => impulse,
				o_speed => speed
				);

	temperature_pd_module : pd 
	generic map (
		 	IntPart => IntPart,
			FracPart => FracPart )
		
	port map (
			res =>res,
			clk =>clk,
			i_enable =>enable_pid,
			i_val => in_temperature_reg,
			o_reg => out_temperature_reg
			);

	motor_pid_module : pid 
	generic map (
		 	IntPart => IntPart,
			FracPart => FracPart )
		
	port map (
			res =>res,
			clk =>clk,
			i_enable =>enable_pid,
			i_val => in_reg,
			o_reg => out_reg
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
				i_req_speed => req_speed_motor(7 downto 0),
				i_work_wave => out_trigger,
				i_motor_control_setup => motor_control_setup,
		
				o_motor_transistors => motor_transistors
				);

	module_div: div
		generic map(
		 size => IntPart + FracPart)
		port map (
		res => res,
		clk => clk,
		i_enable => enable_div,
		i_divisor => divisor,
		i_divident	=> mul_out(31 downto 16),
		o_valid => valid,
		o_quotient => quot);

	process(clk)
		variable uart_sized : boolean := False; 
	
		type type_regulator_state is ( regulator_idle,regulator_speed_check,regulator_init,regulator_valid, regulator_processing_output, regulator_initiate_trigger );
			
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
	begin


		if rising_edge(clk)  then
			if res = '0' then
				pulse_trigger <= (others => '0');
				regulator_state := regulator_idle;
			else
				if i_control_box_setup.enable = '1' then
					if cnt = glob_clk_denom then
						cnt := 0;
						regulator_state := regulator_speed_check; 
	
					else 
						cnt := cnt + 1;
					end if;
						
	
					if regulator_state = regulator_speed_check  then
						mul_a <= (others => '0');
						mul_b <= (others => '0');
						mul_a(23 downto 8) <= max_speed;
						mul_b(15 downto 8) <= i_req_speed;
						
						regulator_state := regulator_init;
					elsif regulator_state = regulator_init then

						in_temperature_reg <= signed(poly_temperature) + signed(max_temperature);
						
						req_speed_motor <= mul_out(23 downto 8 );
						in_reg <= signed(mul_out(23 downto 8 )) - signed(speed);
						
						if enable_pid = '1' then
							regulator_state := regulator_valid;
							enable_pid <= '0';
						else
							enable_pid <= '1';
						end if;
						
					elsif regulator_state = regulator_valid then
						modified_reg := out_reg + signed(offset_voltage);
						modified_temp_reg := out_temperature_reg + signed(offset_tmp_voltage);

						if modified_temp_reg < 0 then  
							modified_temp_reg := (others => '0');
						elsif modified_temp_reg > signed(battery_voltage) then
							modified_temp_reg := signed(battery_voltage);
						end if;
												
						if modified_reg < 0 then  
							modified_reg := (others => '0');
						elsif modified_reg > signed(battery_voltage) then
							modified_reg := signed(battery_voltage);
						end if;
						
						if modified_temp_reg < modified_reg then
							mul_a(31 downto 16) <= period_trigger;
							mul_b(23 downto 8) <= unsigned(modified_temp_reg);
							
						else
							mul_a(31 downto 16) <= period_trigger;
							mul_b(23 downto 8) <= unsigned(modified_reg);
							
						end if;
						
						divisor <= (others => '0');
						divisor(7 downto 0) <= battery_voltage(15 downto 8);
						enable_div <= '1';
						regulator_state := regulator_processing_output;
					elsif regulator_state = regulator_processing_output then
						if enable_div = '1' then
							 enable_div <= '0';
						end if;
						if valid = '1' then
							regulator_state := regulator_initiate_trigger;
						end if;
							
					elsif regulator_state = regulator_initiate_trigger then
						pulse_trigger <= quot;
						regulator_state := regulator_idle;
					end if;
			
				
					if impulse = '1' then
						impulse <= '0';
					elsif i_hal_data /= last_hal_data then
						last_hal_data := i_hal_data;
						impulse <= '1';
					end if; 
				end if;
					
			end if;

		end if;

	end process;


	
end behaviour;