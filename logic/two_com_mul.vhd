


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity two_com_mul is
	generic (CONSTANT IntPart : integer := 4;
   			 CONSTANT FracPart : integer := 4);

	port(
		A : in  signed(IntPart + FracPart - 1  downto 0);
		B : in  signed(IntPart + FracPart - 1  downto 0);

		outMul : out signed(IntPart + FracPart - 1  downto 0)
		);
end two_com_mul;

architecture behaviour of two_com_mul is
		signal tmp : signed (IntPart + FracPart - 1  downto 0) := to_signed(0,IntPart + FracPart); 
begin	


	process(A,B)
		
		variable shift : integer := 0;
		variable span : integer := IntPart + FracPart - 1;
		variable result : signed (IntPart + FracPart - 1  downto 0);
variable tmp : signed (IntPart + FracPart - 1  downto 0);
	begin
	
	
		sum : for i in 0 to span loop

			shift := FracPart -i;
			if FracPart -i < 0 then
				shift := -shift;
				
			end if;
			tmp := (not A + 1);
			if i = 0 then
				if  B(i) = '1' then
					if A(IntPart + FracPart - 1) = '1' then
					
						result := -shift_right(tmp ,shift);
						tmp  := -shift_right(tmp ,shift);	
					else
						result := shift_right(signed(A),shift );
					end if;						
				else
					result := to_signed(0,result'length);
				end if;
			
			else
				
				if  B(i) = '1' then
					if A(IntPart + FracPart - 1) = '1' then
						if FracPart -i < 0 then
							tmp  := -shift_left( tmp,shift);
						else
							tmp  := -shift_right( tmp,shift);						
						end if;		
	
	
					else
						if FracPart -i < 0 then
							tmp := shift_left(signed(A),shift);
	
						else
							tmp := shift_right(signed(A),shift);
						end if;
					end if;
	
          if i = IntPart + FracPart - 1  then
              result  := result-tmp;
          else
              result  := result+tmp;	
          end if;
  
						
				end if;
	
			end if;

		end loop;
		outMul <= result; 

	end process;

end behaviour;