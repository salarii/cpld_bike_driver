library ieee;
use ieee.std_logic_1164.all;


package interface_data is

type transaction_type is (Read, Write, Index);

type transaction_stage is ( Idle, Address, Reg_Addr, Data_H, Data_L, Repeat, Conclude );

type transaction_data is record
	data : std_logic_vector(15 downto 0);
	address : std_logic_vector(6 downto 0);
	reg_addr : std_logic_vector(1 downto 0);
	enable : std_logic;		
	busy	: std_logic;
	done	: std_logic;
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




