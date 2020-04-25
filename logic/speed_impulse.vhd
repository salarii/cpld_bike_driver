


--use work.functions.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity speed_impulse is
	generic ( 
		CONSTANT time_period : integer
		);
		
	port(
			res : in std_logic;		
			clk : in std_logic;	
			i_enable : in std_logic;
			i_impulse : in std_logic;
			
			o_speed : out unsigned(7 downto 0)
		);
		
end speed_impulse;

architecture behaviour of speed_impulse is
	signal speed : unsigned(7 downto 0) := (others => '0');
begin	

process(clk)
		variable count_imp : boolean := True; 
		variable cnt_cycle : integer  range 524287 downto 0 := 0;
		variable cnt_pulses : integer  range 255 downto 0 := 0;
begin
		

		
		if rising_edge(clk)  then
			
			--debug <= activated;
			if res = '0' then
				count_imp := True; 
				cnt_cycle := 0;
				cnt_pulses := 0;
				speed <= (others => '0');
			else
			
				
				if i_enable = '1' then
					cnt_cycle := 0;
					cnt_pulses := 0;
					count_imp := True;
					speed <= (others => '0');				
				else	
					if i_impulse = '1' and count_imp = True then
						cnt_pulses := cnt_pulses + 1;
						count_imp := False;
					elsif i_impulse = '0' then
						count_imp := True;
					end if;
					

					if 	cnt_cycle = time_period - 1 then
						speed <= to_unsigned(cnt_pulses, speed'length );
						cnt_pulses := 0;
						cnt_cycle := 0; 
					else
						
					
						cnt_cycle := cnt_cycle + 1;
					end if;

				end if;	
				
			end if;
				
		end if;
	

end  process;

process(speed)

begin
	o_speed <= speed;
end process;



end behaviour;
