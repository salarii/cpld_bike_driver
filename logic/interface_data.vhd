library ieee;
use ieee.std_logic_1164.all;


package interface_data is

type transaction_type is (Read, Write);

type transaction_stage is ( t_Idle, t_Address, t_Data, t_Repeat, t_Conclude, t_Continue );

type type_to_i2c is record
	address : std_logic_vector(6 downto 0);
	enable : std_logic;		
	continue : std_logic;
	transaction : transaction_type;
end record;

type type_from_i2c is record	
	busy	: std_logic;
	done	: std_logic;
	error : std_logic;
end record;


end package;




