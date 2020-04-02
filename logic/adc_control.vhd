

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.interface_data.all;

entity adc_control is
	generic (CONSTANT period : integer := 1000000);

	port(
		clk : in  std_logic;
		res : in  std_logic;
		i2c : inout  transaction_data;
		
		o_uart : inout std_logic_vector(7 downto 0);
		busy_uart : in std_logic;
		en_uart : out std_logic;
		
		ready : in  std_logic
		);
end adc_control;

architecture behaviour of adc_control is
		signal data : std_logic_vector(15 downto 0) := x"ABCD";	
		signal address : unsigned(6 downto 0) := "1001000";
		signal enable_uart  : std_logic;
begin	


	process(clk)
		type state_type is (Setup, Index_Read,Standby, Cycle, Empty);
		
		constant config_register_h : unsigned(7 downto 0) := "11111111";
		constant config_register_l : unsigned(7 downto 0) := "00001111";
		constant short_break : integer := 10;
		variable state : state_type := Standby;
		variable cnt : integer := 0;		
		variable time : unsigned(15 downto 0) := x"1234";		
		variable val_cnt : integer  range 4 downto 0 := 0;
	begin
	
		if rising_edge(clk)  then
			if res = '0' then
				state := Standby;
				cnt :=0;
				val_cnt := 0;
			else

				if  state = Setup then
					i2c.reg_addr <= "11";
				
					data(15 downto 8) <= std_logic_vector(config_register_h);
					i2c.transaction <= Write;

					
					data(7 downto 0) <= std_logic_vector(config_register_l);
					
					if i2c.done = '1' then
						state := Index_Read;
						data <=  (others=>'Z');		
						cnt := short_break;	
					else 
						i2c.enable <= '1';
					end if;
					
					
				elsif state = Index_Read then

					if cnt = 0 then
						i2c.transaction <= Index;
						i2c.reg_addr <= "10";
						i2c.enable <= '1';
						
					end if;
					
					if i2c.done = '1' then
						cnt := short_break;
						state := Standby;
					end if;
				elsif state = Standby then		
						
					if cnt = 0 then
						data <= x"ABCD";
						state := Cycle;
						i2c.transaction <= Read;
						i2c.enable <= '1';
						i2c.reg_addr <= "11";
					
						if i2c.done = '1' then
							i2c.enable <= '0';				
						end if;
						
						if i2c.busy = '1' then
							i2c.enable <= '0';
	
						end if;
					
					
						cnt := period;
					end if;
					
					
					
				elsif state = Cycle then
					
					
					if busy_uart = '0' and enable_uart = '0' then
						
						case val_cnt is
						  when 0 =>   o_uart <= data(15 downto 8);
						  when 1 =>   o_uart <= data(7 downto 0);
						  when 2 =>   o_uart <= std_logic_vector(time(15 downto 8));
						  when 3 =>   o_uart <= std_logic_vector(time(7 downto 0));
						  when others => o_uart <=  (others=>'Z');
						end case;
					
						if val_cnt = 4 then
							val_cnt := 0;
							state := Standby;
						else
							val_cnt := val_cnt + 1;
							enable_uart <= '1';
						end if;
						
					else
						enable_uart <= '0';
							
					end if;			
				end if;	
				cnt := cnt - 1;	
					
				if i2c.busy = '1' then
						i2c.enable <= '0';

				end if;
			end if;

		end if;

	end process;
	
	process( data, address, enable_uart )
	begin
		en_uart <= enable_uart;
		i2c.data <= data;
		i2c.address <= std_logic_vector(address);	
	end process;

	
end behaviour;