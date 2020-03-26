

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
	signal debug : unsigned(9 downto 0);
begin	


process(clk)
		type transaction_seq is (Inactive, DataActive, Active);

		constant slide : integer := 10;
		constant clk_reduction : integer := 10;
		constant longerSlide : integer := 20;
		constant clk_half : integer := clk_reduction/2;
		constant size : integer := 9;
		variable cnt : integer;
		
		variable shiftReg : unsigned(size downto 0);
		variable stage : transaction_stage := Idle;
		variable seq : transaction_seq := Inactive;		
begin
		
		debug <= shiftReg;
		if res = '1' then
			stage := Idle;
			shiftReg := to_unsigned(0,size + 1);
		elsif rising_edge(clk)  then
		
			--report "cnt:  " & integer'image(cnt);
			
			if transaction.enable = '1' or busy_internal = '1' then
				
				if stage = Idle then
					stage := Address;
					shiftReg(size -1 downto 2) := unsigned(transaction.address);
					shiftReg(size) := '0';
					
					if transaction.transaction = write then
						shiftReg(1) := '0';
					elsif transaction.transaction = read then
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
					if stage = Repeat then 
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
				
					elsif  bus_clk_internal /= '0' then
						bus_clk_internal <= '0';
						seq := Active;
					else
						
						bus_clk_internal <= 'Z';
					end if;
					
					
					if shiftReg = "1000000000" and  bus_clk /= '0' then
						
						if bus_data = '0' then	
							
							if stage = Address then
								stage := Reg_Addr;
							elsif stage = Reg_Addr then
								stage := Data_H;
							end if;
							cnt := longerSlide -1;
							if  transaction.transaction = write then 
							 
								if stage = Reg_Addr then
									shiftReg(2 downto 1) := unsigned(transaction.reg_addr);
								elsif stage = Data_H then
									shiftReg(size -1 downto 1) := unsigned(transaction.data);
								elsif Data_L
								end if;
								shiftReg(size) := '0';
								shiftReg(0) := '1';
							elsif transaction.transaction = read then
								shiftReg(0) := '1';
							end if;
							--report integer'image(cnt);
							--report integer'image(to_integer(shiftReg));
								
							-- handle  error  somehow
						else
							if stage = Address then 
								bus_data_internal <= '0';
								stage := Repeat;
							end if;
							
						end if;
					end if;
					
				else 

					if cnt = clk_half and seq = Active and bus_clk = '0' then
				
						shiftReg := shift_left(shiftReg, 1);
						
					end if;
					
					cnt := cnt -1;
				end if;
				
				
				if stage = Address or transaction.transaction = write then 
					if shiftReg(size) = '1'  then
						bus_data_internal <= 'Z';
					else
						bus_data_internal <= '0';					
					end if;				
				elsif transaction.transaction = read then
					shiftReg(0) := bus_data_internal;
				end if;
				
			else
				bus_data_internal <= 'Z';
				bus_clk_internal <= 'Z';
			end if;
			
		end if;
	

end  process;

	
process(busy_internal,bus_clk_internal,bus_data_internal)
begin
		transaction.busy <= busy_internal;
		bus_clk <= bus_clk_internal;
		bus_data <= bus_data_internal;
end  process;	



end behaviour;
