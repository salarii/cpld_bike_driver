

use work.interface_data.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity i2c_master is
	port(
		i_to_i2c : in type_to_i2c;
		o_from_i2c : out type_from_i2c;
			
		i2c_bus : inout std_logic_vector(7 downto 0);
			
		res : in std_logic;		
		clk : in std_logic;		
		bus_clk	: inout  std_logic;
		bus_data : inout std_logic
		);
end i2c_master;

architecture behaviour of i2c_master is
	signal busy_internal	: std_logic := '0';
	signal bus_clk_internal	: std_logic;
	signal bus_data_internal : std_logic;
	signal debug : unsigned(7 downto 0);
	signal data_out : signed(15 downto 0);
	signal done : std_logic := '0';
begin	


process(clk)
		type transaction_seq is (Inactive, DataActive, Active);

		constant slide : integer := 10;
		constant clk_reduction : integer := 10;
		constant longerSlide : integer := 20;
		constant clk_half : integer := clk_reduction/2;
		variable cnt : integer;
		
		variable cycle_counter : integer range 10 downto 0 := 0; 
		
		variable shiftReg : unsigned(7 downto 0);
		variable stage : transaction_stage := t_Idle;
		variable seq : transaction_seq := Inactive;		
begin
		
		debug <= to_unsigned(cycle_counter, debug'length);
		--debug <= shiftReg;
		if res = '1' then
			stage := t_Idle;
			shiftReg := to_unsigned(0,8);
			seq := Inactive;
			done <= '0';
			busy_internal <= '0';
			cycle_counter:= 0;
		elsif rising_edge(clk)  then
		
			--report "cnt:  " & integer'image(cnt);
			
			if done  = '1' then
				done <= '0';
			end if;	
			
			if i_to_i2c.enable = '1' or busy_internal = '1' then
				
				if stage = t_Idle and seq = Inactive then
					stage := t_Address;
					
					shiftReg(7  downto 1) := unsigned(i_to_i2c.address);
				
					if i_to_i2c.transaction = Write then
						shiftReg(0) := '0';
						i2c_bus <= (others=>'Z');
					elsif i_to_i2c.transaction = Read then
						shiftReg(0) := '1';
					end if;
					
					cnt := slide; 
					cycle_counter := 0;
					busy_internal <= '1';
					bus_data_internal <= '0';
					seq := DataActive;
				end if;
				
				if cnt = 0 then
					
					cnt := clk_reduction -1;
					if stage = t_Repeat then 
						if seq = Inactive then
							stage := t_Idle;
						elsif seq = Active then
							seq := DataActive; 
							bus_clk_internal <= 'Z';
						elsif seq = DataActive then
							seq := Inactive;
							bus_data_internal <= 'Z';
							cnt := longerSlide -1;
						end if;  
					elsif stage = t_Continue then
						bus_clk_internal <= '0';
						bus_data_internal <= '0';
						if seq = Active then
							seq := Inactive;
							cnt := longerSlide -1;
						elsif seq = Inactive then
							busy_internal <= '0';
							if i_to_i2c.enable = '1' then
							
							
							end if;
						end if;
						
					elsif stage = t_Conclude then

						if seq = Active then
								seq := DataActive; 
								bus_clk_internal <= 'Z';
						elsif seq = DataActive then
								seq := Inactive;
								bus_data_internal <= 'Z';
								busy_internal <= '0';
								stage := t_Idle; 
								done <= '1';
						end if;

					elsif  bus_clk_internal /= '0' then
						bus_clk_internal <= '0';
						seq := Active;
						
					else
						
						bus_clk_internal <= 'Z';
					end if;
					

					if stage /= t_Continue then
						if stage = t_Data then
							if i_to_i2c.transaction = Read then
								
								if  bus_clk /= '0' then
								
									if cycle_counter = 7 then
										if stage = t_Data  then
											i2c_bus <= std_logic_vector(shiftReg);
										
										end if;
										
										bus_data_internal <= '0';
									elsif cycle_counter = 8 then
										bus_data_internal <= 'Z';
										
										
										if stage = t_Data  then
		
											if i_to_i2c.continue = '1' then
												stage := t_Continue;
											else
												stage := t_Conclude;
											end if;	
										
										end if;
										
										cnt := longerSlide -1;
								
									end if;
								
								else			
										shiftReg(0) := bus_data;
								end if;
							elsif i_to_i2c.transaction = Write and cycle_counter = 0 and bus_clk /= '0' then
								cnt := longerSlide -1;
							end if;
						end if;
						if  bus_clk = '0' then
							if cycle_counter = 8  then
		
								if bus_data = '0' then	
									cycle_counter := 0;
									if i_to_i2c.transaction = Write then
										if stage = t_Address then
											shiftReg := unsigned(i2c_bus);
											stage := t_Data; 
											bus_data_internal <= '0';
										elsif stage = t_Data then
											if i_to_i2c.continue = '1' then
												
												stage := t_Continue;
											else
												stage := t_Conclude;
											end if;	
										
										end if;
										
		
									elsif i_to_i2c.transaction = Read then
		
										if stage = t_Address then
											stage := t_Data;
											shiftReg := (others=>'0');	
										end if;
										
									end if;
									
								else
										bus_data_internal <= '0';
										stage := t_Repeat;
									
									
								end if;
							else
								cycle_counter := cycle_counter + 1;
							end if;
						end if;
					end if;
				else 

					cnt := cnt -1;
					if cnt = clk_half  and seq = Active and bus_clk = '0' and stage /= t_Continue then
						
						if stage = t_Address or i_to_i2c.transaction = Write then 
							if shiftReg(7) = '1'  then
								bus_data_internal <= 'Z';
							else
								bus_data_internal <= '0';					
							end if;				
						end if;
						
						shiftReg := shift_left(shiftReg, 1);
						shiftReg(0) := '1';					
					
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
		o_from_i2c.busy <= busy_internal;
		bus_clk <= bus_clk_internal;
		bus_data <= bus_data_internal;
		o_from_i2c.done <= done;
end  process;	



end behaviour;
