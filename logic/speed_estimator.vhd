


--use work.functions.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity speed_estimator is
		
	port(
			res : in std_logic;		
			clk : in std_logic;	
			
			i_throttle_meas : in unsigned(9 downto 0);
			i_impulse : in std_logic;
			
			o_speed : out unsigned(15 downto 0)
		);
		
end speed_estimator;

architecture behaviour of speed_estimator is

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
	
		
	component mul
		generic (CONSTANT IntPart : integer;
	  			 CONSTANT FracPart : integer );
	port  (
		A : in  unsigned(IntPart + FracPart - 1  downto 0);
		B : in  unsigned(IntPart + FracPart - 1  downto 0);
		outMul : out unsigned(IntPart + FracPart - 1  downto 0));
	end component;
			
		constant  a1: unsigned(7 downto 0) := x"79";
		constant  a0: signed(9 downto 0):= "1101111111";
		signal throttle_val : unsigned(17  downto 0);
		signal pedals_speed : unsigned(15 downto 0);
		signal sum_speed : signed(9 downto 0);

begin	

	module_mul_prv_val: mul
	generic map(
			 IntPart => 10,
			 FracPart => 8
	)
	port map (
			A(17 downto 8) => (others => '0'),
			A(7 downto 0) => a1,
			B(17 downto 8) => i_throttle_meas,
			B(7 downto 0) => (others => '0'),
			outMul => throttle_val);

	module_impulse : speed_impulse 
	generic map(
			 main_clock => 1000000,
			 work_period => 100
	)
	port map(
				res => res,		
				clk => clk,
				
				i_impulse => i_impulse,
				o_speed => pedals_speed
		);

process(clk)

begin
	
		
		if rising_edge(clk)  then
			
			if res = '0' then

			else
				sum_speed <= signed(throttle_val(17 downto 8)) + a0;
				
				
			end if;
				
		end if;
	

end  process;

--process(rotation_speed)
--begin
--	o_speed <= rotation_speed;
--end process;


end behaviour;
