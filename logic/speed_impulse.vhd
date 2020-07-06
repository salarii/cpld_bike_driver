


--use work.functions.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity speed_impulse is
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
		
end speed_impulse;

architecture behaviour of speed_impulse is

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
		
		signal lap_cycles	: unsigned(15 downto 0);
		signal freq : unsigned(15  downto 0);	
		constant base : integer := work_period;
		constant norm : unsigned(15 downto 0):= to_unsigned(base,16);
		constant integral : integer := 16;
		constant fraction : integer := 0;
		signal enable_filter : std_logic := '0';		
			
		constant alfa : unsigned(7 downto 0):= x"35";
		signal filtered : unsigned(15 downto 0) := (others => '0');

		signal rotation_speed : unsigned(15 downto 0):= (others => '0');

begin	


		module_mul_prv_val: mul
		generic map(
			 IntPart => integral,
			 FracPart => fraction
		 )
		port map (
			A => norm,
			B => lap_cycles,
			outMul => freq);

	module_filter : low_pass 
			
	port map(
		res => res,
		clk => clk,	
		i_enable =>enable_filter,
			
		i_no_filter_val => freq,
		i_alfa => alfa,
		o_filtered => filtered
		);

process(clk)

		type type_state is (idle, multiply, filter);
		variable impCounted : boolean := False;

		constant period_max : integer := main_clock/work_period;
		variable cnt_time_tick : integer  range period_max downto 0 := 0;
		
		variable cnt_rotations : integer := 0;

		variable state : type_state;
begin
	
		
		if rising_edge(clk)  then
			
			if res = '0' then
				cnt_time_tick := 0;
				cnt_rotations := 0;
				rotation_speed <= (others => '0');
				impCounted := False;
				enable_filter <= '0';
			else
				if i_impulse = '1' and impCounted = False then
					cnt_rotations := cnt_rotations + 1;
					impCounted := True;
				elsif i_impulse = '0' and impCounted = True then
					impCounted := False;					
					
				end if;
				
        if state = multiply  then
				
					state := filter;
					enable_filter <= '1';
					
				elsif state = filter then
					if enable_filter = '1' then
						enable_filter <= '0';
						rotation_speed <= filtered;
						state := idle;
					end if;
				
				end if;
				
				
				if 	cnt_time_tick = period_max then
					
					cnt_time_tick := 0; 
					
					if state = idle then
							state := multiply;
							lap_cycles <= to_unsigned(cnt_rotations,lap_cycles'length);
					end if;
				
					cnt_rotations := 0;
				else
					cnt_time_tick := cnt_time_tick + 1;
				end if;
				
				
			end if;
				
		end if;
	

end  process;

process(rotation_speed)
begin
	o_speed <= rotation_speed;
end process;


end behaviour;
