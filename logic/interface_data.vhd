library ieee;
use ieee.std_logic_1164.all;


package interface_data is

type transaction_type is (Read, Write);

type transaction_stage is (Idle, Address, Data, Repeat);

type transaction_data is record
	data : std_logic_vector(7 downto 0);
	address : std_logic_vector(6 downto 0);
	enable : std_logic;		
	busy	: std_logic;
	error : std_logic;
	transaction : transaction_type;
end record;

type transaction_simp_data is record
	data : std_logic_vector(7 downto 0);
	enable : std_logic;		
	busy	: std_logic;
	error : std_logic;
	transaction : transaction_type;
end record;

end package;




