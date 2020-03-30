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
use ieee.numeric_std.all;

entity temp_tb is
end temp_tb;

architecture t_behaviour of temp_tb is

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
	
	component adc_control is
		port(
		clk : in  std_logic;
		res : in  std_logic;
		i2c : inout  transaction_data;
		ready : in  std_logic;
		
		o_uart : out unsigned(7 downto 0);
		busy_uart : in std_logic;
		en_uart : out std_logic
		);
	end component adc_control;

	component i2c_slave is
		port(
			res : in std_logic;		
			bus_clk	: in  std_logic;
			bus_data : inout std_logic
			);
	end component i2c_slave;
	
	
		signal transaction :  transaction_data; 
		signal res : std_logic;	
		signal clk : std_logic;		
		signal bus_clk	: std_logic;
		signal bus_data :  std_logic;


		signal ready	: std_logic;
		
		
		constant clk_period : time := 100 ns;
		
		signal data : std_logic_vector(15 downto 0);
		signal address : std_logic_vector(6 downto 0);
		signal reg_addr : std_logic_vector(1 downto 0);
		signal enable : std_logic;		
		signal busy	: std_logic;
		signal done	: std_logic;
		signal error : std_logic;
			
			
		signal o_uart : unsigned(7 downto 0);
		signal busy_uart : std_logic;
		signal en_uart : std_logic;
	begin	

		module_master: i2c_master
		port map (
				transaction => transaction,
				res => res,
				clk => clk,
				bus_clk => bus_clk,
				bus_data => bus_data
				);

		module_slave: i2c_slave
		port map(
			res => res,		
			bus_clk	=>  bus_clk,
			bus_data => bus_data
			);
			

		module_wire: wire
		port map (
				bus_clk => bus_clk,
				bus_data => bus_data
				);


		control_func: adc_control
		port map (
				res => res,
				clk => clk,
				i2c => transaction,
				ready => ready,
				o_uart => o_uart,
				busy_uart => busy_uart,
				en_uart => en_uart
				);

		process
			begin
				
				-- inputs which produce '1' on the output
				
		
				ready <= '0';
				wait for 1 us;
				wait for 0.1 us;
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
	reg_addr <= transaction.reg_addr;
	enable <= transaction.enable;		
	busy <= transaction.busy;
	done <= transaction.done;
	error <= transaction.error;
		
end t_behaviour;