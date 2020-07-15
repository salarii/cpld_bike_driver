library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package interface_data is

type transaction_type is (Read, Write, Erase);

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


type type_to_spi is record	
	miso : std_logic;
end record;

type type_from_spi is record	
	sck : std_logic;
	ss : std_logic;	
	mosi : std_logic;
end record;

type type_motor_control_setup is record
	hal : std_logic;
	enable : std_logic;		
			
	hal_data : std_logic_vector(2 downto 0);
end record;


type type_control_box_setup is record
	hal : std_logic;
	enable : std_logic;		
	temperature : std_logic;
	manual : std_logic;	
	pulse_trigger : unsigned(7 downto 0);	
	req_speed_motor : unsigned(7 downto 0);
	
end record;

type control_data_type is (
	 t_Kmp, t_Kmd, t_Kmi, t_Ktp, t_Ktd, t_Kti );


type type_control_box_data is record
	hal : unsigned(15 downto 0);	
	temperature : control_data_type;	
	-- neutral pid motor
	-- neutral temperature
	
end record;

end package;


type type_settings_pid is record
		Kp : signed(15 downto 0) := x"ffe1";
		Ki : signed(15 downto 0) := x"001f";
		Kd : signed(15 downto 0) := x"000f";
		
end record;

type type_settings_pd is record
		Kp : signed(15 downto 0) := x"009d";
		Kd  : signed(15 downto 0) := x"0027";
		
end record;

type type_settings_control_box is record


max_speed : unsigned(15 downto 0):= x"0200";
max_temperature : unsigned(15 downto 0):= x"0200";

offset_speed : unsigned(15 downto 0) := x"0280";
offset_term : unsigned(15 downto 0) := x"0000";

end record;


	variable setting_val : unsigned(23 downto 0);
	variable setting_id : unsigned(7 downto 0);		
		
		
	address_flash <= shift_left(setting_id, 4);
		
		
			
	if setting_id = x"00" then
		settings_control_box.settings_pid.Kp <= signed(setting_val(15 downto 0));
	elsif setting_id = x"01" then   
		settings_control_box.settings_pid.Ki <= signed(setting_val(15 downto 0));
	elsif setting_id = x"02" then   
		settings_control_box.settings_pid.Kd <= signed(setting_val(15 downto 0));
	elsif setting_id = x"03" then   
		settings_control_box.settings_pd.Kp <= signed(setting_val(15 downto 0));
	elsif setting_id = x"04" then  
		settings_control_box.settings_pid.Kd <= signed(setting_val(15 downto 0)); 
	elsif setting_id = x"05" then   
		settings_control_box.max_speed <= signed(setting_val(15 downto 0));
	elsif setting_id = x"06" then   
		settings_control_box.max_temperature <= signed(setting_val(15 downto 0));
	elsif setting_id = x"07" then   
		settings_control_box.offset_speed <= signed(setting_val(15 downto 0));
	elsif setting_id = x"08" then  
		settings_control_box.offset_term <= signed(setting_val(15 downto 0));
	
	end if;
