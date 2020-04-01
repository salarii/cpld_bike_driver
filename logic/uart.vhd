library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


package auxiliary is

function parity_check(data: in std_logic_vector(7 downto 0); size : in integer) return std_logic;

end package;

package  body  auxiliary is

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

end  auxiliary;


use work.auxiliary.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity uart is
	generic ( 
		freq : integer;
		bound : integer
		);
		
	port(
		data : inout std_logic_vector(7 downto 0);
		enable : in std_logic;		
		res : in std_logic;		
		clk : in std_logic;	
		rx : in std_logic;		
		error : out std_logic;
		busy	: out std_logic;
		tx	: out  std_logic
		);
end uart;

architecture behaviour of uart is
	signal tx_internal : std_logic;
	signal  busy_internal : std_logic := '0'; 
begin	


process(clk)

		type state_type is (Idle, Data_in, Data_out);
		--constant clk_reduction : integer := 10;

		constant parity_bit : integer := 9;
		constant period : integer := freq/bound;
		constant half : integer := period/2;
		
		constant size : integer := 10;
		variable cnt : integer;
		variable seq : integer;
		variable shift_reg: unsigned(size - 1 downto 0);
		variable  state : state_type := Idle;
		variable  parity : std_logic;

begin
		
		

		if rising_edge(clk)  then
			if res = '0' then
				state := Idle;
				busy_internal <= '0';
			else
				cnt := cnt - 1;
			
			
				if enable = '1' or busy_internal = '1' then	
				
					busy_internal <= '1';
					
					if enable = '1' and  state = Idle then
					
						parity := parity_check(data,8);
			
					
						seq := 0;
						cnt := period;
						state := Data_out;
						shift_reg(0) := '0'; 
						shift_reg(size -2  downto  1) := unsigned(data);				
						
						shift_reg(size -1 ) := parity;
					end if;
					
					if cnt = 0  then 
						if state = Data_out then
							
							
							shift_reg(size -1) := '1';
							if seq = size + 3 then
								busy_internal <= '0';
								state := Idle;
							end if;
							shift_reg := shift_right(shift_reg, 1);
						elsif state = Data_in then
							
							if seq = size - 2 then
							
								parity := parity_check(std_logic_vector(shift_reg(size - 1 downto 2)),8); 
								if rx = parity then
								
								
								end if;
								busy_internal <= '0';
								state := Idle;
							else
								shift_reg := shift_right(shift_reg, 1);
							end if;					
						
						end if;
						
						cnt := period;	
						seq :=  seq +1;

					end if;
					
					if state = Data_out then
						tx_internal <= shift_reg(0);
					elsif state = Data_in then
						shift_reg(size - 1) := rx;
					end if;
					
				else
					tx_internal <= '1';
				end if;
				
				if state = Data_in then
					data <= std_logic_vector(shift_reg(size - 2 downto 1));
				else
					data <= "ZZZZZZZZ";
				end if;

				if rx = '0' and state = Idle then
					
						seq := 0;
						state := Data_in;
						cnt := period + half;
						busy_internal <= '1';
				end if;
			end if;

		end if;
	

end  process;

process(tx_internal,busy_internal)
begin
	tx <= tx_internal;
	busy <= busy_internal;
end process;



end behaviour;
