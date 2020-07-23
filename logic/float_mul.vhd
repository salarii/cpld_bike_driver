

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity float_mul is
	generic (CONSTANT exponent : integer := 6;
   			 CONSTANT mantisa : integer := 9);

	port(
		A : in  unsigned(exponent + mantisa  downto 0);
		B : in  unsigned(exponent + mantisa  downto 0);

		outMul : out unsigned(exponent + mantisa  downto 0)
		);
end float_mul;

architecture behaviour of float_mul is

		component mul is
		generic (CONSTANT IntPart : integer := 8;
	   			 CONSTANT FracPart : integer := 8);
	
		port(
			A : in  unsigned(IntPart + FracPart - 1  downto 0);
			B : in  unsigned(IntPart + FracPart - 1  downto 0);
	
			outMul : out unsigned(IntPart + FracPart - 1  downto 0)
			);
		end component mul;

		signal man_A : unsigned (mantisa + 1 downto 0); 
		signal man_B : unsigned (mantisa + 1 downto 0); 
		signal man_out : unsigned (mantisa + 1 downto 0); 
		
		signal exp_A : unsigned (exponent  downto 0); 
		signal exp_B : unsigned (exponent  downto 0); 
		
		constant sub : unsigned (exponent  downto 0) :=  "0011111";--(others=>'1' ,0 => '0', ); 

		signal exp_out : unsigned (exponent  downto 0);
begin	

		module_mul2: mul
		generic map(
			 IntPart => 2,
			 FracPart => mantisa
		 )
		port map (
			A => man_A,
			B => man_B,
			outMul => man_out);



	process(A,B,man_out,exp_A,exp_B,exp_out)
	begin
		man_A(mantisa -1 downto 0) <= A(mantisa -1 downto 0); 
		man_A(mantisa) <= '1';
		man_A(mantisa + 1) <= '0';

		man_B(mantisa -1 downto 0) <= B(mantisa -1 downto 0); 
		man_B(mantisa) <= '1';
		man_B(mantisa + 1) <= '0';
		
		exp_A(exponent  -1  downto 0) <= A(exponent + mantisa -1  downto mantisa);
		exp_A(exponent )<= '0';
		exp_B(exponent  -1  downto 0) <= B(exponent + mantisa -1  downto mantisa);
		exp_B(exponent )<= '0';		
		if man_out(mantisa) = '1' then
			exp_out <= exp_A + exp_B - sub + 1;
			outMul(mantisa -1  downto 0) <= man_out(mantisa  downto 1);
		else
			exp_out <= exp_A + exp_B - sub;
			outMul(mantisa -1  downto 0) <= man_out(mantisa -1  downto 0);
		end if;
		outMul(exponent + mantisa) <= A(exponent + mantisa)  xor B(exponent + mantisa);
		outMul(exponent + mantisa -1  downto mantisa) <= exp_out(exponent -1  downto 0);

	end process;
end behaviour;