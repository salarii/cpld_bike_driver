

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity poly is
	generic (CONSTANT IntPart : integer := 12;
   			 CONSTANT FracPart : integer := 12);

	port(
		res : in std_logic;
		clk : in std_logic;
		i_enable : in std_logic;
		i_val	: in  std_logic_vector(9  downto 0);
		o_calculated : out std_logic;
		o_temp : out std_logic_vector(7  downto 0)
		);
end poly;

architecture behaviour of poly is
		constant one : signed(IntPart + FracPart - 1  downto 0) := x"001000";
		
		signal translated_input : signed (IntPart + FracPart - 1  downto 0):= (others => '0');
		signal stored_val_power : signed (IntPart + FracPart - 1  downto 0) := one;
		signal out_mul_1 : signed (IntPart + FracPart - 1  downto 0);
		signal mul2_in : signed (IntPart + FracPart - 1  downto 0);
		signal out_mul_2 : signed (IntPart + FracPart - 1  downto 0);
		signal result : signed (IntPart + FracPart - 1  downto 0) := (others=>'0');
		signal calculated : std_logic := '0';
		---    0.8444  56.9365  -12.7778  1.3186          
		
		constant par_0 : signed(IntPart + FracPart - 1  downto 0) := "000000000000110110000010";
		constant par_1 : signed(IntPart + FracPart - 1  downto 0) := "000000111000111011111011";
		constant par_2 : signed(IntPart + FracPart - 1  downto 0) := "111111110011001110001111";
		constant par_3 : signed(IntPart + FracPart - 1  downto 0) := "000000000001010100011000";

		component two_com_mul
			generic (CONSTANT IntPart : integer;
		   			 CONSTANT FracPart : integer );
		port  (
			A : in  signed(IntPart + FracPart - 1  downto 0);
			B : in  signed(IntPart + FracPart - 1  downto 0);
			outMul : out signed(IntPart + FracPart - 1  downto 0));
		end component;
				
begin	

		module_mul1: two_com_mul
		generic map(
			 IntPart => IntPart,
			 FracPart => FracPart
		 )
		port map (
			A => stored_val_power,
			B => signed(translated_input),
			outMul => out_mul_1);

		module_mul2: two_com_mul
		generic map(
			 IntPart => IntPart,
			 FracPart => FracPart
		 )
		port map (
			A => stored_val_power,
			B => mul2_in,
			outMul => out_mul_2);

	process(clk)
		type state_type is (inactive_state, active_state, calculated_state);
		variable state : state_type := inactive_state;

		variable fracRange : integer := IntPart + FracPart;
		variable cnt : integer range 3 downto 0 := 0;


	begin
			
		if  res = '0' then
			cnt := 0;
			state := inactive_state;
			stored_val_power <= one;
			result <= (others=>'0');
			calculated <= '0';
		elsif  rising_edge(clk) then
			
			if i_enable = '1' and state = inactive_state then 
				state := active_state;
				result <= par_0;
				calculated <= '0';
			elsif  i_enable = '0' and state = calculated_state then
				state := inactive_state;
				cnt := 0;
			elsif state = active_state then
			
				case cnt is
				  when 0 => mul2_in <= par_1;
				  when 1 => mul2_in <= par_2;
				  when 2 => mul2_in <= par_3;
				  when others => mul2_in <= (others=>'0');
				end case;
				
				
				result <= result + out_mul_2;
				
				
				if cnt = 3 then
					stored_val_power <= one;
					state := calculated_state;
					calculated <= '1'; 
				else
					stored_val_power <= out_mul_1;
					cnt := cnt + 1;
				end if;
			end if;
			
		end if;
		
	end process;

	process(result,i_val,calculated)
	begin
		translated_input(14 downto 5) <= signed(i_val);
		o_temp <= std_logic_vector(result(IntPart + FracPart - 5  downto FracPart));
		o_calculated <= calculated;

	end process;

end behaviour;

		