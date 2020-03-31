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
	signal debug : unsigned(7 downto 0);
begin	


process(bus_clk,bus_data)
		type operation_stage is (Idle, Address, Index, Data_H, Data_L);
		type transaction_type is (Read_data, Write_data);

		constant slide : integer := 10;
		constant longerSlide : integer := 20;

		variable cnt : integer;
		
		variable shiftReg : unsigned(7 downto 0);
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


			if cnt = 9 and seq_type = Read_data then
 						
				assert bus_data = '0' report "Master no ack.";
					
			end if;
			--report integer'image(1);
			shiftReg := shift_left(shiftReg, 1);
			
		 elsif falling_edge(bus_clk)  then
			

				
				if cnt = 8 and stage = Address then 

					if bus_data = '0'  then
						seq_type := Write_data; 
					elsif ( bus_data = '1' or bus_data = 'H' ) then	
						seq_type := Read_data;
						bus_data_internal <= '0';
					end if;

				elsif cnt = 9 then
					--report integer'image(cnt);	

 					cnt :=  0;
 					if seq_type = Read_data then

						if stage = Address then
								
							shiftReg := "10101010";
							stage := Data_H;					
						elsif stage = Data_H then
							shiftReg := "01010101";
							stage := Data_L;
						end if;
					elsif seq_type = Write_data then
						if stage = Address then
							stage := Index;
						elsif stage = Index then		
							stage := Data_H;					
						elsif stage = Data_H then
							stage := Data_L;
						elsif stage = Data_L then	
							stage := Idle;
						end if;	
					end if;
					
				end if;
				
 				if seq_type = Read_data and ( stage = Data_H or stage = Data_L ) then
					if cnt = 8 then
					 	bus_data_internal <= 'Z';
					else
	 					if shiftReg(7) = '1'  then
							bus_data_internal <= 'Z';
						else
							bus_data_internal <= '0';					
						end if;					
					end if;
 				elsif seq_type = Write_data then
 					if  cnt = 8  then
						bus_data_internal <= '0';
					else
 						bus_data_internal <= 'Z';
 					end if;
 				end  if;
				
				
				
		 end if;	
		debug <= shiftReg;

end  process;

	
process(bus_data_internal)
begin
		
		bus_data <= bus_data_internal;
end  process;	



end behaviour;
