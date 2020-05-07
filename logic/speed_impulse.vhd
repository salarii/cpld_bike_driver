


--use work.functions.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity speed_impulse is
	generic ( 
		CONSTANT main_clock : integer;
		CONSTANT work_period : integer;
		CONSTANT out_period : integer
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
		
		signal lap_cycles	: unsigned(15 downto 0);
		signal freq : unsigned(15  downto 0);	
		signal valid : std_logic;
		signal enable_div : std_logic := '0';
		constant  base : integer := 1000;
		constant norm : unsigned(15 downto 0):= to_unsigned(base,16);
	
		signal enable_filter : std_logic := '0';		
			
		constant alfa : unsigned(7 downto 0):= x"80";
		signal filtered : unsigned(15 downto 0) := (others => '0');

		signal rotation_speed : unsigned(15 downto 0):= (others => '0');

		signal debug_cnt_time_tick   : unsigned(15 downto 0);
		signal debug_cnt_out   : unsigned(15 downto 0); 
		signal debug_cnt_rot   : unsigned(15 downto 0); 
begin	


		module_div: div
		generic map(
		 size => 16)
		port map (
		res => res,
		clk => clk,
		i_enable => enable_div,
		i_divisor => lap_cycles,
		i_divident	=> norm,
		o_valid => valid,
		o_quotient => freq);


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

		type type_state is (idle, divide, filter);
		variable impCounted : boolean := False;

		constant period_max : integer := main_clock/work_period;
		constant out_period_max : integer := (main_clock/out_period)/period_max;

		variable cnt_time_tick : integer  range period_max downto 0 := 0;
		variable cnt_out : integer  range out_period_max downto 0 := 0;
		
		variable cnt_rotations : integer  range base downto 0 := 0;

		variable state : type_state;
begin
		
		debug_cnt_time_tick <= to_unsigned(cnt_time_tick,16);
		debug_cnt_out <= to_unsigned(cnt_out,16);
		debug_cnt_rot <= to_unsigned(cnt_rotations,16);
		
		if rising_edge(clk)  then
			
			if res = '0' then
				cnt_time_tick := 0;
				cnt_out := 0;
				cnt_rotations := 0;
				rotation_speed <= (others => '0');
				impCounted := False;
				enable_div <= '0';
				enable_filter <= '0';
			else
				if i_impulse = '1' and impCounted = False then
					cnt_rotations := cnt_rotations + 1;
					impCounted := True;
				elsif i_impulse = '0' and impCounted = True then
					impCounted := False;					
					
				end if;
				
				
				if 	cnt_time_tick = period_max then
					
					cnt_time_tick := 0; 
					
					if  cnt_out = out_period_max then
						cnt_out := 0;
						if state = idle then
							
							state := divide;
							lap_cycles <= to_unsigned(cnt_rotations,lap_cycles'length);
						end if;
				
					else
						cnt_out := cnt_out + 1; 
					end if;
					cnt_rotations := 0;
				else
					cnt_time_tick := cnt_time_tick + 1;
				end if;
				
				if state = divide  then
				
					if enable_div = '0' then
						enable_div <=  '1';
					elsif enable_div = '1' then
						state := filter;
						enable_div <=  '0';
					end if;
					
				elsif state = filter then
					if enable_filter = '1' then
						enable_filter <= '0';
						rotation_speed <= filtered;
						state := idle;
					end if;
					
					if valid = '1' then
						enable_filter <= '1';
					end if;
				
				end if;
				
			end if;
				
		end if;
	

end  process;

process(rotation_speed)
begin
	o_speed <= rotation_speed;
end process;


end behaviour;
