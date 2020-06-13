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
	signal enable_filter :=  '0';
	signal reg_in : signed (15  downto  0):=(others=>'0');
	signal plant_measurement : signed (15  downto  0);
	signal fill_out : signed (15  downto  0);
	signal reg_out : signed (15  downto  0);

	
	constant alfa : unsigned(7 downto 0) := x"63";
	constant clk_period : time := 100 ms;

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

	component pd is
		generic (CONSTANT IntPart : integer := 8;
	   			 CONSTANT FracPart : integer := 8);
	
		port(
			res : in std_logic;
			clk : in std_logic;
			i_enable : in std_logic;
			i_val	: in  signed(IntPart + FracPart -1  downto 0);
			o_reg : out signed(IntPart + FracPart -1  downto 0)
			);
	end component pd;
	
	component low_pass is
			
		port(
			res : in std_logic;		
			clk : in std_logic;		
			i_enable : in std_logic;		
			
			i_no_filter_val  : in unsigned(15 downto 0);
			i_alfa : in  unsigned(7 downto 0);
			o_filtered : out  unsigned(15 downto 0)
			);
	end component low_pass;

BEGIN

		pid_module : pd 
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

	module_filter : low_pass 
			
	port map(
		res => res,
		clk => clk,	
		i_enable =>enable_filter,
			
		i_no_filter_val => plant_measurement,
		i_alfa => alfa,
		o_filtered => fill_out
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
	constant demand : signed(15  downto  0) := x"0100";
	--variable reg_executed : boolean := false;
begin
	if rising_edge(clk) then

		if cnt = 10 then
			enable <= '1';
			cnt := 0;	
						
			plant_in := to_integer(reg_out);
			plant_out := regToPlant(1000,plant_in);
			plant_measurement <= to_unsigned(plant_out,plant_measurement'length);
			enable_filter  <= '1';
		else
			if 	enable = '1' then
					
				enable <= '0'; 
			elsif enable_filter = '1'  then
				reg_in <= demand - to_signed(fill_out);
			
				enable_filter  <= '0';
				enable  <= '1';
			end if;
			cnt := cnt + 1;	
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