

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity low_pass is
		
	port(
		res : in std_logic;		
		clk : in std_logic;		
		i_enable : in std_logic;		
		
		i_no_filter_val  : in unsigned(15 downto 0);
		i_alfa : in  unsigned(7 downto 0);
		o_filtered : out  unsigned(15 downto 0)
		);
end low_pass;

architecture behaviour of low_pass is
	constant integral : integer := 8;
	constant fraction : integer := 8;

	signal mul_out : unsigned(15 downto 0);

	signal alpha_complement : unsigned(15 downto 0);
	signal alpha_full : unsigned(15 downto 0);

	signal prev_comp : unsigned(15 downto 0);
	signal now_comp : unsigned(15 downto 0);
	
	signal prev_val :  unsigned(15 downto 0) := (others => '0');
	
	
	component mul
		generic (CONSTANT IntPart : integer;
	  			 CONSTANT FracPart : integer );
	port  (
		A : in  unsigned(IntPart + FracPart - 1  downto 0);
		B : in  unsigned(IntPart + FracPart - 1  downto 0);
		outMul : out unsigned(IntPart + FracPart - 1  downto 0));
	end component;
	
	component embed_16_mul is

	port(
			A		: IN signed (15 DOWNTO 0);
			B		: IN signed (15 DOWNTO 0);
			outMul		: OUT signed (15 DOWNTO 0)
	);
				
	end component embed_16_mul;

begin	
--		module_mul_prv_val: mul
--		generic map(
--			 IntPart => integral,
--			 FracPart => fraction
--		 )
--		port map (
--			A => alpha_full,
--			B => prev_val,
--			outMul => prev_comp);

		module_mul_prv_val: embed_16_mul
		port map (
			A => signed(alpha_full),
			B => signed(prev_val),
			unsigned(outMul) => prev_comp);


		module_mul_new_val: embed_16_mul
		port map (
			A => signed(alpha_complement),
			B => signed(i_no_filter_val),
			unsigned(outMul) => now_comp);

--		module_mul_new_val: mul
--		generic map(
--			 IntPart => integral,
--			 FracPart => fraction
--		 )
--		port map (
--			A => alpha_complement,
--			B => i_no_filter_val,
--			outMul => now_comp);

process(clk)
	
	type type_status is (Idle, Calculate, Inactive);

	
	variable status : type_status := Idle;
	
	
begin
	
	if rising_edge(clk)  then
		if  res = '0' then
			prev_val <= (others => '0');
			status := Idle;
		else
			if i_enable = '1' and status =  Idle  then

					status := Calculate;				
					alpha_full(15 downto 8) <= (others =>'0');
					alpha_full(7 downto 0) <= i_alfa;
					alpha_complement <= x"0100" - (x"00" & i_alfa);
			elsif status = Calculate then
				
					prev_val <= now_comp + prev_comp;
					status := Inactive;
			
			elsif i_enable = '0' then
			
				status := Idle;	

			end if;
			
			
		end if;
	end if;
	
		
end  process;
	
process ( prev_val)
begin

	o_filtered <= prev_val;
end  process;

end behaviour;
