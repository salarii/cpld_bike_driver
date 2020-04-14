

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity low_pass is
	generic ( 
		freq : integer;
		internal_freq : integer
		);
		
	port(
		res : in std_logic;		
		clk : in std_logic;		

		i_pedal_assist_imp  : in std_logic; 
		i_alfa : in  unsigned(7 downto 0);
		o_filtered : out  unsigned(7 downto 0)
		);
end low_pass;

architecture behaviour of low_pass is
	constant integral : integer := 8;
	constant fraction : integer := 8;
	signal operand_A : unsigned(15 downto 0);
	signal operand_B : unsigned(15 downto 0);
	signal mul_out : unsigned(15 downto 0);

	component mul
		generic (CONSTANT IntPart : integer;
	  			 CONSTANT FracPart : integer );
	port  (
		A : in  unsigned(IntPart + FracPart - 1  downto 0);
		B : in  unsigned(IntPart + FracPart - 1  downto 0);
		outMul : out unsigned(IntPart + FracPart - 1  downto 0));
	end component;

begin	
		module_mul: mul
		generic map(
			 IntPart => integral,
			 FracPart => fraction
		 )
		port map (
			A => operand_A,
			B => operand_B,
			outMul => mul_out);

process(clk)
	type type_calculate_status is ( calculated, partialy_calculated, have_to_calculate);
	
	constant max_tick_cnt : integer := freq/internal_freq; 
	constant max_cnt : integer := 5; 

	variable ready_for_impulse : boolean  := true;	
	variable prev :  unsigned(15 downto 0);
	variable tick_cnt : integer range max_tick_cnt - 1 downto 0;
	variable cnt : integer range max_cnt -1 downto 0;
	variable value : unsigned(7 downto 0);
	variable calculate_status : type_calculate_status := calculated;
begin
	
	if rising_edge(clk)  then
		if  res = '0' then
			tick_cnt := max_tick_cnt;
			o_filtered <= (others => '0');
		else
			if tick_cnt = 0 then
				tick_cnt := max_tick_cnt;
				if ready_for_impulse = true and i_pedal_assist_imp = '1' then
					ready_for_impulse := false;
					cnt := max_cnt -1;
					value := x"ff";
			
				elsif cnt > 0 then
					cnt := cnt - 1;
					
				else	
					if cnt = 0 then
						value := x"00"; 		
					end if;			
					
						
					if i_pedal_assist_imp = '0' and cnt= 0 then
						ready_for_impulse := true;
					end if;
					
				end if;		
			
			else

				if calculate_status = have_to_calculate then
					operand_A(15 downto 0) <= prev;
					operand_B(7 downto 0) <= x"ff" - i_alfa;
					operand_B(15 downto 8) <= (others => '0');
				elsif calculate_status = partialy_calculated then
					prev := mul_out;
					operand_A(15 downto 8) <= value;
					operand_A(7 downto 0) <= (others => '0');
					operand_B(7 downto 0) <= i_alfa;
					operand_B(15 downto 8) <= (others => '0');
			
				elsif calculate_status = calculated then
				
					o_filtered <= mul_out(15  downto 8) + prev(15  downto 8);
				end if;
			
				tick_cnt := tick_cnt - 1;

			end if;
		
		end if;
	end if;
end  process;
	
	

end behaviour;
