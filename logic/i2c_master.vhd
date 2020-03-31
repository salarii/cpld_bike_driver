

use work.interface_data.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity i2c_master is
	port(
		transaction : inout transaction_data; 
		res : in std_logic;		
		clk : in std_logic;		
		bus_clk	: inout  std_logic;
		bus_data : inout std_logic
		);
end i2c_master;

architecture behaviour of i2c_master is
	signal busy_internal	: std_logic;
	signal bus_clk_internal	: std_logic;
	signal bus_data_internal : std_logic;
	signal debug : unsigned(8 downto 0);
	signal data_out : signed(15 downto 0);
	signal done : std_logic;
begin	


process(clk)
		type transaction_seq is (Inactive, DataActive, Active);

		constant slide : integer := 10;
		constant clk_reduction : integer := 10;
		constant longerSlide : integer := 20;
		constant clk_half : integer := clk_reduction/2;
		constant size : integer := 8;
		variable cnt : integer;
		
		variable shiftReg : unsigned(size downto 0);
		variable stage : transaction_stage := Idle;
		variable seq : transaction_seq := Inactive;		
begin
		
		debug <= shiftReg;
		if res = '1' then
			stage := Idle;
			shiftReg := to_unsigned(0,size + 1);
			seq := Inactive;
		elsif rising_edge(clk)  then
		
			--report "cnt:  " & integer'image(cnt);
			
			if done  = '1' then
				done <= '0';
			end if;	
			
			if transaction.enable = '1' or busy_internal = '1' then
				
				if stage = Idle and seq = Inactive then
					
					
					shiftReg(size  downto 2) := unsigned(transaction.address);

					if transaction.transaction = Write or transaction.transaction = Index then
						shiftReg(1) := '0';
					elsif transaction.transaction = Read then
						shiftReg(1) := '1';
					end if;
					shiftReg(0) := '1';
					
					cnt := slide; 
					
					busy_internal <= '1';
					bus_data_internal <= '0';
					seq := DataActive;
				end if;
				
				if cnt = 0 then
				
					cnt := clk_reduction -1;
					if seq = Active and stage = Idle then
						stage := Address;
					
					elsif stage = Repeat then 
						if seq = Inactive then
							stage := Idle;
						elsif seq = Active then
							seq := DataActive; 
							bus_clk_internal <= 'Z';
						elsif seq = DataActive then
							seq := Inactive;
							bus_data_internal <= 'Z';
							cnt := longerSlide -1;
						end if;  
						
					elsif stage = Conclude then
					
						if seq = Active then
							seq := DataActive; 
							bus_clk_internal <= 'Z';
						elsif seq = DataActive then
							seq := Inactive;
							bus_data_internal <= 'Z';
							busy_internal <= '0';
							stage := Idle; 
							done <= '1';
						end if;
						
					elsif  bus_clk_internal /= '0' then
						bus_clk_internal <= '0';
						seq := Active;
						
					else
						
						bus_clk_internal <= 'Z';
					end if;
					
					
					if shiftReg = "000000000" and  bus_clk /= '0' then
						
						if bus_data = '0' then	
							if transaction.transaction = Write then
								if stage = Address then
									stage := Reg_Addr;
									shiftReg(2 downto 1) := unsigned(transaction.reg_addr);
								elsif stage = Reg_Addr then
									shiftReg(size downto 1) := unsigned(transaction.data(15 downto 8));									
									stage := Data_H;
								elsif stage = Data_H then
									shiftReg(size downto 1) := unsigned(transaction.data(7 downto 0));
									stage := Data_L; 
								elsif stage = Data_L then
									stage := Conclude; 	
								end if;
								
								shiftReg(0) := '1';
								
							elsif transaction.transaction = Index then
								
								if stage = Address then
							
									stage := Reg_Addr;
									shiftReg(2 downto 1) := unsigned(transaction.reg_addr);
									
									shiftReg(0) := '1';
								elsif stage = Reg_Addr then
									stage := Conclude; 

								end if;
							elsif transaction.transaction = Read then
								
								if stage = Address then
									stage := Data_H;
									shiftReg(size downto 1) := (others=>'0');
									shiftReg(0) := '1'; 	
								end if;
								
							end if;
							if  stage /= Repeat  then
								bus_data_internal <= '0';
							end if;
							cnt := longerSlide -1;
							
						else
								bus_data_internal <= '0';
								stage := Repeat;
							
							
						end if;
					end if;
					
					if (stage = Data_H or stage = Data_L) and  transaction.transaction = Read then
						if bus_clk /= '0' then
								if shiftReg = "000000000" then
									if stage = Data_H  then
										cnt := longerSlide -1;
										stage := Data_L;
										shiftReg(0) := '1';
									elsif stage = Data_L then
										stage := Conclude; 	
									end if;
								elsif shiftReg(size) = '1' then
								
									shiftReg(size downto 0) := (others=>'0');
									
								end if; 
									
						elsif shiftReg(0) /= '1' and shiftReg /= "000000000"  then
							shiftReg(0) := bus_data;
						end if;
					end if;
				else 

					cnt := cnt -1;
					if cnt = clk_half and stage /= Idle and seq = Active and bus_clk = '0' then
						
						if stage = Address or transaction.transaction = Write or transaction.transaction = Index then 
							if shiftReg(size) = '1'  then
								bus_data_internal <= 'Z';
							else
								bus_data_internal <= '0';					
							end if;				
						elsif transaction.transaction = Read then
							if shiftReg = "000000000"  then
								bus_data_internal <= '0';
							else 
								bus_data_internal <= 'Z';
							end if;
						end if;
						
						shiftReg := shift_left(shiftReg, 1);
											
					
					end if;
				end if;
						
			else
				bus_data_internal <= 'Z';
				bus_clk_internal <= 'Z';
			end if;
			
		end if;
	

end  process;

	
process(busy_internal,bus_clk_internal,bus_data_internal,done)
begin
		transaction.busy <= busy_internal;
		bus_clk <= bus_clk_internal;
		bus_data <= bus_data_internal;
		transaction.done <= done;
end  process;	



end behaviour;
