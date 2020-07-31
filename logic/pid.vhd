

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.interface_data.all;

entity pid is
	generic (CONSTANT IntPart : integer := 8;
   			 CONSTANT FracPart : integer := 8);

	port(
		res : in std_logic;
		clk : in std_logic;
		i_enable : in std_logic;
		i_n_clear : in std_logic;
		i_val	: in  signed(IntPart + FracPart -1  downto 0);
		i_settings_pid : type_settings_pid;
		
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
		

		signal pt0 : signed(IntPart + FracPart - 1  downto 0);
		signal pt1 : signed(IntPart + FracPart - 1  downto 0);
		signal pt2 : signed(IntPart + FracPart - 1  downto 0);
		
		component two_com_mul
				generic (CONSTANT IntPart : integer;
			   			 CONSTANT FracPart : integer );
			port  (
			A : in  signed(IntPart + FracPart - 1  downto 0);
			B : in  signed(IntPart + FracPart - 1  downto 0);
	
			outMul : out signed(IntPart + FracPart - 1  downto 0)
			);
		end component;
		
		
		component embed_16_mul is

			port(
					A		: IN signed (15 DOWNTO 0);
					B		: IN signed (15 DOWNTO 0);
					outMul		: OUT signed (15 DOWNTO 0)
				);
				
		end component embed_16_mul;
				
begin	

		module_mul1: embed_16_mul
--		generic map(
--			 IntPart => IntPart,
--			 FracPart => FracPart
--		 )
		port map (
			A => pt0,
			B => signed(i_val),
			outMul => mul1_out);

		module_mul2: embed_16_mul
--		generic map(
--			 IntPart => IntPart,
--			 FracPart => FracPart
--		 )
		port map (
			A => pt1,
			B => et1,
			outMul => mul2_out);

		module_mul3: embed_16_mul
--		generic map(
--			 IntPart => IntPart,
--			 FracPart => FracPart
--		 )
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
			
			if i_n_clear = '0' then
					et1 <= (others=>'0');
					et2 <= (others=>'0');
					regt1 <= (others=>'0');
			else
				if i_enable = '1' then

					regt1 <= regt1 + mul1_out + mul2_out + mul3_out;
					et1 <= signed(i_val);
					et2 <= signed(et1);
					if regt1 > x"1600" then
						regt1<= x"1600";
					end if;
					
				end if;
			end if;
		end if;
		
	end process;

	process(regt1,i_settings_pid)
	begin
		o_reg <= regt1;
		 
		pt0 <= i_settings_pid.Kp + i_settings_pid.Ki + i_settings_pid.Kd;
		pt1 <= i_settings_pid.Ki - i_settings_pid.Kp - shift_left(signed(i_settings_pid.Kd), 1);
		pt2 <= i_settings_pid.Kd;
	end process;

end behaviour;

		