library IEEE;
use IEEE.std_logic_1164.all;

use ieee.numeric_std.all;
entity float_mul_tb is
end float_mul_tb;

architecture t_behaviour of float_mul_tb is
		CONSTANT exponent : integer := 6;
	   	CONSTANT mantisa : integer := 9;

		
		signal A :  unsigned(exponent + mantisa  downto 0);
		signal B :  unsigned(exponent + mantisa downto 0);

		signal outMul : unsigned(exponent + mantisa  downto 0);

		
		component float_mul is
			generic (CONSTANT exponent : integer := 6;
		   			 CONSTANT mantisa : integer := 9);
		
			port(
				A : in  unsigned(exponent + mantisa  downto 0);
				B : in  unsigned(exponent + mantisa  downto 0);
		
				outMul : out unsigned(exponent + mantisa  downto 0)
				);
		end component float_mul;
		
	begin	

		module_mul: float_mul
		generic map(
		 exponent => exponent,
		 mantisa => mantisa)
		port map (
				A =>A,
				B =>B,
				outMul => outMul
				);

		process
		
			begin
				
				--
				
				wait for 1 us;
				A <= "0100001110110111";
				B <= "0100001110110111";
--				enable_div <= '1';
--				wait for 1 us;
--				enable_div <= '0';
--				wait for 20 us;
--				assert quot  = x"03F8" report "problem";
--				wait for 1 us;
--				divisor <= x"0ccc";
--				divident <= x"0ccc";
--				enable_div <= '1';
--				wait for 1 us;
--				enable_div <= '0';
--				wait for 20 us;
--				assert quot  = x"0001" report "problem";
--				wait for 1 us;
--				divisor <= x"accc";
--				divident <= x"0ccc";
--				enable_div <= '1';
--				wait for 1 us;
--				enable_div <= '0';
--				wait for 20 us;
--				assert quot  = x"0000" report "problem";
--						
--				wait for 1 us;
--				divisor <= x"001c";
--				divident <= x"0ccc";
--				enable_div <= '1';
--				wait for 1 us;
--				enable_div <= '0';
--				wait for 20 us;
--				assert quot  = x"0075" report "problem";
							
								
				wait for 1000 us;	
				

				
				--
				
				wait for 10 ns;		
						

			end process;
		--

--
end t_behaviour;