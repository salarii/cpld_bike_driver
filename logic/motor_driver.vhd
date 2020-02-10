library IEEE;
use IEEE.std_logic_1164.all;



use work.interface_data.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity motor_driver is

	port(
		transaction : inout transaction_simp_data; 
		res : in std_logic;		
		clk : in std_logic;		
		speed : in std_logic_vector(7 downto 0);
		imp_cover : in std_logic_vector(7 downto 0);
		A_n : out std_logic;
		A_p : out std_logic;
		B_n : out std_logic;
		B_p : out std_logic;
		C_n : out std_logic;
		C_p : out std_logic
		);
end motor_driver;



architecture behaviour of motor_driver is

begin	


process(clk)


		constant period : integer := 10;
		
		constant size : integer := 8;
		variable cnt : integer;
		variable cntSmall : integer;
		variable speed_internal : unsigned(7 downto 0);	
		variable imp_cover_internal : unsigned(7 downto 0);


		variable A_p : std_logic;
		variable A_n : std_logic;
		variable B_p : std_logic;
		variable B_n : std_logic;
		variable C_p : std_logic;
		variable C_n : std_logic;


begin
		
 shift_right(speed_internal - imp_cover_internal );
	
		if res = '1' then
			state := Idle;
		elsif rising_edge(clk)  then
			
			cnt = cnt - 1;
			
			if  cnt = 0 then
				cnt := to_integer( speed );
			
				if A_p = '1' and B_n = '1' then
					C_n := '1';
					B_n := '0';
				elsif A_p = '1' and C_n = '1' then
					A_p = '0';
					B_p = '1';
				elsif B_p = '1' and C_n = '1' then
					C_n = '0';
					A_n = '1';
				elsif B_p = '1' and A_n = '1' then
					B_p = '0';
					C_p = '1';
				elsif C_p = '1' and A_n = '1' then
					A_n = '0';
					B_n = '1';
				elsif C_p = '1' and B_n = '1' then	
					C_p = '0';
					A_p = '1';		
				end if;
			
				case  &  A_n & B_p & B_n & C_p & C_n is
  when "1000" =>   Z <= A;
  when "10" =>   Z <= B;
  when others => Z <= 'X';
end case;
			
			
			
			end if;
			
				if transaction.enable = '1' and  state = Idle then
					bus_clk_internal := '0';
				
					state = Exchange;
					if transaction.transaction = write then
						shift_reg_mosi(size -1  downto  0) := unsigned(transaction.data);				
					
					end
					state := Data_out;
					
					
				end if;
						
				if cnt = 0 and  then
	 
					shift_reg_mosi := shift_right(shift_reg_rx, 1);
					shift_reg_miso := shift_right(shift_reg_tx, 1);
					
					if bus_clk_internal = '0' then
					
					
					end if;
					
					
				end if;
				
				if transaction.transaction = write then 
					miso_internal <= shift_reg_miso(0);
					
				end if;
				
				shift_reg_mosi(0) <= mosi_internal;

			else
				miso_internal <= 'Z';
			end if;
			
		end if;
	

end  process;





end behaviour;