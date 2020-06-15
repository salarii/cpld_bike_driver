

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
		
		signal data : std_logic_vector(15 downto 0);	
		
		signal poly_enable : std_logic;	
		signal poly_temperature : unsigned(7  downto 0);	
		signal poly_val : unsigned(15 downto 0) := (others => '0');

		signal en_trigger : std_logic;	
		signal out_trigger : std_logic;
		signal time_trigger : unsigned(15  downto 0);
		signal pulse_trigger : unsigned(15 downto 0);	
		signal stop_trigger : std_logic;
		
		signal enable_div : std_logic;
		signal valid : std_logic;
		
		
		signal impulse : std_logic;
		
		constant battery_voltage : unsigned(15 downto 0) := x"0000";--36V
		constant offset_voltage : unsigned(15 downto 0) := x"0000";--3V 

		constant period_trigger : unsigned(15 downto 0);
		
		signal req_speed_motor : unsigned(7 downto 0);
		signal motor_control_setup : type_motor_control_setup;
		signal motor_transistors : type_motor_transistors;
		
		signal speed : unsigned(15 downto 0)

		signal out_reg : signed(IntPart + FracPart -1  downto 0);
		signal modified_reg : signed(IntPart + FracPart -1  downto 0);
		signal quot : unsigned(IntPart + FracPart -1  downto 0);

		signal mul_a : signed(31  downto 0);
		signal mul_b : unsigned(31  downto 0);
		signal mul_out : unsigned(31  downto 0);
begin	
	

	
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
		 work_period =>10
		)
				
		port map(
				res => res, 	
				clk => clk,	
				
				i_impulse => impulse,
				
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

	module_div: div
		generic map(
		 size => 16)
		port map (
		res => res,
		clk => clk,
		i_enable => enable_div,
		i_divisor => to_unsigned(modified_reg),
		i_divident	=> battery_voltage,
		o_valid => valid,
		o_quotient => quot);
	
	module_mul: mul
	generic map(
			 IntPart =>16,
			 FracPart => 16
		 )
		port map (
			A => mul_a,
			B => mul_b,
			outMul => mul_out);
			
	process(clk)
		variable uart_sized : boolean := False; 
	
		
		type type_run_motor_state is ( run_motor_get_speed, run_motor_get_pulse_width, execute_run_motor );
			

		constant config_register_h : unsigned(7 downto 0) := "01000100";
		constant config_register_l : unsigned(7 downto 0) := "01100011";
		constant short_break : integer := 50;
		variable cnt : integer := 0;			
		variable val_cnt : integer  range 7 downto 0 := 0;

		
		variable run_motor_state : type_run_motor_state;
		variable uart_dev_status : type_uart_dev_status  := (False,False,False);
		
		constant glob_clk_denom : integer := 1000;
		constant send_motor_data_wait : integer := 500;
		variable glob_clk_counter : integer := 0;
		variable glob_small_clk_counter : integer range glob_clk_denom downto 0  := 0;
	
		variable last_motor_action : integer := 0;
		
		variable time_tmp : unsigned(15 downto 0);
	
		variable sp : unsigned(15 downto 0);
		
		variable last_hal_data : std_logic_vector(2 downto 0);
	
		
	begin

	
	modified_reg := out_reg + offset_voltage;
	if modified_reg < 0 then  
		modified_reg := (others => '0');
	elsif modified_reg > battery_voltage then
		modified_reg := battery_voltage;
	end if;
	

	
	
		if rising_edge(clk)  then
			if res = '0' then

			else
				if impulse = '1' then
					impulse <= '0';
				elsif i_hal_data /= last_hal_data then
					last_hal_data := i_hal_data;
					impulse <= '1';
				end if; 
				
				
			end if;

		end if;

	end process;
	


	
end behaviour;