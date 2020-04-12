

library IEEE;
use IEEE.std_logic_1164.all;


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



package motor_auxiliary is

type type_on_transistors_path is (A_B, A_C, B_A, B_C, C_A, C_B);

type type_motor_transistors is record
		A_n : std_logic;
		A_p : std_logic;
		B_n : std_logic;
		B_p : std_logic;
		C_n : std_logic;
		C_p : std_logic;
end record;

function set_transistors(path: in type_on_transistors_path; driver : in std_logic) return type_motor_transistors;

end package;

package  body  motor_auxiliary is

function set_transistors(path: in type_on_transistors_path; driver : in std_logic) return type_motor_transistors is
	variable  transistors : type_motor_transistors;
begin

	transistors.A_n := '0';
	transistors.A_p := '0';
	transistors.B_n := '0';
	transistors.B_p := '0';
	transistors.C_n := '0';
	transistors.C_p := '0';

	if path = A_B then
		transistors.A_p := driver;
		transistors.B_n := '1';
	elsif path = A_C then
		transistors.A_p := driver;	
		transistors.C_n := '1';
	elsif path = B_A then
		transistors.B_p := driver;
		transistors.A_n := '1';
	elsif path = B_C then
		transistors.B_p := driver;
		transistors.C_n := '1';
	elsif path = C_A then
		transistors.C_p := driver;
		transistors.A_n := '1';
	elsif path = C_B then
		transistors.C_p := driver;
		transistors.C_n := '1';
	end if;	
	
			
	return transistors;
end set_transistors;

end  motor_auxiliary;


library IEEE;
use work.motor_auxiliary.all;
use work.interface_data.all;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity motor_driver is

	port( 
		res : in std_logic;		
		clk : in std_logic;		
		i_req_speed : in std_logic_vector(7 downto 0);
		i_work_wave : in std_logic_vector(7 downto 0);
		i_motor_sensors_setup : type_motor_control_setup;
		i_enable  : in std_logic;

		o_motor_transistors : out type_motor_transistors
		);
end motor_driver;



architecture behaviour of motor_driver is
		
begin	


process(clk)


begin
		

	
		
		if rising_edge(clk)  then
			if res = '0' then	
			

			
			else
			
			end if;

			
		end if;
	

end  process;


end behaviour;