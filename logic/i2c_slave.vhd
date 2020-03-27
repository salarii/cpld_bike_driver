-- SIMULATION  ONLY

use work.interface_data.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity i2c_slave is
	port(
		res : in std_logic;		
		bus_clk	: in  std_logic;
		bus_data : inout std_logic
		);
end i2c_slave;

architecture behaviour of i2c_slave is
	signal bus_data_internal : std_logic := 'Z';

begin	


process(bus_clk,bus_data)
		type transaction_type is (Read_data, Write_data);

		constant slide : integer := 10;
		constant longerSlide : integer := 20;

		constant size : integer := 9;
		variable cnt : integer;
		
		variable shiftReg : unsigned(size downto 0);
		variable stage : transaction_stage := Idle;
		variable seq_type : transaction_type;		
begin
		
	
		if res = '1' then
			stage := Idle;
			shiftReg := to_unsigned(0,size + 1);
			cnt := 0;
			bus_data_internal <= 'Z';
		elsif falling_edge(bus_data)  then
			if stage = Idle and (bus_clk = '1' or bus_clk = 'H' ) then
				cnt := 0;
				bus_data_internal <= 'Z';
				stage := Address;
			elsif (bus_clk = '1' or bus_clk = 'H' ) then
				stage := Idle;	
				cnt := 0;
					
				--report integer'image(cnt);	
			end if; 
			--report integer'image(cnt);
			
			
		elsif rising_edge(bus_clk)  then
			cnt := cnt + 1;
			if stage = Address then
				shiftReg(0) := bus_data;
			
				if  cnt = 8 then
					if bus_data_internal = '1' then
						seq_type := Read_data; 
					elsif bus_data_internal = '0' then
						seq_type := Write_data;
					end if;

				end if;
			end if;
			shiftReg := shift_left(shiftReg, 1);
			
		 elsif falling_edge(bus_clk)  then
			
				
				if cnt = 8 then 
					--report integer'image(cnt);
					bus_data_internal <= '0';
				elsif cnt = 9 then
					--report integer'image(cnt);	
 					bus_data_internal <= 'Z';
 					cnt :=  0;
			
				end if;
		 end if;	
	

end  process;

	
process(bus_data_internal)
begin
		bus_data <= bus_data_internal;
end  process;	



end behaviour;
