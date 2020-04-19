


--use work.functions.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity trigger is
	generic ( 
		CONSTANT time_divider : integer
		);
		
	port(
			res : in std_logic;		
			clk : in std_logic;	
			i_enable : in std_logic;
			i_stop : in std_logic;
			i_period : in unsigned(15 downto 0);
			i_pulse : in unsigned(15 downto 0);
			
			o_trigger : out std_logic;
			o_current_time : out unsigned(15 downto 0)
		);
end trigger;

architecture behaviour of trigger is
	signal trigger_internal : std_logic := '0';
	signal  debug : std_logic;
begin	


process(clk)
		variable time_cnt : integer  range 65535 downto 0 := 0;
		variable time_div : integer  range time_divider downto 0 := time_divider;		
		variable activated : std_logic := '0';
			
		
		variable period_cnt : integer  range 65535 downto 0;
		variable pulse_cnt : integer  range 65535 downto 0;
begin
		

		
		if rising_edge(clk)  then
			
			--debug <= activated;
			if res = '0' then
				trigger_internal <= '0';
				time_cnt := 0;
				time_div := time_divider-1;
				activated := '0';
				o_current_time <= (others => '0');			
			else
			
				if time_div = 0 then
						time_div := time_divider;
						o_current_time <= to_unsigned(time_cnt, o_current_time'length);
						time_cnt :=	time_cnt + 1;
				else
						time_div := time_div - 1;
				end if;
			
				if i_stop = '1' then	
					activated := '0';
					trigger_internal <= '0';			
				elsif i_enable = '1' or activated = '1' then	
					if activated = '0' then

						period_cnt := to_integer(i_period);
						pulse_cnt := to_integer(i_pulse);
						activated := '1';
						time_cnt := 0;
						time_div := time_divider-1;
						o_current_time <= (others => '0');						
					end if;

					if 	period_cnt = 0 then
						period_cnt := to_integer(i_period)-1;
						pulse_cnt := to_integer(i_pulse)-1;
						trigger_internal <= '1';
					else
						if pulse_cnt = 0 then
							trigger_internal <= '0';
						else
							pulse_cnt := pulse_cnt - 1;
						end if;
					
						period_cnt := period_cnt - 1;
					end if;

				end if;	
				
			end if;
				
		end if;
	

end  process;

process(trigger_internal)

begin
	o_trigger <= trigger_internal;
end process;



end behaviour;
