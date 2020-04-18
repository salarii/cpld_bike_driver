use work.interface_data.all;
library IEEE;
use IEEE.std_logic_1164.all;

use ieee.numeric_std.all;

entity spi_tb is
end spi_tb;

architecture t_behaviour of spi_tb is

		component spi is
			generic ( 
				freq : integer;
				bound : integer
				);
				
			port(
				res : in std_logic;		
				clk : in std_logic;	
				
				io_data : inout std_logic_vector(7 downto 0);
				i_miso : in std_logic;
				i_transaction : transaction_type;
				i_enable : in std_logic;
				i_stall : in std_logic;
				
				o_sck : out std_logic;
				o_ss : out std_logic;	
				o_mosi : out std_logic;
				o_received : out std_logic;
				o_busy	: out std_logic
				);
		end component spi;

			
		signal res : std_logic;
		signal clk : std_logic;			
		signal data : std_logic_vector(7 downto 0);
		signal busy : std_logic;
		signal en : std_logic;
		signal received : std_logic;	
		signal miso : std_logic;
		signal mosi : std_logic;
		signal ss : std_logic;			
		signal sck : std_logic;	
		signal transaction : transaction_type;
		signal stall : std_logic;
				
	begin	

		spi_function : spi
		generic map (
		 	freq => 1000000,
			bound => 100000 )
			
		port map (		
			res => res,		
			clk => clk,
			io_data => data,
			i_miso => miso,
			i_transaction => transaction,
			i_enable => en,
			i_stall => stall,
			o_sck => sck,
			o_ss => ss,
			o_mosi => mosi,
			o_received => received,
			o_busy => busy
			);

		process
			begin
				
				-- inputs which produce '1' on the output
				res <= '0';
				--i_data_uart <= x"AB";
				
				transaction <= Write;	
				data <= x"AA";	
				en <= '1';
				
				wait for 10 ns;
				res <= '1';
				wait for 95 ns;
				data <= (others  => 'Z');	
				transaction <= Read;	
				miso <= '1';
				wait for 10 ns;
				miso <= '0';
				wait for 10 ns;
				miso <= '1';
				wait for 10 ns;
				miso <= '0';
				wait for 10 ns;
				miso <= '1';
				wait for 10 ns;
				miso <= '0';
				wait for 10 ns;
				miso <= '1';
				wait for 10 ns;
				miso <= '0';
				wait for 10 ns;
				miso <= '1';
				wait for 10 ns;
				wait for 10 ns;
				wait for 5 ns;
				wait for 5 ns;				
				wait for 100 ns;				
				--res <= '0';
				wait for 10 ns;
				--res <= '1';
				
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