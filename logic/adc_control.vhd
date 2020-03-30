

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
		
		o_uart : out unsigned(7 downto 0);
		busy_uart : in std_logic;
		en_uart : out std_logic;
		
		ready : in  std_logic
		);
end adc_control;

architecture behaviour of adc_control is
		signal data : std_logic_vector(15 downto 0);	
		signal address : unsigned(6 downto 0) := "1001000";
		signal enable_uart  : std_logic;
		signal out_uart : unsigned(7 downto 0);
begin	


	process(clk)
		type state_type is (Setup, Index,Standby, Cycle, Empty);
		
		constant config_register_h : unsigned(7 downto 0) := "11111111";
		constant config_register_l : unsigned(7 downto 0) := "00001111";
		variable state : state_type := Setup;
		variable cnt : integer := 0;		
		variable time : unsigned(15 downto 0);		
		variable val_cnt : integer  range 3 downto 0 := 0;
	begin
	
		if rising_edge(clk)  then
			if res = '0' then
				state := Setup;
				
				
			else

				if  state = Setup then
					i2c.reg_addr <= "11";
				
					data(15 downto 8) <= std_logic_vector(config_register_h);
					i2c.transaction <= Write;

					i2c.enable <= '1';
					data(7 downto 0) <= std_logic_vector(config_register_l);
					
					if i2c.done = '1' then
						state := Empty;
						data <=  (others=>'Z');	
						i2c.enable <= '0';				
					end if;
					
					if i2c.busy = '1' then
						i2c.enable <= '0';

					end if;
				
					cnt := period;
				elsif state = Standby then		
						
					if cnt = 0 then
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
					
					cnt := cnt - 1;	
					
				elsif state = Cycle then
					
					
					if busy_uart = '0' then
						
						case val_cnt is
						  when 0 =>   out_uart <= unsigned(data(15 downto 8));
						  when 1 =>   out_uart <= unsigned(data(7 downto 0));
						  when 2 =>   out_uart <= time(15 downto 8);
						  when 3 =>   out_uart <= time(7 downto 0);
						  when others => out_uart <=  (others=>'0');
						end case;
					
						if val_cnt = 3 then
							val_cnt := 0;
						else
							enable_uart <= '1';
							val_cnt := val_cnt + 1;
						end if;
					else
						enable_uart <= '0';
							
					end if;			
				end if;		

			end if;

		end if;

	end process;
	
	process(out_uart, data, address, enable_uart )
	begin
		en_uart <= enable_uart;
		o_uart <= out_uart;
		i2c.data <= data;
		i2c.address <= std_logic_vector(address);	
	end process;

	
end behaviour;