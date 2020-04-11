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
				leds : out std_logic_vector(4 downto 0);
			res : in std_logic;		
			clk : in std_logic;		
			o_slave_clk	: out  std_logic;
			o_slave_data : out std_logic;
			o_data_en : out std_logic;
			i_slave_data : in std_logic
			);
		end component i2c_master;
		
		component wire is
			port(
			bus_clk	: inout  std_logic;
			bus_data : inout std_logic
			);
		end component wire;
		
		
		
		component control_unit is
			port(
				clk : in  std_logic;
				res : in  std_logic;
				
		
				i_from_i2c : in type_from_i2c;
				i2c_bus : inout std_logic_vector(7 downto 0);
				o_to_i2c : out type_to_i2c;
						
				i_busy_uart : in std_logic;
				i_from_uart : in std_logic_vector(7 downto 0);
				i_received_uart : in std_logic;
				o_to_uart : out std_logic_vector(7 downto 0);
				o_en_uart : out std_logic
			);
		end component control_unit;
	
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
			res : in std_logic;		
			clk : in std_logic;	
			
			i_data : in std_logic_vector(7 downto 0);
			i_enable : in std_logic;
			i_rx : in std_logic;	
			
			o_data : out std_logic_vector(7 downto 0);	
			o_error : out std_logic;
			o_received : out std_logic;
			o_busy	: out std_logic;
			o_tx	: out  std_logic
			);
		end component uart;
	 

	 
	 
	 	signal leds : std_logic_vector(4 downto 0);
	 
		signal to_i2c : type_to_i2c;
		signal from_i2c : type_from_i2c;
		signal i2c_bus : std_logic_vector(7 downto 0);
		
		signal res : std_logic;	
		signal clk : std_logic;		
		signal bus_clk	: std_logic;
		signal bus_data :  std_logic;
		signal o_slave_data :  std_logic;
		signal o_data_en :  std_logic;
		signal i_slave_data :  std_logic;

		signal ready	: std_logic;
		
		
		constant clk_period : time := 100 ns;
		
		signal data : std_logic_vector(15 downto 0);
		signal address : std_logic_vector(6 downto 0);
		
		signal enable : std_logic;		
		signal busy	: std_logic;
		signal done	: std_logic;
		signal error : std_logic;
		signal continue : std_logic;
					
			
		signal to_uart : std_logic_vector(7 downto 0);
		signal from_uart : std_logic_vector(7 downto 0);
		signal received_uart : std_logic; 
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
				leds => leds,
				res => res,
				clk => clk,
				o_slave_clk => bus_clk,
				o_slave_data => o_slave_data,
				o_data_en => o_data_en,
				i_slave_data => i_slave_data
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

		
		control_func: control_unit
		port map (
				res => res,
				clk => clk,
				
				o_to_i2c => to_i2c,
				i_from_i2c => from_i2c,
				i2c_bus => i2c_bus,

				i_received_uart => received_uart,
				i_from_uart => from_uart,
				i_busy_uart => busy_uart,
				o_to_uart => to_uart,
				o_en_uart => en_uart
				);

 
		to_display : uart
		generic map (
		 	freq => 100,
			bound => 10 )
			
		port map (
			res => res,		
			clk => clk,
			i_data => to_uart,
			i_enable => en_uart,		
			i_rx => rx_uart,	
			o_data => from_uart,
			o_error => err_uart,
			o_received => received_uart,
			o_busy => busy_uart,
			o_tx => tx_uart
			);

		process
			begin
				
				-- inputs which produce '1' on the output
				
		
				wait for 1 us;
				
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 7 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '1';
				wait for 3 us;

				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 7 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 3 us;
				
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 4 us;
				rx_uart <= '0';
				wait for 4 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 3 us;
				
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '0';
				wait for 8 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 3 us;
				
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 2 us;
				rx_uart <= '0';
				wait for 6 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '1';
				wait for 3 us;
							
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
			
			
	i_slave_data <= bus_data;
	bus_data <=  o_slave_data when o_data_en = '1' else  'Z'; 

			
end t_behaviour;