

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity mul is
	generic (CONSTANT IntPart : integer := 8;
   			 CONSTANT FracPart : integer := 8);

	port(
		A : in  unsigned(IntPart + FracPart - 1  downto 0);
		B : in  unsigned(IntPart + FracPart - 1  downto 0);

		outMul : out unsigned(IntPart + FracPart - 1  downto 0)
		);
end mul;

architecture behaviour of mul is
		signal tmp : unsigned (IntPart + FracPart - 1  downto 0) := to_unsigned(0,IntPart + FracPart); 
begin	


-- to_unsigned(m1Low, 7)


	process(A,B)
		
		variable shift : integer := 0;
		variable span : integer := IntPart + FracPart - 1;
		variable result : unsigned (IntPart + FracPart - 1  downto 0);
	begin
	
	
		tryThis : for i in 0 to span loop

			shift := FracPart -i;
			if FracPart -i < 0 then
				shift := -shift;
				
			end if;
			
			if i = 0 then
				if  B(i) = '1' then
						result := shift_right(unsigned(A),shift );
						
				else
						result := to_unsigned(0,result'length);
				end if;
					
			else
				
				if  B(i) = '1' then
					
					if FracPart -i < 0 then
							result := result+ shift_left(unsigned(A),shift);
					else
							result := result+ shift_right(unsigned(A),shift);
					end if;
						
						
					--report "idx:"	& integer'image( i );
					--report 	integer'image( to_integer(result) );
					
					--report 	integer'image( to_integer(result) );
						
				end if;
	
			end if;

		end loop;
		outMul <= result; 

	end process;

end behaviour;