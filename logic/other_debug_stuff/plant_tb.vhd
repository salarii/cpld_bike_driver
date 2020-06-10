LIBRARY  ieee;
USE  ieee.std_logic_1164.ALL;
USE  ieee.numeric_std.ALL;
use work.glue.all;

ENTITY  tb  IS
END  tb;

ARCHITECTURE  behavior  OF  tb  IS
	signal clk : std_logic :=  '0';
	signal enable : std_logic :=  '0';
	signal res : std_logic :=  '1';
	signal wdata : std_logic_vector (15  downto  0);

	signal reg_in : signed (15  downto  0);
	signal reg_out : signed (15  downto  0);

	
	constant clk_period : time := 100 us;

	constant IntPart : integer := 8;
	constant FracPart : integer := 8;
	
	component pid is
		generic (CONSTANT IntPart : integer := 8;
	   			 CONSTANT FracPart : integer := 8);
	
		port(
			res : in std_logic;
			clk : in std_logic;
			i_enable : in std_logic;
			i_val	: in  signed(IntPart + FracPart -1  downto 0);
			o_reg : out signed(IntPart + FracPart -1  downto 0)
			);
	end component pid;

BEGIN

		pid_module : pid 
		generic map (
		 	IntPart => IntPart,
			FracPart => FracPart )
		
		port map (
			res =>res,
			clk =>clk,
			i_enable =>enable,
			i_val => reg_in,
			o_reg => reg_out
			);

process

begin
	initPlant(0);

wait;

end process;

process (clk)
	variable cnt : integer := 0;
	variable plant_in : integer := 0;
	variable plant_out : integer := 0; 
	constant demand : signed(15  downto  0) := x"010A";
	--variable reg_executed : boolean := false;
begin
	if rising_edge(clk) then
		if cnt = 10 then
			enable <= '1';
			cnt := 0;	
		else
			cnt := cnt + 1;	
		end if;

		if 	enable = '1' then
				plant_in := to_integer(reg_out);
				plant_out := regToPlant(100,plant_in);
				
				reg_in <= demand - to_signed(plant_out,reg_in'length);
				report integer'image(1);
				report integer'image(to_integer(demand));
				report integer'image(to_integer(reg_out));
				report integer'image(to_integer(reg_in));
				--reg_out
				--wdata <= std_logic_vector(to_unsigned(evalPlant (1000,100) ,wdata'length));
		
			enable <= '0'; 
		end if;
	end  if;
end  process;



clk_process :
process
begin
	clk  <=  '0';
	wait  for clk_period/2;
	clk  <=  '1';
	wait  for clk_period/2;
end  process;


END;