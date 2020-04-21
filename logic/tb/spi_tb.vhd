use work.interface_data.all;
library IEEE;
use IEEE.std_logic_1164.all;

use ieee.numeric_std.all;

entity spi_tb is
end spi_tb;

architecture t_behaviour of spi_tb is

		component flash_controller is
			generic ( 
				freq : integer;
				bound : integer
				);
				
			port(
				res : in std_logic;		
				clk : in std_logic;	
			
				io_data : inout std_logic_vector(23 downto 0);
				i_address : in std_logic_vector(7 downto 0);
				i_transaction : in transaction_type;
				i_enable : in std_logic;
				i_spi : in type_to_spi;
					
				o_spi : out type_from_spi;
				o_received : out std_logic;
				o_busy	: out std_logic
				);
		end component flash_controller;

		component spi is
			generic ( 
				freq : integer;
				bound : integer
				);
				
			port(
				res : in std_logic;		
				clk : in std_logic;	
				
				io_data : inout std_logic_vector(7 downto 0);
				i_spi : in type_to_spi;
				i_transaction : transaction_type;
				i_enable : in std_logic;
				
				o_spi : out type_from_spi;
				o_received : out std_logic;
				o_busy	: out std_logic
				);
		end component spi;

			
		signal res : std_logic;
		signal clk : std_logic;			
		signal data : std_logic_vector(23 downto 0);
		signal address : std_logic_vector(7 downto 0);
		signal busy : std_logic;
		signal en : std_logic;
		signal received : std_logic;	
		signal transaction : transaction_type;
		signal in_spi : type_to_spi;
		signal out_spi : type_from_spi;
		
		signal miso : std_logic;
		signal mosi : std_logic;
		signal ss : std_logic;
		signal sck : std_logic;		
		
		
	begin	
	
		miso <= in_spi.miso;
		mosi <= out_spi.mosi;
		ss <= out_spi.ss;
		sck <= out_spi.sck;

		flash_function : flash_controller
			generic map ( 
		 	freq => 1000000,
			bound => 100000 )
				
			port map(
					res => res,		
					clk => clk,
					 
					io_data => data,
					i_address => address,
					i_transaction => transaction,
					i_enable => en,
					i_spi => in_spi,
						
					o_received => received,
					o_spi => out_spi,
					o_busy => busy
				);

		process
			begin
				
				-- inputs which produce '1' on the output
				--res <= '0';
				res <= '1';
				--i_data_uart <= x"AB";
				
				transaction <= Read;	
				data <= (others => 'Z');
				en <= '1';
				address <= x"01";
				in_spi.miso <= '0';
				wait for 10 ns;
				en <= '0';
				res <= '1';
				wait for 440 ns;
				in_spi.miso <= '1';
				--data <= (others  => 'Z');	
					
		
				wait for 10 ns;
				wait for 10 ns;
				wait for 10 ns;
				wait for 10 ns;
				wait for 10 ns;
				wait for 10 ns;
				wait for 10 ns;
				wait for 10 ns;
				wait for 10 ns;
				wait for 10 ns;
				wait for 5 ns;
				wait for 5 ns;				
				wait for 100 ns;
				wait for 10 ns;
				
				wait for 1 ms;

				wait;
			end process;
		--
clk_process :
process
	constant clk_period : time := 1 ns;
begin
	clk  <=  '0';
	wait  for clk_period/2;
	clk  <=  '1';
	wait  for clk_period/2;
end  process;


end t_behaviour;