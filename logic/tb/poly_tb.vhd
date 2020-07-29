library IEEE;
use IEEE.std_logic_1164.all;

use ieee.numeric_std.all;
entity poly_tb is
end poly_tb;

architecture t_behaviour of poly_tb is
		signal IntPart : integer := 12;
		signal FracPart : integer := 12;
		signal res :  std_logic;
		signal clk :  std_logic := '0';
		signal start :  std_logic;

		signal calculated :  std_logic;
		signal in_val :  unsigned(9  downto 0);
		signal temp :  unsigned(9  downto 0);


		
		component poly is
			generic (CONSTANT IntPart : integer;
		   			 CONSTANT FracPart : integer);
		
			port(
			res : in std_logic;
			clk : in std_logic;
			i_enable : in std_logic;
			i_val	: in  std_logic_vector(9  downto 0);
			o_calculated : out std_logic;
			o_temp : out std_logic_vector(9  downto 0)
				);
		end component;

		
	begin	
		clk <= not clk after 1 ns;


		module_poly: poly
		generic map(
		 IntPart => IntPart,
		 FracPart => FracPart
		 )
		port map (
		res => res,
		clk => clk,
		i_enable => start,
		o_calculated => calculated,
		i_val	=> std_logic_vector(in_val),
		unsigned(o_temp) => temp );

		process
		
			begin
				
				--
				
				res <= '1';
				start <= '1';
				wait for 2 ns;
				in_val  <= "1111000000";
		
				wait for 4 ns;
				start <= '0';
				wait for 20 ns;	
				
				--assert outMul  = x"2186" report "problem:" & integer'image( to_integer(outMul) );
				
				wait ;	

					

			end process;
		--
	--
--
end t_behaviour;