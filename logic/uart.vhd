

use work.interface_data.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
	port(
		transaction : inout transaction_simp_data; 
		res : in std_logic;		
		clk : in std_logic;	
		rx : in std_logic;		
		tx	: out  std_logic
		);
end uart;

architecture behaviour of uart is
	signal rx_internal	: std_logic;
	signal tx_internal : std_logic;
	
begin	


process(clk)

		type state_type is (Idle, Data_in, Data_out);
		--constant clk_reduction : integer := 10;

		constant parity_bit : integer := 9;
		constant period : integer := 10;
		constant half : integer := period/2;
		
		constant size : integer := 9;
		variable cnt : integer;
		variable seq : integer;
		variable shiftReg : unsigned(size - 1 downto 0);	
		variable  state : state_type := Idle;
		variable  parity : std_logic;
		variable  busy_internal : std_logic; 
begin
		

		parity_check : for i in 0 to size - 2 loop
						
			if i = 0  then
				parity := std_logic(shiftReg(i));
			else
				parity := std_logic(shiftReg(i))  xor parity;
				
			end	if;
				
		end loop;
	
		if res = '1' then
			state := Idle;
		elsif rising_edge(clk)  then
			if transaction.enable = '1' or busy_internal = '1' then	
				if transaction.enable = '1' and  state = Idle then
					state := Data_out;
					
					shiftReg(size -1) := '0'; 
					shiftReg(size -2  downto  0) := unsigned(transaction.data);				
					
				end if;
						
				if rx = '0' and state = Idle then
	
					seq := 0;
					state := Data_in;
					cnt := period + half;
					
				end if;
				cnt := cnt - 1;
				
				if state = Data_in then
					
					
					if cnt = 0 then
						if seq = parity_bit then
						
						else
							shiftReg := shift_right(shiftReg, 1);
						end if;
						cnt := period;
						seq := seq + 1;			
					end if;
					
				end if;
							
			    if transaction.transaction = write then 
					tx_internal <= shiftReg(size-1);	
			    else 
			    	shiftReg(size - 1 ) := rx_internal;
						
				end if;
				
			else
				tx_internal <= 'Z';
			end if;
			
		end if;
	

end  process;





end behaviour;
