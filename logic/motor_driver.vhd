

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

--impure function set_transistors(path: in type_on_transistors_path; driver : in std_logic) return type_motor_transistors;

end package;

package  body  motor_auxiliary is


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
		i_motor_control_setup : in type_motor_control_setup;

		o_motor_transistors : out type_motor_transistors
		);
end motor_driver;



architecture behaviour of motor_driver is
	constant size : integer := 12;
	constant max_steps_per_cycle : integer := 2048;
	
	constant base_cycle : unsigned(size - 1  downto 0) := to_unsigned(max_steps_per_cycle,size);
	
	constant generate_no_hal_control : boolean  := true;

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
		
		
		signal motor_transistors : type_motor_transistors := ('0','0','0','0','0','0');
begin	

generate_no_hal_controler: if generate_no_hal_control = true generate
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
 		procedure set_transistors(path: in type_on_transistors_path) is
	
		begin

			motor_transistors.A_n <= '0';
			motor_transistors.A_p <= '0';
			motor_transistors.B_n <= '0';
			motor_transistors.B_p <= '0';
			motor_transistors.C_n <= '0';
			motor_transistors.C_p <= '0';

			if path = A_B then
				motor_transistors.A_p <= '1';
				motor_transistors.B_n <= '1';
			elsif path = A_C then
				motor_transistors.A_p <= '1';	
				motor_transistors.C_n <= '1';
			elsif path = B_A then
				motor_transistors.B_p <= '1';
				motor_transistors.A_n <= '1';
			elsif path = B_C then
				motor_transistors.B_p <= '1';
				motor_transistors.C_n <= '1';
			elsif path = C_A then
				motor_transistors.C_p <= '1';
				motor_transistors.A_n <= '1';
			elsif path = C_B then
				motor_transistors.C_p <= '1';
				motor_transistors.B_n <= '1';
			end if;	
	
		
		end procedure;

		type type_status is (initialise_control, active_control);
		
		
		constant tick_period : integer := 300;
		
		variable status : type_status := initialise_control;
		variable cnt : integer range max_steps_per_cycle downto 0 := 0;
		variable tick_cnt  : integer range tick_period downto 0 := 0;
		
		variable transistors_path : type_on_transistors_path;
	begin
			
			
			
		if rising_edge(clk)  then
			if res = '0' then	
				status := initialise_control;
				transistors_path := No_path;
				set_transistors(No_path);
			else
				if i_motor_control_setup.enable = '1' then
					if i_motor_control_setup.hal = '1' then
						  case i_motor_control_setup.hal_data is
									when "101" =>  
									     set_transistors(A_B);
								  	when "100"  =>  
											set_transistors(A_C);
								  	when "110"  =>  
									     set_transistors(B_C);
								  	when "010"  =>  
									     set_transistors(B_A);
								  	when "011"  =>  
								    	 set_transistors(C_A);
								  	when "001"  =>  
									     set_transistors(C_B);
								  	when others => 
									     set_transistors(transistors_path);
								    end case;

					else
						divisor(7 downto 0) <= i_req_speed;
						divisor(size -1 downto 8) <= (others => '0');
						if status = initialise_control then
							tick_cnt := tick_period-1;	
							transistors_path := No_path;
							set_transistors(No_path);
							
							if 	i_req_speed > 0 then					
								status := active_control;
								enable_div <= '1';	

								cnt := max_steps_per_cycle /100;
							end if;
						elsif status = active_control then
							
						
							if tick_cnt = 0 then
								if cnt = 0 then
								  case transistors_path is
								  	when No_path => 
								   	  set_transistors(No_path);
									     transistors_path := A_B;
									when A_B =>  
									     set_transistors(transistors_path);
								  	     transistors_path := A_C;
								  	when A_C  =>  
							      	  set_transistors(transistors_path);
								  	     transistors_path := B_C;
								  	when B_C  =>  
									     set_transistors(transistors_path);
								  	     transistors_path := B_A;
								  	when B_A  =>  
									     set_transistors(transistors_path);
								  	     transistors_path := C_A;
								  	when C_A  =>  
								    	  set_transistors(transistors_path);
								  	     transistors_path := C_B;
								  	when C_B  =>  
									     set_transistors(transistors_path);
								  	     transistors_path := A_B;
								  	when others => 
									     set_transistors(transistors_path);
								  	     transistors_path := No_path;
								    end case;

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
				else
					set_transistors(No_path);
					status := initialise_control;
				end if;
			
				
			end if;
	
				
		end if;
		
	
	end  process;
	process(motor_transistors,i_work_wave)
 		function drop_wave_on_transistors( transistors : type_motor_transistors; wave : std_logic) return type_motor_transistors  is
			variable motor_transistors_internal : type_motor_transistors;
		begin
			
			motor_transistors_internal.A_n := not(transistors.A_n );
			motor_transistors_internal.B_n := not(transistors.B_n );
			motor_transistors_internal.C_n := not(transistors.C_n );			
			motor_transistors_internal.A_p := not(transistors.A_p and wave);
			motor_transistors_internal.B_p := not(transistors.B_p and wave);
			motor_transistors_internal.C_p := not(transistors.C_p and wave);	
			return motor_transistors_internal;
		end function;
	begin
		o_motor_transistors <= drop_wave_on_transistors(motor_transistors,i_work_wave);
	end  process;
end behaviour;