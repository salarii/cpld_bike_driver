-- SIMULATION  ONLY

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
		type operation_stage is (Idle, Address, Index, Data_H, Data_L);
		type transaction_type is (Read_data, Write_data);

		constant slide : integer := 10;
		constant longerSlide : integer := 20;

		variable cnt : integer;
		
		variable shiftReg : unsigned(8 downto 0);
		variable seq_type : transaction_type;
		variable stage : operation_stage := Idle;		
begin
		
	
		if res = '1' then
			stage := Idle;
			shiftReg := to_unsigned(0,9);
			cnt := 0;
			bus_data_internal <= 'Z';
		elsif falling_edge(bus_data)  then
		
			if stage = Idle and (bus_clk = '1' or bus_clk = 'H' ) then
				cnt := 0;
				bus_data_internal <= 'Z';
				shiftReg  := (others=>'Z');
				stage := Address;
			elsif (bus_clk = '1' or bus_clk = 'H' ) then
				--stage := Idle;	
				--cnt := 0;
					
				--report integer'image(cnt);	
			end if; 
			--report integer'image(cnt);
		elsif rising_edge(bus_data)  then
			if (bus_clk = '1' or bus_clk = 'H' ) then
				stage := Idle;
			end if;
		elsif rising_edge(bus_clk)  then
			cnt := cnt + 1;
			if stage = Address then
				shiftReg(0) := bus_data;
			

			end if;

			if cnt = 9 and seq_type = Read_data then
 						
				assert bus_data = '0' report "Master no ack.";
					
			end if;
			
			shiftReg := shift_left(shiftReg, 1);
			
		 elsif falling_edge(bus_clk)  then
			
 				if seq_type = Read_data then
 						--bus_data_internal <= shiftReg(8);
 				elsif seq_type = Write_data then
 						bus_data_internal <= 'Z';
 				end  if;
				
				bus_data_internal <= 'Z';
				if cnt = 8 then 
					--report integer'image(cnt);
					if (bus_data = '1' or bus_data = 'H' ) then
						seq_type := Write_data; 
						bus_data_internal <= '0';
					elsif bus_data = '0' then
						shiftReg := "010101010";	
						seq_type := Read_data;
						bus_data_internal <= '0';
					end if;

				elsif cnt = 9 then
					--report integer'image(cnt);	

 					cnt :=  0;
 					
					if stage = Address then
						stage := Index;
					elsif stage = Index then
						stage := Data_H;					
					elsif stage = Data_H then
						stage := Data_L;
					end if;
					
				end if;
		 end if;	
	

end  process;

	
process(bus_data_internal)
begin
		bus_data <= bus_data_internal;
end  process;	



end behaviour;
