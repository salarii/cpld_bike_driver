
library IEEE;
use IEEE.std_logic_1164.all;

use ieee.numeric_std.all;

entity uart_tb is
end uart_tb;

architecture t_behaviour of uart_tb is

		component uart is
			generic ( 
				freq : integer;
				bound : integer
				);
			
		port(
			i_data : in std_logic_vector(7 downto 0);
			enable : in std_logic;
			res : in std_logic;		
			clk : in std_logic;	
			rx : in std_logic;	
			
			o_data : out std_logic_vector(7 downto 0);	
			error : out std_logic;
			received : out std_logic;
			busy	: out std_logic;
			tx	: out  std_logic
			);
		end component uart;
			
		signal res : std_logic;
		signal clk : std_logic;			
		signal i_data_uart : std_logic_vector(7 downto 0);
		signal o_data_uart : std_logic_vector(7 downto 0);
		signal busy_uart : std_logic;
		signal en_uart : std_logic;
		signal received_uart : std_logic;
		signal tx_uart : std_logic;
		signal rx_uart : std_logic;
		signal err_uart : std_logic;		
		
	begin	
		
		
		to_display : uart
		generic map (
		 	freq => 1000000,
			bound => 100000 )
			
		port map (
			i_data => i_data_uart,
			enable => en_uart,		
			res => res,		
			clk => clk,
			rx => rx_uart,	
			o_data => o_data_uart,
			error => err_uart,
			received => received_uart,
			busy => busy_uart,
			tx => tx_uart
			);

		process
			begin
				
				-- inputs which produce '1' on the output
				res <= '0';
				--en_uart <= '1';
				i_data_uart <= x"AB";
				wait for 3 ns;
				res <= '1';
				wait for 10 ns;
				
				wait for 10 ns;
				wait for 10 ns;
				
				wait for 100 ns;				
				res <= '0';
				wait for 10 ns;
				res <= '1';
				
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