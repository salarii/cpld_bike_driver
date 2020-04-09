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
			i_data : in std_logic_vector(7 downto 0);
			enable : in std_logic;
			res : in std_logic;		
			clk : in std_logic;	
			rx : in std_logic;	
			
			o_data : out std_logic_vector(7 downto 0);	
			error : out std_logic;
			received : out std_logic;
			busy	: out std_logic;
			tx	: out  std_logic
		);
end uart;

architecture behaviour of uart is
	signal tx_internal : std_logic;
	signal  busy_internal_tx : std_logic := '0'; 
	signal  busy_internal_rx : std_logic := '0';
	
	
	signal bit_cnt_debug  : unsigned(3 downto 0);	
	signal cycle_cnt_debug  : unsigned(3 downto 0);
begin	


process(clk)



		constant parity_bit : integer := 9;
		constant period : integer := freq/bound;
		constant half : integer := period/2;
		
		variable cnt_tx : integer  range period downto 0;
		variable cnt_rx : integer  range period downto 0;
		variable seq : integer  range 15 downto 0;

		variable bit_cnt_rx : integer  range 9 downto 0;
		variable bit_cnt_tx : integer  range 9 downto 0;
				
		variable shift_reg_tx: unsigned(7 downto 0);
		variable shift_reg_rx: unsigned(7 downto 0);
		
		variable  parity : std_logic;

begin
		

		
		if rising_edge(clk)  then
			
			bit_cnt_debug  <= to_unsigned(bit_cnt_tx, bit_cnt_debug'length); 
			cycle_cnt_debug  <= to_unsigned(cnt_tx, cycle_cnt_debug'length);
			
			if res = '0' then
				busy_internal_tx <= '0';
				bit_cnt_tx := 0;
				bit_cnt_rx := 0;
			else
			
				if enable = '1' or busy_internal_tx = '1' then	
				
					busy_internal_tx <= '1';
					if  bit_cnt_tx = 0 then

						parity := parity_check(i_data,8);
			
						cnt_tx := period;
						shift_reg_tx(0) := '0'; 
						shift_reg_tx(7  downto  0) := unsigned(i_data);				
						
					end if;
			
					
					if cnt_tx = 0  then 
						if bit_cnt_tx = 10  then
							busy_internal_tx <= '0';
							--o_data <= std_logic_vector(shift_reg(7 downto 0));
						end if;
						
						
						tx_internal <= shift_reg_tx(0);	
						shift_reg_tx := shift_right(shift_reg_tx, 1);
					end if;	
				end if;
				
				if rx = '0' and busy_internal_rx = '0' then 
					busy_internal_rx <= '1';
					if  bit_cnt_rx = 0 then
			
						cnt_rx := period + half;
					end if;
					
					
					if cnt_rx = 0 then
						if bit_cnt_rx = 10  then
							parity := parity_check(std_logic_vector(shift_reg_rx(7 downto 0)),8); 
							
							if parity /= rx then
								error <= '1';
							else
								error <= '0';
							end if;
							
						end if;
						
						shift_reg_rx := shift_right(shift_reg_rx, 1);
						
						
						
						cnt_rx := period;	
						bit_cnt_rx :=  bit_cnt_rx +1;
						--shift_right(7) := rx;
					end if;
				end if;	
				
			end if;
				
		end if;
	

end  process;

process(tx_internal,busy_internal_tx)
begin
	tx <= tx_internal;
	busy <= busy_internal_tx;
end process;



end behaviour;
