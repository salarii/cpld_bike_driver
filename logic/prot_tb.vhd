library IEEE;
use IEEE.std_logic_1164.all;

use work.interface_data.all;


entity wire is
	port(	
		bus_clk	: out  std_logic;
		bus_data : out std_logic
		);
end wire;

architecture t_behaviour of wire is
	
begin

	bus_clk <= 'H';
	bus_data <= 'H';



end  architecture;


library IEEE;
use IEEE.std_logic_1164.all;

use work.interface_data.all;


entity prot_tb is
end prot_tb;

architecture t_behaviour of prot_tb is

	component i2c_master is
		port(
		transaction : inout transaction_data; 
		res : in std_logic;
		clk : in std_logic;			
		bus_clk	: inout  std_logic;
		bus_data : inout std_logic
		);
	end component i2c_master;
	
	component wire is
		port(
		bus_clk	: inout  std_logic;
		bus_data : inout std_logic
		);
	end component wire;
	
	component uart is
		port(
			transaction : inout transaction_simp_data; 
			res : in std_logic;		
			clk : in std_logic;	
			rx : in std_logic;		
			tx	: out  std_logic
			);
	end  component uart;
	
		signal transaction :  transaction_data; 
		signal res : std_logic;	
		signal clk : std_logic;		
		signal bus_clk	: std_logic;
		signal bus_data :  std_logic;
		signal data1 :  std_logic;
		signal data2 :  std_logic;
		signal simp_transaction : transaction_simp_data;
		
		constant clk_period : time := 100 ns;
		
		
		signal data : std_logic_vector(7 downto 0);
		signal address : std_logic_vector(6 downto 0);
		signal enable : std_logic;		
		signal busy	: std_logic;
		signal error : std_logic;
		signal transaction_intern : transaction_type;
		
			
	begin	

		--module_func: i2c_master
		--port map (
		--		transaction => transaction,
		--		res => res,
		--		clk => clk,
		--		bus_clk => bus_clk,
		--		bus_data => bus_data
		--		);

		--module_wire: wire
		--port map (
		--		bus_clk => bus_clk,
		--		bus_data => bus_data
		--		);

		uart_module : uart 
		port map (
				transaction => simp_transaction,
				res => res,
				clk => clk,
				rx => data1,
				tx => data2
				);

		process
			begin
				
				-- inputs which produce '1' on the output
				
				simp_transaction.transaction <= Write;
				wait for 1 us;
				simp_transaction.enable <= '1';
				wait for 16.5 us;
				--bus_data <= '0';
				
				wait for 1 ms;

				wait;
			end process;
		--
clk_process :
process
begin
	clk  <=  '0';
	wait  for clk_period/2;
	clk  <=  '1';
	wait  for clk_period/2;
end  process;

		data <= transaction.data;
		address <= transaction.address;
		enable <= transaction.enable;		
		busy	<= transaction.busy;
		error <= transaction.error;
			

end t_behaviour;