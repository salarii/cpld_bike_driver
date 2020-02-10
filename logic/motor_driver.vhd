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
		A_n_out : out std_logic;
		A_p_out : out std_logic;
		B_n_out : out std_logic;
		B_p_out : out std_logic;
		C_n_out : out std_logic;
		C_p_out : out std_logic
		);
end motor_driver;



architecture behaviour of motor_driver is
		signal A_n : std_logic;
		signal B_n : std_logic;
		signal C_n : std_logic;
		signal A_p : std_logic;
		signal B_p : std_logic;
		signal C_p : std_logic;
		signal allow : std_logic;
		
begin	


process(clk)


		constant period : integer := 10;
		
		constant size : integer := 8;
		variable cnt : integer;
		variable cntSmall : integer;
		variable speed_internal : unsigned(7 downto 0);	
		variable imp_cover_internal : unsigned(7 downto 0);




begin
		

	
		if res = '1' then
			state := Idle;
		elsif rising_edge(clk)  then
			
			cnt = cnt - 1;
			cntSmall = cntSmall -1;
			
			
			if  cnt = 0 then
				allow := 0;
				cnt := to_integer( speed );
				cntSmall := shift_right(speed_internal - imp_cover_internal,1 );
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
			
				
			end if;
			
			if cntSmall = '0'  then
				if  allow = '0' then
					allow = '1';
					cntSmall := imp_cover_internal;
				elsif allow = '1' then
					allow = '0';					
					cntSmall :=cnt + 1;
				end if;
			end  if;
			

			
		end if;
	

end  process;


process(A_n,B_n,C_n,A_p,B_p,C_p,allow)
begin
		A_n_out <= A_n;
		B_n_out <= B_n;
		C_n_out <= C_n; 
		A_p_out <= A_p and allow;
		B_p_out <= B_p and allow;
		C_p_out <= C_p and allow;


end  process;

end behaviour;