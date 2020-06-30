LIBRARY  ieee;
USE  ieee.std_logic_1164.ALL;
USE  ieee.numeric_std.ALL;
use work.glue.all;

use work.interface_data.all;
use work.functions.all;
use work.motor_auxiliary.all;

ENTITY  control_box_tb  IS
END  control_box_tb;

ARCHITECTURE  behavior  OF  control_box_tb  IS
	signal clk : std_logic :=  '0';
	signal enable : std_logic :=  '0';
	signal res : std_logic :=  '1';
	signal reg_in : signed (15  downto  0):=(others=>'0');
	signal plant_measurement : signed (15  downto  0);
	signal fill_out : signed (15  downto  0);
	signal reg_out : signed (15  downto  0);


	signal temp_transistors : unsigned(9 downto 0);
	signal req_temperature : unsigned(7 downto 0);
	signal req_speed : unsigned(7 downto 0) := x"7f";
	signal control_box_setup : type_control_box_setup;
	signal motor_transistors : type_motor_transistors;
	signal hal_data : std_logic_vector(2 downto 0);
		

	
	constant alfa : unsigned(7 downto 0) := x"63";
	constant clk_period : time := 1 us;

	constant IntPart : integer := 8;
	constant FracPart : integer := 8;
	
		
		component control_box is
		port(
				clk : in  std_logic;
				res : in  std_logic;
				
				i_temp_transistors : in unsigned(9 downto 0);
				i_req_speed : in unsigned(7 downto 0);
				i_req_temperature : in unsigned(7 downto 0);
				i_control_box_setup : in type_control_box_setup;
				i_hal_data : in std_logic_vector(2 downto 0);
				o_motor_transistors : out type_motor_transistors
				);
		end component control_box;
BEGIN

		
			module_control_box: control_box
			port map (
						res => res,	
						clk => clk,	
						
						i_temp_transistors => temp_transistors,
						i_req_speed => req_speed,
						i_req_temperature => req_temperature,
						i_control_box_setup => control_box_setup,
						i_hal_data => hal_data,
						o_motor_transistors => motor_transistors 
					);
process

begin
	initPlant(0);
	res <= '1';
	control_box_setup.enable <= '1';

	
	req_temperature <= x"20";
	--wait for 1200 ms;
	--control_box_setup.enable <= '1';
wait;

end process;

process (clk)
	variable p_sum : std_logic;
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

			--plant_in := to_integer(reg_out);
			
			p_sum := motor_transistors.A_p  or
					 motor_transistors.B_p or
					 motor_transistors.C_p;	
			if p_sum = '1' then 

				plant_out := regToPlant(10,1);
			else
				plant_out := regToPlant(10,0);
			end if;
			
			temp_transistors <= to_unsigned(plant_out,temp_transistors'length);
		
		else

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