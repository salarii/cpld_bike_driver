library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


package functions is

type type_uart_dev_status is record	
	flash : boolean;
	termistor : boolean;	
end record;


type type_uart_device is (flash_uart_dev, termistor_uart_dev);

function parity_check(data: in std_logic_vector(7 downto 0); size : in integer) return std_logic;

function uart_take(status: in type_uart_dev_status; dev : in type_uart_device) return boolean;

function uart_any_taken(status: in type_uart_dev_status) return boolean;


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

function uart_take(status: in type_uart_dev_status; dev : in type_uart_device) return boolean is
		
begin

		return (dev = flash_uart_dev and status.flash = True ) or
			   ( dev = termistor_uart_dev and status.termistor = True) or
			    (( status.flash  or status.termistor ) = False);
	
	
end uart_take;

function uart_any_taken(status: in type_uart_dev_status) return boolean is
begin 
	return ( status.flash  or status.termistor );
end uart_any_taken;



end  functions;