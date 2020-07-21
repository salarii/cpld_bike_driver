


--use work.functions.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity embed_16_mul is

	port(
			A		: IN signed (15 DOWNTO 0);
			B		: IN signed(15 DOWNTO 0);
			outMul		: OUT signed(15 DOWNTO 0)
		);
		
end embed_16_mul;

architecture behaviour of embed_16_mul is

	component mul_16_bit IS
		PORT
		(
			dataa		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			datab		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END component mul_16_bit;
	
	signal result_internal : signed(31 downto 0);

begin	

	module_mul: mul_16_bit
	port map (
			dataa => STD_LOGIC_VECTOR(A),
			datab => STD_LOGIC_VECTOR(B),
			signed(result) => result_internal);



process(result_internal)
begin
	outMul <= result_internal(23 downto 8);
end process;


end behaviour;
