

library IEEE;
use IEEE.std_logic_1164.all;


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


package motor_auxiliary is

type type_on_transistors_path is (No_path, A_B, A_C, B_A, B_C, C_A, C_B);

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
		transistors.B_n := '1';
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
		i_req_speed : in unsigned(7 downto 0);
		i_work_wave : in std_logic;
		i_motor_control_setup : type_motor_control_setup;

		o_motor_transistors : out type_motor_transistors
		);
end motor_driver;



architecture behaviour of motor_driver is
	constant size : integer := 12;
	constant max_steps_per_cycle : integer := 2048;
	
	constant base_cycle : unsigned(size - 1  downto 0) := to_unsigned(max_steps_per_cycle,size);
	
	constant generate_no_hal_control : boolean  := true;
-- ????? use  other  ways, consider it  later  ???
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
		
		
		signal divisor	: unsigned(size - 1  downto 0);
		signal quotient : unsigned(size - 1  downto 0);	
		signal o_valid : std_logic;
		signal enable_div : std_logic;
		
		
		signal debug_tick : unsigned(9  downto 0);
		signal debug_cnt : unsigned(9  downto 0);
		
begin	

generate_no_hal_controel: if generate_no_hal_control = true generate
		module_div: div
		generic map(
		 size => size)
		port map (
		res => res,
		clk => clk,
		i_enable => enable_div,
		i_divisor => divisor,
		i_divident	=> base_cycle,
		o_valid => o_valid,
		o_quotient => quotient);
end generate;  
	process(clk)
		type type_status is (initialise_control, active_control);
		
		
		constant tick_period : integer := 20;
		
		variable status : type_status := initialise_control;
		variable cnt : integer range max_steps_per_cycle downto 0 := 0;
		variable tick_cnt  : integer range tick_period downto 0 := 0;
		
		variable transistors_path : type_on_transistors_path;
	begin
			
		debug_tick <=  to_unsigned(tick_cnt, debug_tick'length);
		debug_cnt <= to_unsigned(cnt, debug_tick'length);
			
			
		if rising_edge(clk)  then
			if res = '0' then	
				status := initialise_control;
				transistors_path := No_path;
				o_motor_transistors <= set_transistors(No_path, '0');
			else
				if i_motor_control_setup.enable = '1' then
					if i_motor_control_setup.hal = '1' then
						

					else
						divisor(7 downto 0) <= i_req_speed;
						divisor(size -1 downto 8) <= (others => '0');
						if status = initialise_control then
							tick_cnt := tick_period-1;							
							status := active_control;
							enable_div <= '1';	
							transistors_path := No_path;
							cnt := 0;
						elsif status = active_control then
							if cnt = 0 then
								case transistors_path is
								  when No_path => 
									 o_motor_transistors <= set_transistors(No_path, '0');
								     transistors_path := A_B;
								  when A_B =>  
									 o_motor_transistors <= set_transistors(transistors_path, i_work_wave);
								  	 transistors_path := A_C;
								  when A_C  =>  
									 o_motor_transistors <= set_transistors(transistors_path, i_work_wave);
								  	 transistors_path := B_C;
								  when B_C  =>  
									 o_motor_transistors <= set_transistors(transistors_path, i_work_wave);
								  	 transistors_path := B_A;
								  when B_A  =>  
									 o_motor_transistors <= set_transistors(transistors_path, i_work_wave);
								  	 transistors_path := C_A;
								  when C_A  =>  
									 o_motor_transistors <= set_transistors(transistors_path, i_work_wave);
								  	 transistors_path := C_B;
								  when C_B  =>  
									 o_motor_transistors <= set_transistors(transistors_path, i_work_wave);
								  	 transistors_path := A_B;
								  when others => 
									 o_motor_transistors <= set_transistors(transistors_path, i_work_wave);
								  	 transistors_path := No_path;
								end case;
							
				
							end if;
						
							if tick_cnt = 0 then
								if cnt = 0 then
									cnt := to_integer(quotient);
								else	
									cnt := cnt -1;
								end if;	
							
								
								enable_div <= '1';
								tick_cnt := tick_period-1;
							else
								enable_div <= '0';
								tick_cnt := tick_cnt - 1;
							
							end if;
						
						end if;



					end if;
				end if;
			
				
			end if;
	
				
		end if;
		
	
	end  process;


end behaviour;