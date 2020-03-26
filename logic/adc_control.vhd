

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity adc_control is
	generic (CONSTANT period : integer := 1000);

	port(
		clk : in  std_logic;
		res : in  std_logic;
		i2c : inout  std_logic_vector(7  downto 0);
		ready : in  std_logic;
		write : out std_logic
		);
end adc_control;

architecture behaviour of adc_control is
		signal data : std_logic_vector(7 downto 0);	
		signal val : std_logic_vector(15 downto 0);	
begin	


-- to_unsigned(m1Low, 7)


	process(clk)
		type state_type is (Setup1, Setup2, Active);
		constant address : std_logic_vector(6 downto 0) := "1001000";
		constant config_register_h : std_logic_vector(7 downto 0) := "11111111";
		constant config_register_l : std_logic_vector(7 downto 0) := "00001111";
		variable  state : state_type := Setup1;
		variable cnt : integer;	

	begin
	
		if rising_edge(clk)  then
			if res = '0' then
				state := Setup1;
				
				
			else

				if  state = Setup1 then
					data <= config_register_h;
					if ready = '1' then
						state := Setup2;
					end if;
						
				elsif state = Setup2 then
					data <= config_register_l;
					if ready = '1' then
						state := Active;
						data <=  (others=>'Z');
					end if;
				
					cnt := period;
				elsif state = Active then	
					val(7 downto 0) <= data;	
						
					cnt := cnt - 1;	
					if cnt = period/2 then
						
					elsif cnt = 0 then
					end
									
				end if;		
	
			end if;

		end if;

	end process;
		
		
	i2c <= data;
end behaviour;