

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.interface_data.all;

entity adc_control is
	generic (CONSTANT period : integer := 100);

	port(
		clk : in  std_logic;
		res : in  std_logic;
		i2c : inout  transaction_data;
		ready : in  std_logic
		);
end adc_control;

architecture behaviour of adc_control is
		signal data : std_logic_vector(15 downto 0);	
		signal address : unsigned(6 downto 0) := "1001000";
begin	


	process(clk)
		type state_type is (Setup, Active);
		
		constant config_register_h : unsigned(7 downto 0) := "11111111";
		constant config_register_l : unsigned(7 downto 0) := "00001111";
		variable state : state_type := Setup;
		variable cnt : integer;	

	begin
	
		if rising_edge(clk)  then
			if res = '0' then
				state := Setup;
				
				
			else

				if  state = Setup then
					data(15 downto 8) <= std_logic_vector(config_register_h);
					i2c.transaction <= Write;

					i2c.enable <= '1';
					data(7 downto 0) <= std_logic_vector(config_register_l);
					
					if i2c.busy = '1' then
						i2c.enable <= '0';
					elsif i2c.done = '1' then
						state := Active;
						data <=  (others=>'Z');
					end if;
				
					cnt := period;
				elsif state = Active then		
						
					cnt := cnt - 1;	
					if cnt = period then

					end if;
									
				end if;		
	
			end if;

		end if;

	end process;
	
	i2c.data <= data;
	i2c.address <= std_logic_vector(address);
	
end behaviour;