

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity poly is
	generic (CONSTANT IntPart : integer := 12;
   			 CONSTANT FracPart : integer := 12);

	port(
		res : in std_logic;
		clk : in std_logic;
		i_enable : in std_logic;
		i_val	: in  std_logic_vector(15  downto 0);
		o_temp : out std_logic_vector(7  downto 0)
		);
end poly;

architecture behaviour of poly is
		constant one : unsigned(IntPart + FracPart - 1  downto 0) := x"001000";
		
		signal translated_input : unsigned (IntPart + FracPart - 1  downto 0);
		signal stored_val_power : unsigned (IntPart + FracPart - 1  downto 0) := one;
		signal out_mul_1 : unsigned (IntPart + FracPart - 1  downto 0);
		signal mul2_in : unsigned (IntPart + FracPart - 1  downto 0);
		signal out_mul_2 : unsigned (IntPart + FracPart - 1  downto 0);
		signal result : unsigned (IntPart + FracPart - 1  downto 0) := (others=>'0');
		
		--- 6.3511 17.3911 -1.3672 0.0495          
		
		constant par_0 : unsigned(IntPart + FracPart - 1  downto 0) := "000000000110010110011110";
		constant par_1 : unsigned(IntPart + FracPart - 1  downto 0) := "000000010001011001000001";
		constant par_2 : unsigned(IntPart + FracPart - 1  downto 0) := "000000000001010111100000";
		constant par_3 : unsigned(IntPart + FracPart - 1  downto 0) := "000000000000000011001010";

		component mul
			generic (CONSTANT IntPart : integer;
		   			 CONSTANT FracPart : integer );
		port  (
			A : in  unsigned(IntPart + FracPart - 1  downto 0);
			B : in  unsigned(IntPart + FracPart - 1  downto 0);
			outMul : out unsigned(IntPart + FracPart - 1  downto 0));
		end component;
				
begin	

		module_mul1: mul
		generic map(
			 IntPart => IntPart,
			 FracPart => FracPart
		 )
		port map (
			A => stored_val_power,
			B => unsigned(translated_input),
			outMul => out_mul_1);

		module_mul2: mul
		generic map(
			 IntPart => IntPart,
			 FracPart => FracPart
		 )
		port map (
			A => stored_val_power,
			B => mul2_in,
			outMul => out_mul_2);

	process(clk)
		type state_type is (Inactive, Active, Calculated);
		variable state : state_type := Inactive;

		variable fracRange : integer := IntPart + FracPart;
		variable cnt : integer range 3 downto 0 := 0;


	begin
			
		if  res = '0' then
			cnt := 0;
			state := Inactive;
			stored_val_power <= one;
			result <= (others=>'0');
		elsif  rising_edge(clk) then
			
			if i_enable = '1' and state = Inactive then 
				state := Active;
				result <= par_0;
			elsif  i_enable = '0' and state = Calculated then
				state := Inactive;
				cnt := 0;
			elsif state = Active then
			
				case cnt is
				  when 0 => mul2_in <= par_1;
				  when 1 => mul2_in <= par_2;
				  when 2 => mul2_in <= par_3;
				  when others => mul2_in <= (others=>'0');
				end case;
				
				if cnt = 2 then
					result <= result - out_mul_2;
				else
					result <= result + out_mul_2;
				end if;
				
				if cnt = 3 then
					stored_val_power <= one;
					state := Calculated; 
				else
					stored_val_power <= out_mul_1;
					cnt := cnt + 1;
				end if;
			end if;
			
		end if;
		
	end process;

	process(result,i_val)
	begin
		translated_input(16 downto 1) <= unsigned(i_val);
		o_temp <= std_logic_vector(result(IntPart + FracPart - 5  downto FracPart));
	

	end process;

end behaviour;

		