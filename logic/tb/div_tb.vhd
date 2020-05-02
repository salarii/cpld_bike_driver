library IEEE;
use IEEE.std_logic_1164.all;

use ieee.numeric_std.all;
entity div_tb is
end div_tb;

architecture t_behaviour of div_tb is
		signal IntPart : integer := 16;
		signal FracPart : integer := 0;

		
		signal A :  signed(IntPart + FracPart - 1  downto 0);
		signal B :  signed(IntPart + FracPart - 1  downto 0);

		signal outMul : signed(IntPart + FracPart - 1  downto 0);

		
		component two_com_mul
			generic (CONSTANT IntPart : integer;
		   			 CONSTANT FracPart : integer );
		port  (
		A : in  signed(IntPart + FracPart - 1  downto 0);
		B : in  signed(IntPart + FracPart - 1  downto 0);

		outMul : out signed(IntPart + FracPart - 1  downto 0));
		end component two_com_mul;
		
	component div is
		generic (CONSTANT size : integer);
	
		port(
			res : in std_logic;
			clk : in std_logic;
			i_enable : in std_logic;
			
			i_divisor	: in  unsigned(size - 1  downto 0);
			i_divident : in  unsigned(size - 1  downto 0);
			o_valid : out std_logic;
			o_quotient : out unsigned(size - 1  downto 0)
			);
	end component div;
		
		
		signal divisor	: unsigned(15 downto 0);
		signal divident : unsigned(15  downto 0);	
		signal quot : unsigned(15  downto 0);	
		signal valid : std_logic;
		signal enable_div : std_logic := '0';
		constant  base : integer := 1000;
		constant norm : unsigned(15 downto 0):= to_unsigned(base,16);
	
		signal clk : std_logic;		
		signal res : std_logic;	
					

		signal rotation_speed : unsigned(15 downto 0):= (others => '0');
		
		constant clk_period : time := 1 us;
	begin	

		module_div: div
		generic map(
		 size => 16)
		port map (
		res => res,
		clk => clk,
		i_enable => enable_div,
		i_divisor => divisor,
		i_divident	=> divident,
		o_valid => valid,
		o_quotient => quot);

		process
		
			begin
				
				--
				
				wait for 1 us;
				divisor <= x"0001";
				divident <= x"03F8";
				enable_div <= '1';
				wait for 1 us;
				enable_div <= '0';
				wait for 20 us;
				assert quot  = x"03F8" report "problem";
				wait for 1 us;
				divisor <= x"0ccc";
				divident <= x"0ccc";
				enable_div <= '1';
				wait for 1 us;
				enable_div <= '0';
				wait for 20 us;
				assert quot  = x"0001" report "problem";
				wait for 1 us;
				divisor <= x"accc";
				divident <= x"0ccc";
				enable_div <= '1';
				wait for 1 us;
				enable_div <= '0';
				wait for 20 us;
				assert quot  = x"0000" report "problem";
						
				wait for 1 us;
				divisor <= x"001c";
				divident <= x"0ccc";
				enable_div <= '1';
				wait for 1 us;
				enable_div <= '0';
				wait for 20 us;
				assert quot  = x"0075" report "problem";
							
								
				wait for 1000 us;	
				

				
				--
				
				wait for 10 ns;		
						

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
--
end t_behaviour;