


--use work.functions.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity trigger is
		
	port(
			res : in std_logic;		
			clk : in std_logic;	
			i_enable : in std_logic;
			i_pulse : in unsigned(7 downto 0);
			
			o_trigger : out std_logic
		);
end trigger;

architecture behaviour of trigger is
	signal trigger_internal : std_logic := '0';
begin	


process(clk)
		constant period : unsigned(13 downto 0) := "11111111000000";
		variable period_cnt : unsigned(13 downto 0) := period;
		variable pulse_cnt : unsigned(13 downto 0) := (others => '0');
begin
		

		
		if rising_edge(clk)  then
			
			--debug <= activated;
			if res = '0' then
				trigger_internal <= '0';
				period_cnt:= (others => '0');		
			else

						
				if i_enable = '1' then	


					if 	period_cnt = 0 then
						period_cnt := period;
						if i_pulse > 0 then
							pulse_cnt(13 downto 6) := i_pulse;
							trigger_internal <= '1';
						else
							pulse_cnt := (others => '0');
						end if;
						
					else
						if pulse_cnt = 0 then
							trigger_internal <= '0';
						else
							pulse_cnt := pulse_cnt - 1;
						end if;
					
						period_cnt := period_cnt - 1;
					end if;
				else
					period_cnt:= (others => '0');
					trigger_internal <= '0';	
				end if;	
				
			end if;
				
		end if;
	

end  process;

process(trigger_internal)

begin
	o_trigger <= trigger_internal;
end process;



end behaviour;
