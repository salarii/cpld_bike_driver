

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity pid is
	generic (CONSTANT IntPart : integer := 8;
   			 CONSTANT FracPart : integer := 8);

	port(
		res : in std_logic;
		clk : in std_logic;
		i_enable : in std_logic;
		i_val	: in  signed(IntPart + FracPart -1  downto 0);
		o_reg : out signed(IntPart + FracPart -1  downto 0)
		);
end pid;

architecture behaviour of pid is
		constant one : unsigned(IntPart + FracPart - 1  downto 0) := x"0100";
		
		signal et1 : signed (IntPart + FracPart - 1  downto 0) := (others=>'0');
		signal et2 : signed (IntPart + FracPart - 1  downto 0) := (others=>'0');
		signal regt1 : signed (IntPart + FracPart - 1  downto 0) := (others=>'0');

		signal mul1_out : signed (IntPart + FracPart - 1  downto 0);
		signal mul2_out : signed (IntPart + FracPart - 1  downto 0);
		signal mul3_out : signed (IntPart + FracPart - 1  downto 0);
		
		--- 
		
		constant Kp : signed(IntPart + FracPart - 1  downto 0) := x"0001";
		constant Ki : signed(IntPart + FracPart - 1  downto 0) := (others=>'0');--"0001011001000001";
		constant Kd : signed(IntPart + FracPart - 1  downto 0) := (others=>'0');--"0001010111100000";
		
		constant pt0 : signed(IntPart + FracPart - 1  downto 0) := Kp + Ki + Kd;
		constant pt1 : signed(IntPart + FracPart - 1  downto 0) := Ki - Kp - shift_left(signed(Kd), 1);
		constant pt2 : signed(IntPart + FracPart - 1  downto 0) := Kd;
		
		component two_com_mul
				generic (CONSTANT IntPart : integer;
			   			 CONSTANT FracPart : integer );
			port  (
			A : in  signed(IntPart + FracPart - 1  downto 0);
			B : in  signed(IntPart + FracPart - 1  downto 0);
	
			outMul : out signed(IntPart + FracPart - 1  downto 0)
			);
		end component;
				
begin	

		module_mul1: two_com_mul
		generic map(
			 IntPart => IntPart,
			 FracPart => FracPart
		 )
		port map (
			A => pt0,
			B => signed(i_val),
			outMul => mul1_out);

		module_mul2: two_com_mul
		generic map(
			 IntPart => IntPart,
			 FracPart => FracPart
		 )
		port map (
			A => pt1,
			B => et1,
			outMul => mul2_out);

		module_mul3: two_com_mul
		generic map(
			 IntPart => IntPart,
			 FracPart => FracPart
		 )
		port map (
			A => pt2,
			B => et2,
			outMul => mul3_out);

	process(clk)
		type state_type is (Inactive, Active, Calculated);
		variable state : state_type := Inactive;

		variable fracRange : integer := IntPart + FracPart;
		variable cnt : integer range 3 downto 0 := 0;


	begin
			
		if  res = '0' then
			et1 <= (others=>'0');
			et2 <= (others=>'0');
			regt1 <= (others=>'0');

		elsif  rising_edge(clk) then
			if i_enable = '1' then
			
				regt1 <= regt1 + mul1_out + mul2_out + mul3_out;
				et1 <= signed(i_val);
				et2 <= signed(et1);
			end if;
		end if;
		
	end process;

	process(regt1)
	begin
		o_reg <= regt1;

	end process;

end behaviour;

		