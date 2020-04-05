

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
		
		o_to_i2c : out type_to_i2c;
		i_from_i2c : in type_from_i2c;
		i2c_bus : inout std_logic_vector(7 downto 0);
		
		o_uart : inout std_logic_vector(7 downto 0);
		busy_uart : in std_logic;
		en_uart : out std_logic;
		
		ready : in  std_logic
		);
end adc_control;

architecture behaviour of adc_control is
		--signal data : std_logic_vector(15 downto 0) := x"ABCD";	
		--signal address : unsigned(6 downto 0) := "";
		signal enable_uart  : std_logic;
begin	

	o_to_i2c.address <= "1001000";
	process(clk)
		type state_type is (Setup, Index_Read,Standby, Cycle, Empty);
		
		type type_i2c_operations is ( i2c_index, i2c_data_H, i2c_data_L );
		
		constant config_register_h : unsigned(7 downto 0) := "11111111";
		constant config_register_l : unsigned(7 downto 0) := "00001111";
		constant short_break : integer := 50;
		variable cnt : integer := 0;		
		variable time : unsigned(15 downto 0) := x"1234";		
		variable val_cnt : integer  range 4 downto 0 := 0;
		variable state : state_type := Standby;
		variable i2c_state : type_i2c_operations;
		
	begin
	
		if rising_edge(clk)  then
			if res = '0' then
				state := Setup;
				cnt :=0;
				val_cnt := 0;
			else

				if  state = Setup then
					i2c_bus <= x"03";
				
					o_to_i2c.transaction <= Write;
					
					i2c_state :=  i2c_index;
					
					if i_from_i2c.done = '1' then
						if i2c_state = i2c_index then
						
							i2c_bus <= std_logic_vector(config_register_h);	
						elsif i2c_state = i2c_data_H then
						
							i2c_bus <= std_logic_vector(config_register_l);
					
							i2c_state := i2c_data_L;
						elsif i2c_state = i2c_data_L then
							state := Index_Read;
							i2c_bus <=  (others=>'Z');		
							cnt := short_break;	
						
						end if;
						
					elsif i_from_i2c.busy = '1' then
						o_to_i2c.continue <= '1';
						o_to_i2c.enable <= '0';
					else
						o_to_i2c.enable <= '1';
					end if;
					
					
				elsif state = Index_Read then

					if cnt = 0 then
						
						o_to_i2c.enable <= '1';
						
					end if;
					
					if i_from_i2c.done = '1' then
						cnt := short_break;
						state := Standby;
					end if;
				elsif state = Standby then		
						
					if cnt = 0 then
						i2c_bus <= x"AB";
						state := Cycle;
						o_to_i2c.transaction <= Read;
						o_to_i2c.enable <= '1';
					
						if i_from_i2c.done = '1' then
							o_to_i2c.enable <= '0';				
						end if;
						
						if i_from_i2c.busy = '1' then
							o_to_i2c.enable <= '0';
	
						end if;
					
					
						cnt := period;
					end if;
					
					
					
				elsif state = Cycle then
					
					
					if busy_uart = '0' and enable_uart = '0' then
						
						case val_cnt is
						  when 0 =>   o_uart <= i2c_bus;
						  when 1 =>   o_uart <= i2c_bus;
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
					
			end if;

		end if;

	end process;
	
	process(  enable_uart )
	begin
		en_uart <= enable_uart;
	end process;

	
end behaviour;