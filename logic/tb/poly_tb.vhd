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

		
		signal in_val :  unsigned(15  downto 0);
		signal temp :  unsigned(7  downto 0);


		
		component poly is
			generic (CONSTANT IntPart : integer;
		   			 CONSTANT FracPart : integer);
		
			port(
				res : in std_logic;
				clk : in std_logic;
				i_enable : in std_logic;
				i_val	: in  std_logic_vector(15  downto 0);
				o_temp : out std_logic_vector(7  downto 0)
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
		i_val	=> std_logic_vector(in_val),
		unsigned(o_temp) => temp );

		process
		
			begin
				
				--
				
				res <= '0';
				start <= '1';
				start <= '1';
				in_val  <= x"6000";
		
				wait for 1 ns;
				res <= '1';
				
				wait for 20 ns;
				start <= '0';
				wait for 2 ns;					
				start <= '1';
				
				--assert outMul  = x"2186" report "problem:" & integer'image( to_integer(outMul) );
				
				wait for 100 ns;	

					

			end process;
		--
	--
--
end t_behaviour;