
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity comunication is
	generic (delay : integer);
	port(
		data : inout std_logic_vector(7 downto 0);
		enable : out std_logic;		
		busy : in std_logic;
		res : in std_logic;		
		clk : in std_logic
		);
end comunication;

architecture behaviour of comunication is
	signal data_internal : std_logic_vector(7 downto 0);
begin	


process(clk)

	variable cnt : integer := delay;
 	
begin
		
		
		if rising_edge(clk)  then
			if res = '0' then
			cnt := delay;
			else
				cnt := cnt - 1;
			
			
				if cnt = 0 and busy /= '1' then	
				
						if data_internal = x"41"  then
							data_internal <= x"42";
						
						else
							data_internal <= x"41";
						
						end if;
						
						data <= data_internal;
						enable <= '1';
				
					
					
				elsif busy = '1' then
					cnt:= delay;
					enable <= '0';
					data <= "ZZZZZZZZ";
				end if;
			end if;
		end if;
	

end  process;

	



end behaviour;
