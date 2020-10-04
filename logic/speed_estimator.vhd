


--use work.functions.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity speed_estimator is
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
		
end speed_estimator;

architecture behaviour of speed_estimator is

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
	
	component low_pass is
		port(
			res : in std_logic;		
			clk : in std_logic;		
			i_enable : in std_logic;		
			
			i_no_filter_val  : in unsigned(15 downto 0);
			i_alfa : in  unsigned(7 downto 0);
			o_filtered : out  unsigned(15 downto 0)
			);
	end component low_pass;
	
	component mul
		generic (CONSTANT IntPart : integer;
	  			 CONSTANT FracPart : integer );
	port  (
		A : in  unsigned(IntPart + FracPart - 1  downto 0);
		B : in  unsigned(IntPart + FracPart - 1  downto 0);
		outMul : out unsigned(IntPart + FracPart - 1  downto 0));
	end component;
			
		constant  a1: unsigned(7 downto 0) := x"79";
		constant  a0: signed(11 downto 0):= x"f7f";
		constant  mod_imp_speed: unsigned(7 downto 0):= x"30";
		signal throttle_val : unsigned(19  downto 0);
		signal imp_val : unsigned(19  downto 0);
		signal pedals_speed : unsigned(15 downto 0);
		signal sum_speed : unsigned(11 downto 0):= (others=>'0');
		signal filtered : unsigned(15 downto 0);
		signal enable_filter : std_logic := '0';
		
		constant period_max : integer := main_clock/work_period;
		
begin	

	module_mul_prv_val: mul
	generic map(
			 IntPart => 12,
			 FracPart => 8
	)
	port map (
			A(19 downto 8) => (others => '0'),
			A(7 downto 0) => a1,
			B(19 downto 18) => (others => '0'),
			B(17 downto 8) => i_throttle_meas,
			B(7 downto 0) => (others => '0'),
			outMul => throttle_val);

	module_mul_imp_val: mul
	generic map(
			 IntPart => 12,
			 FracPart => 8
	)
	port map (
			A(19 downto 16) => (others => '0'),
			A(15 downto 0) => pedals_speed,
			B(19 downto 16) => (others => '0'),
			B(15 downto 8) => mod_imp_speed,
			B(7 downto 0) => (others => '0'),
			outMul => imp_val);

	module_impulse : speed_impulse 
	generic map(
			 main_clock => main_clock,
			 work_period => work_period,
			 shift_impulses => 8
	)
	port map(
				res => res,		
				clk => clk,
				
				i_impulse => i_impulse,
				i_alfa => i_alfa,
				
				o_speed => pedals_speed
		);

	module_filter : low_pass 
			
	port map(
		res => res,
		clk => clk,	
		i_enable =>enable_filter,
			
		i_no_filter_val(11 downto 0) => sum_speed,
		i_no_filter_val(15 downto 12) => (others => '0'),
		i_alfa => x"50",
		o_filtered => filtered
		);

process(clk)
		variable speed : signed(11 downto 0);
		variable cnt_time_tick : integer  range period_max downto 0 := 0;
		
begin
	
		
		if rising_edge(clk)  then
			
			if res = '0' then
				sum_speed <= (others =>'0');
				enable_filter <= '0';
				cnt_time_tick := 0;
			else
				speed := (others =>'0');
				speed := signed(throttle_val(19 downto 8)) + a0;
				if speed < 0 then
					speed := (others =>'0');
				end if; 
				
				speed := speed+  signed(i_manu_speed) + signed(imp_val(19 downto 8));
				if speed > x"0ff" then
					speed(7 downto 0):= (others => '1'); 
				end if;
			
				sum_speed <= filtered(11 downto 0);
				if 	cnt_time_tick = period_max then
					
					cnt_time_tick := 0; 
					enable_filter <= '1';
		
				else
					enable_filter <= '0';
					cnt_time_tick := cnt_time_tick + 1;
				end if;
			end if;
				
		end if;
	

end  process;

process(sum_speed)
begin
	o_speed <= unsigned(sum_speed(7 downto 0));
end process;


end behaviour;
