library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


package functions is

type type_uart_dev_status is record	
	flash : boolean;
	termistor : boolean;	
	motor : boolean;	
end record;


type type_uart_device is (flash_uart_dev, termistor_uart_dev, motor_uart_dev);

function parity_check(data: in std_logic_vector(7 downto 0); size : in integer) return std_logic;

function uart_any_taken(status: in type_uart_dev_status) return boolean;

function revert_byte(byte: in std_logic_vector(7 downto 0) ) return std_logic_vector; 

end package;

package  body  functions is

function parity_check(data: in std_logic_vector(7 downto 0); size : in integer) return std_logic is
	variable  parity : std_logic;
begin
	for i in 0 to size -1 loop
										
		if i = 0  then
			parity := std_logic(data(i));
		else
			parity := std_logic(data(i))  xor parity;	
		end	if;
								
	end loop;
	
	return parity;
end parity_check;


function uart_any_taken(status: in type_uart_dev_status) return boolean is
begin 
	return ( status.flash  or status.termistor or status.motor );
end uart_any_taken;

function revert_byte(byte: in std_logic_vector(7 downto 0) ) return std_logic_vector is
	variable reverted : std_logic_vector(7 downto 0);
begin 

	for i in 0 to 7 loop
										
		reverted(i) := byte(7 - i);
								
	end loop;
	
	return reverted;
end revert_byte;



end  functions;