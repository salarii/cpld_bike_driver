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
		generic ( 
			freq : integer;
			bound : integer
			);
		port(
			data : inout std_logic_vector(7 downto 0);
			enable : in std_logic;		
			res : in std_logic;		
			clk : in std_logic;	
			rx : in std_logic;		
			error : out std_logic;
			busy	: out std_logic;
			tx	: out  std_logic
			);
	end  component uart;
	
	component comunication is
	generic (delay : integer);
	port(
		data : inout std_logic_vector(7 downto 0);
		enable : out std_logic;		
		busy : in std_logic;
		res : in std_logic;		
		clk : in std_logic
		);
	end component comunication;
	
		signal transaction :  transaction_data; 
		signal res : std_logic;	
		signal clk : std_logic;		
		signal bus_clk	: std_logic;
		signal bus_data :  std_logic;
		signal data1 :  std_logic;
		signal data2 :  std_logic;
		signal simp_transaction : transaction_simp_data;
		signal simp_transaction_rec : transaction_simp_data;

		
		constant clk_period : time := 100 ns;
		
		
		signal data : std_logic_vector(7 downto 0);
		signal address : std_logic_vector(6 downto 0);
		signal enable : std_logic;		
		signal busy	: std_logic;
		signal error : std_logic;
		signal transaction_intern : transaction_type;
		
		signal busy2	: std_logic;
		signal data2out : std_logic_vector(7 downto 0);
			
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
		generic map (
		 	freq => 95,
			bound => 10 )
		
		port map (
			data => transaction.data,
			enable => transaction.enable,		
			res => res,		
			clk => clk,
			rx => data1,	
			error => transaction.error,
			busy => transaction.busy,
			tx => data2
			);

		comunication_module: comunication 
		generic map  (delay =>10)
		port map(
		data => transaction.data,
		enable => transaction.enable,		
		busy => transaction.busy,
		res => res,		
		clk => clk
		);

		--uart_module_pyk : uart 
		--generic map (
		-- 	freq => 95,
		--	bound => 10 )
		--port map (
		--		transaction => simp_transaction_rec,
		--		res => res,
		--		clk => clk,
		--		rx => data2,
		--		tx => data1
		--		);


		process
			begin
				
				-- inputs which produce '1' on the output
				
		
				
				wait for 1 us;
				wait for 1 us;
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

		data <= simp_transaction.data;
		address <= transaction.address;
		enable <= simp_transaction.enable;		
		busy	<= transaction.busy;
		error <= transaction.error;
			
		data2out <= simp_transaction_rec.data;
		busy2 <= simp_transaction_rec.busy;
		
		
end t_behaviour;