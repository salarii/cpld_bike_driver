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
			res : in std_logic;		
			clk : in std_logic;	
			
			i_data : in std_logic_vector(7 downto 0);
			i_enable : in std_logic;
			i_rx : in std_logic;	
			
			o_data : out std_logic_vector(7 downto 0);	
			o_error : out std_logic;
			o_received : out std_logic;
			o_busy	: out std_logic;
			o_tx	: out  std_logic
		);
end uart;

architecture behaviour of uart is
	signal tx_internal : std_logic := '1';
	signal  received_internal : std_logic := '0';
	signal  busy_internal_tx : std_logic := '0'; 
	signal  busy_internal_rx : std_logic := '0';
	
	
	signal bit_cnt_debug  : unsigned(3 downto 0);	
	signal cycle_cnt_debug  : unsigned(3 downto 0);
	signal shift_reg_debug  : unsigned(7 downto 0);
begin	


process(clk)



		constant parity_bit : integer := 9;
		constant period : integer := freq/bound;
		constant half : integer := period/2;
		
		variable cnt_tx : integer  range period downto 0;
		variable cnt_rx : integer  range period + half downto 0;
		variable seq : integer  range 15 downto 0;

		variable bit_cnt_rx : integer  range 10 downto 0;
		variable bit_cnt_tx : integer  range 11 downto 0;
				
		variable shift_reg_tx: unsigned(7 downto 0);
		variable shift_reg_rx: unsigned(7 downto 0);
		
		variable  parity : std_logic;

begin
		

		
		if rising_edge(clk)  then
			
			bit_cnt_debug  <= to_unsigned(bit_cnt_rx, bit_cnt_debug'length); 
			cycle_cnt_debug  <= to_unsigned(cnt_rx, cycle_cnt_debug'length);
			shift_reg_debug <= shift_reg_rx;
			if res = '0' then
				busy_internal_tx <= '0';
				busy_internal_rx <= '0';
				tx_internal <= '1';
				received_internal <= '0';
				bit_cnt_tx := 0;
				bit_cnt_rx := 0;
				o_error <= '0';
			else
				if  received_internal = '1' then
					received_internal <= '0';
				end if;
				
				if i_enable = '1' or busy_internal_tx = '1' then	
				
					
					if  busy_internal_tx = '0' then
						busy_internal_tx <= '1';
						parity := parity_check(i_data,8);
			
						cnt_tx := period-1;
						shift_reg_tx(0) := '0'; 
						shift_reg_tx(7  downto  0) := unsigned(i_data);				
						tx_internal <= '0';	
						bit_cnt_tx := 0;
					elsif cnt_tx = 0  then 
						if bit_cnt_tx = 8  then
							tx_internal <= parity;
							--o_data <= std_logic_vector(shift_reg(7 downto 0));
						elsif bit_cnt_tx = 9  then
							tx_internal <= '1';
						elsif bit_cnt_tx = 10  then
							busy_internal_tx <= '0';
						else
							tx_internal <= shift_reg_tx(0);
						end if;
								
						shift_reg_tx := shift_right(shift_reg_tx, 1);
						cnt_tx := period-1;
						bit_cnt_tx := bit_cnt_tx + 1;
						
					else
						cnt_tx := cnt_tx - 1;
					end if;	
					
					
				end if;
				
				if i_rx = '0' or busy_internal_rx = '1' then 
					
					if  busy_internal_rx = '0' then
						busy_internal_rx <= '1';
						bit_cnt_rx := 0;
						cnt_rx := period + half-1;
						shift_reg_rx := (others => '0' );
						
					elsif cnt_rx = 0 then
						if bit_cnt_rx = 8  then
							parity := parity_check(std_logic_vector(shift_reg_rx(7 downto 0)),8); 
							
							if parity /= i_rx then
								o_error <= '1';
							else
								o_error <= '0';
							end if;
						elsif bit_cnt_rx = 9  then
							o_error <= not i_rx;
							bit_cnt_rx:= 0;
							busy_internal_rx <= '0';
							received_internal <= '1';
							o_data <= std_logic_vector(shift_reg_rx);
						else

							shift_reg_rx := shift_right(shift_reg_rx, 1);
							shift_reg_rx(7) := i_rx;
						
						end if;
						cnt_rx := period-1;	
						bit_cnt_rx :=  bit_cnt_rx +1;	
					else
						cnt_rx := cnt_rx - 1;
					end if;
				end if;	
				
			end if;
				
		end if;
	

end  process;

process(tx_internal,busy_internal_tx,received_internal)
begin
	o_tx <= tx_internal;
	o_busy <= busy_internal_tx;
	o_received <= received_internal;
end process;



end behaviour;
