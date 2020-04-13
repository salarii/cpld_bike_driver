

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity div is
	generic (CONSTANT size : integer := 12);

	port(
		res : in std_logic;
		clk : in std_logic;
		i_enable : in std_logic;
			
		i_divisor	: in  unsigned(size - 1  downto 0);
		i_divident : in  unsigned(size - 1  downto 0);
		o_valid : out std_logic;
		o_quotient : out unsigned(size - 1  downto 0)
		);
end div;

architecture behaviour of div is
	
begin	


	process(clk)
		variable  initiated : boolean :=  false;
		variable index : integer range size-1 downto 0 := 0;
		variable part_divident : signed (size downto 0 ) := (others => '0'); 
		variable sig_divisor : signed (size downto 0 ) := (others => '0'); 
		variable tmp : unsigned (size  downto 0);
	begin
	


		if  rising_edge(clk) then
			if  res = '0' then
				index := size -1;
				initiated := false;	
				part_divident := (others => '0');
				sig_divisor := (others => '0'); 
				o_quotient <= (others => '0'); 
				
			elsif i_enable = '1' or initiated = true then 
				if initiated = false then
					index := size -1;
				
					initiated := true;
					tmp(size -1  downto 0) := i_divident;
					tmp(size) := '0';
					o_valid <= '0';
					o_quotient <= (others => '0'); 
				else 
					
					part_divident(size  downto 0) := signed(shift_right(tmp, index));
					sig_divisor(size -1  downto 0) := signed(i_divisor);
					part_divident := part_divident - sig_divisor; 
					if part_divident >= 0 then
						o_quotient(index) <= '1';
						tmp(size -1  downto index) := unsigned(part_divident(size -1 - index  downto 0));
					end if;
				
					if index = 0 then
						o_valid <= '1';
						initiated := false;
					else
						index := index - 1;
					end if;
					
				end if;
			end if;
		end if;
		
			

	end process;

end behaviour;

