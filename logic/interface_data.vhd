library ieee;
use ieee.std_logic_1164.all;


package interface_data is

type transaction_type is (Read, Write, Index);

type transaction_stage is ( Idle, Address, Reg_Addr, Data_H, Data_L, Repeat, Conclude );

type type_to_i2c is record
	address : std_logic_vector(6 downto 0);
	reg_addr : std_logic_vector(1 downto 0);
	enable : std_logic;		
	transaction : transaction_type;
end record;

type type_from_i2c is record	
	busy	: std_logic;
	done	: std_logic;
	error : std_logic;
end record;


end package;




