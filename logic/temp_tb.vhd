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
			i_to_i2c : in type_to_i2c;
			o_from_i2c : out type_from_i2c;
			i2c_bus : inout std_logic_vector(7 downto 0);
			
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
			o_to_i2c : out type_to_i2c;
			i_from_i2c : in type_from_i2c;
			i2c_bus : inout std_logic_vector(7 downto 0);
	
			clk : in  std_logic;
			res : in  std_logic;
			
			o_uart : inout std_logic_vector(7 downto 0);
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
		end component uart;
	 
		signal to_i2c : type_to_i2c;
		signal from_i2c : type_from_i2c;
		signal i2c_bus : std_logic_vector(7 downto 0);
		
		signal res : std_logic;	
		signal clk : std_logic;		
		signal bus_clk	: std_logic;
		signal bus_data :  std_logic;


		signal ready	: std_logic;
		
		
		constant clk_period : time := 100 ns;
		
		signal data : std_logic_vector(15 downto 0);
		signal address : std_logic_vector(6 downto 0);
		
		signal enable : std_logic;		
		signal busy	: std_logic;
		signal done	: std_logic;
		signal error : std_logic;
		signal continue : std_logic;
					
			
		signal o_uart : std_logic_vector(7 downto 0);
		signal busy_uart : std_logic;
		signal en_uart : std_logic;
		signal tx_uart : std_logic;
		signal rx_uart : std_logic;
		signal err_uart : std_logic;		
		
	begin	

		module_master: i2c_master
		port map (
				i_to_i2c => to_i2c,
				o_from_i2c => from_i2c,
				i2c_bus => i2c_bus,
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
				o_to_i2c => to_i2c,
				i_from_i2c => from_i2c,
				i2c_bus => i2c_bus,
				res => res,
				clk => clk,
				o_uart => o_uart,
				busy_uart => busy_uart,
				en_uart => en_uart
				);

		to_display : uart
		generic map (
		 	freq => 95,
			bound => 10 )
			
		port map (
			data => o_uart,
			enable => en_uart,		
			res => res,		
			clk => clk,
			rx => rx_uart,	
			error => err_uart,
			busy => busy_uart,
			tx => tx_uart
			);

		process
			begin
				
				-- inputs which produce '1' on the output
				
		
				wait for 1 us;
				wait for 0.1 us;
				wait for 165 us;
				res <= '0';
				wait for 195 us;				
				res <= '1';
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

	address <= to_i2c.address;
	enable <= to_i2c.enable;		
	continue <= to_i2c.continue;
	
	busy <= from_i2c.busy;
	done <= from_i2c.done;
	error <= from_i2c.error;
			
end t_behaviour;