

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.interface_data.all;

entity pd is
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
end pd;

architecture behaviour of pd is
		constant one : unsigned(IntPart + FracPart - 1  downto 0) := x"0100";
		
		signal et1 : signed (IntPart + FracPart - 1  downto 0) := (others=>'0');
		signal regt1 : signed (IntPart + FracPart - 1  downto 0) := (others=>'0');

		signal mul1_out : signed (IntPart + FracPart - 1  downto 0);
		signal mul2_out : signed (IntPart + FracPart - 1  downto 0);
		
		signal pt0 : signed(IntPart + FracPart - 1  downto 0);
		signal pt1 : signed(IntPart + FracPart - 1  downto 0);
		
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


	process(clk)
		type state_type is (Inactive, Active, Calculated);
		variable state : state_type := Inactive;

		variable fracRange : integer := IntPart + FracPart;
		variable cnt : integer range 3 downto 0 := 0;


	begin
			
		if  res = '0' then
			et1 <= (others=>'0');
			regt1 <= (others=>'0');

		elsif  rising_edge(clk) then
			if i_enable = '1' then
			
				regt1 <= mul1_out + mul2_out;
				et1 <= signed(i_val);
			end if;
		end if;
		
	end process;


	process(regt1,i_settings_pd)
	begin
		o_reg <= regt1;
		
		pt0 <= i_settings_pd.Kp +i_settings_pd.Kd;
		pt1 <= -i_settings_pd.Kd;
end process;

end behaviour;

		