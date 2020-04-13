

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity div is
	generic (CONSTANT IntPart : integer := 8;
   			 CONSTANT FracPart : integer := 8);

	port(
		res : in std_logic;
		clk : in std_logic;
		enable : in std_logic;
		divisor	: in  unsigned(IntPart + FracPart - 1  downto 0);
		divident : in  unsigned(IntPart + FracPart - 1  downto 0);
		quotient : out unsigned(IntPart + FracPart - 1  downto 0)
		);
end div;

architecture behaviour of div is
		signal reciprocal : unsigned (IntPart + FracPart - 1  downto 0); 
		signal divTmp : unsigned (IntPart + FracPart - 1  downto 0);
		signal addConst : unsigned (IntPart + FracPart - 1  downto 0); 


		signal stageOne : unsigned (IntPart + FracPart - 1  downto 0);
		signal stageTwo : unsigned (IntPart + FracPart - 1  downto 0);
		signal stageThree : unsigned (IntPart + FracPart - 1  downto 0);


		signal outStageIn : unsigned (IntPart + FracPart - 1  downto 0);
		signal outStageInTwo : unsigned (IntPart + FracPart - 1  downto 0);
		signal compOut : unsigned (IntPart + FracPart - 1  downto 0);

		component mul
			generic (CONSTANT IntPart : integer;
		   			 CONSTANT FracPart : integer );
		port  (
			A : in  unsigned(IntPart + FracPart - 1  downto 0);
			B : in  unsigned(IntPart + FracPart - 1  downto 0);
	
			outMul : out unsigned(IntPart + FracPart - 1  downto 0)
			);
		end component;

begin	


		module_mul1: mul
		generic map(
			 IntPart => 2,
			 FracPart => IntPart + FracPart - 2
		 )
		port map (
			A => reciprocal,
			B => divTmp,
			outMul => stageOne);

		module_mul2: mul
		generic map(
			 IntPart => 2,
			 FracPart => IntPart + FracPart - 2
		 )
		port map (
			A => stageTwo,
			B => reciprocal,
			outMul => stageThree);


		module_outStage: mul
		generic map(
			 IntPart => IntPart,
			 FracPart => FracPart
		 )
		port map (
			A => outStageIn,
			B => outStageInTwo,
			outMul => compOut);

	outStageInTwo <= unsigned(divident);

	process(clk)
	
		variable iteration : integer range 15 downto 0 := 6;
		variable outShift : integer range 15 downto 0;
		variable divHigh : integer range 15 downto 0 := 0;
		variable decPos : integer range 15 downto 0 := 0;
		variable fracRange : integer range 15 downto 0 := IntPart + FracPart;
	begin
	
		divHighFind : for i in 0 to fracRange - 1 loop
					
			if divisor(i) = '1' then  
			      	
			         divHigh := fracRange-i - 3;
					 decPos := i;
			end if;
		end loop;
	
		outShift :=  decPos  - FracPart;
		
		outStageIn <= shift_right(unsigned(  reciprocal), IntPart - 1);
		

		if outShift < 0 then
			quotient <= shift_left(unsigned(  compOut), -outShift);
		else
			quotient <= shift_right(unsigned(  compOut), outShift);
		end if;
		
		
		if  res = '0' then
			iteration := 12;
			divTmp <= to_unsigned(0,divTmp'length);
			reciprocal <= shift_left(to_unsigned(1,divTmp'length), fracRange - 2);
				
		elsif  clk'event  and clk = '1' then
		
			if enable = '1' then 
				divTmp <= unsigned(  divisor);
				if divHigh < 0 then
					divTmp <= shift_right(unsigned(  divisor), -divHigh);
					
					
				else
					divTmp <= shift_left(unsigned(  divisor), divHigh);				
					
				end if;
				
				addConst <= shift_left(to_unsigned(1,addConst'length), fracRange - 1);
				reciprocal <= shift_left(to_unsigned(1,divTmp'length), fracRange - 2);
				
				
				iteration := 12;
			else
			
			
				if iteration > 0 then
					reciprocal <= stageThree;	
					iteration := iteration - 1; 
				end if;
			end if;
			

		end if;
		
			

	end process;

	process(stageOne)
	begin
		stageTwo <= addConst - stageOne;
	end process;

end behaviour;

