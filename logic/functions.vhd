library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


package functions is

function parity_check(data: in std_logic_vector(7 downto 0); size : in integer) return std_logic;

end package;

package  body  functions is

function parity_check(data: in std_logic_vector(7 downto 0); size : in integer) return std_logic is
	variable  parity : std_logic;
begin
	for i in 0 to size -1 loop
										
		if i = 0  then
			parity := std_logic(data(i));
		else
			parity := std_logic(data(i))  xor parity;	
		end	if;
								
	end loop;
	
	return parity;
end parity_check;




end  functions;