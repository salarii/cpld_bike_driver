library IEEE;
use IEEE.std_logic_1164.all;

use ieee.numeric_std.all;
entity div_tb is
end div_tb;

architecture t_behaviour of div_tb is
		signal IntPart : integer := 16;
		signal FracPart : integer := 0;

		
		signal A :  signed(IntPart + FracPart - 1  downto 0);
		signal B :  signed(IntPart + FracPart - 1  downto 0);

		signal outMul : signed(IntPart + FracPart - 1  downto 0);

		
		component two_com_mul
			generic (CONSTANT IntPart : integer;
		   			 CONSTANT FracPart : integer );
		port  (
		A : in  signed(IntPart + FracPart - 1  downto 0);
		B : in  signed(IntPart + FracPart - 1  downto 0);

		outMul : out signed(IntPart + FracPart - 1  downto 0));
		end component two_com_mul;
		
	begin	


		module_mul: two_com_mul
		generic map(
			 IntPart => IntPart,
			 FracPart => FracPart
		 )
		port map (
			A => A,
			B => B,
			outMul => outMul);

		


		process
		
			begin
				
				--
				
				wait for 1 ns;
				A <= x"FFFF";
				B <= x"0032";
					
				wait for 1 ns;	
				
				assert outMul  = x"FFCE" report "problem:" & integer'image( to_integer(outMul) );
				
				wait for 1 ns;	
			
				A <= x"f101";
				B <= x"00fe";
					
				wait for 1 ns;	
				
				assert outMul  = x"ef1e" report "problem";
				
				wait for 1 ns;	

				
				A <= x"0c32";
				B <= x"0751";
					
				wait for 1 ns;	
				
				assert outMul  = x"5939" report "problem";
				
				wait for 1 ns;	
				
				
				A <= x"0022";
				B <= x"beaa";
					
				wait for 1 ns;	
				
				assert outMul  = x"1952" report "problem";
				
				wait for 1 ns;	
				
				A <= x"02c0";
				B <= x"0aaa";
					
				wait for 1 ns;	
				
				assert outMul  = x"1d53" report "problem";
				
				wait for 10 ns;		
						

			end process;
		--
	--
--
end t_behaviour;