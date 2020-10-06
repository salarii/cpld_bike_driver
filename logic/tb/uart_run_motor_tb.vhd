

library IEEE;
use IEEE.std_logic_1164.all;

use work.interface_data.all;
use ieee.numeric_std.all;
use work.motor_auxiliary.all;

entity uart_run_motor_tb is
end uart_run_motor_tb;

architecture t_behaviour of uart_run_motor_tb is

		
		component control_unit is
			port(
      clk : in  std_logic;
      res : in  std_logic;
      
      
      i_flash_spi : in type_to_spi;
      i_hal_data : in std_logic_vector(2 downto 0);
        
      i_pedal_imp : in std_logic;		
      i_brk_1 : in std_logic;
      i_brk_2 : in std_logic;

      i_control_mode : in std_logic;

      i_busy_uart : in std_logic;
      i_from_uart : in std_logic_vector(7 downto 0);
      i_received_uart : in std_logic;
      
      i_adc_spi : in type_to_spi;
        
        
      o_flash_spi : out type_from_spi;
        
      o_adc_spi : out type_from_spi;
      
      o_to_uart : out std_logic_vector(7 downto 0);
      o_en_uart : out std_logic;
      o_motor_transistors : out type_motor_transistors;
      leds : out std_logic_vector(3 downto 0)
			);
		end component control_unit;

	
		component uart is
			generic ( 
				freq : integer;
				bound : integer
				);
			
		port(
			res : in std_logic;		
			clk : in std_logic;	
			
			i_data : in std_logic_vector(7 downto 0);
			i_enable : in std_logic;
			i_rx : in std_logic;	
			
			o_data : out std_logic_vector(7 downto 0);	
			o_error : out std_logic;
			o_received : out std_logic;
			o_busy	: out std_logic;
			o_tx	: out  std_logic
			);
		end component uart;
	 

	 
	 
	 	signal leds : std_logic_vector(3 downto 0);
	 
		signal pedal_imp : std_logic;	
		signal res : std_logic;	
		signal clk : std_logic;		
		signal bus_clk	: std_logic;
		signal bus_data :  std_logic;
		signal o_slave_data :  std_logic;
		signal o_data_en :  std_logic;
		signal i_slave_data :  std_logic;

		signal ready	: std_logic;
		
		signal motor_transistors : type_motor_transistors;
		signal impulse : std_logic;
		constant clk_period : time := 100 ns;
		constant hal_period : time := 500 us;
		
		signal data : std_logic_vector(15 downto 0);
		signal address : std_logic_vector(6 downto 0);
		signal hal_data : std_logic_vector(2 downto 0);
		
		signal enable : std_logic;		
		signal busy	: std_logic;
		signal done	: std_logic;
		signal error : std_logic;
		signal continue : std_logic;
					
			
		signal to_uart : std_logic_vector(7 downto 0);
		signal from_uart : std_logic_vector(7 downto 0);
		signal received_uart : std_logic; 
		signal busy_uart : std_logic;
		signal en_uart : std_logic;
		signal tx_uart : std_logic;
		signal rx_uart : std_logic;
		signal err_uart : std_logic;		

		signal to_spi : type_to_spi;
		signal from_spi : type_from_spi;
		signal to_adc_spi : type_to_spi;
		signal from_adc_spi : type_from_spi;
	begin	
		

		
		
		control_func: control_unit
		port map (
				res => res,
				clk => clk,
				
				i_flash_spi => to_spi,
				o_flash_spi => from_spi,
				
				i_adc_spi => to_adc_spi,
				o_adc_spi => from_adc_spi,
        i_pedal_imp => pedal_imp,
				i_hal_data => hal_data,

        i_brk_1 => '1',
        i_brk_2 => '1',

        i_control_mode => '1',

				leds => leds,
		
				i_received_uart => received_uart,
				i_from_uart => from_uart,
				i_busy_uart => busy_uart,
				o_to_uart => to_uart,
				o_en_uart => en_uart,
				o_motor_transistors => motor_transistors
				);

 
		to_display : uart
		generic map (
		 	freq => 100,
			bound => 10 )
			
		port map (
			res => res,		
			clk => clk,
			i_data => to_uart,
			i_enable => en_uart,		
			i_rx => rx_uart,	
			o_data => from_uart,
			o_error => err_uart,
			o_received => received_uart,
			o_busy => busy_uart,
			o_tx => tx_uart
			);

		process
			begin
				
	
				--res <= '0';	
				res <= '1';
				to_spi.miso <= '1';
to_adc_spi.miso <= '1';
				wait for 1200 us;				
				
        pedal_imp <= '0';
				-- run motor
				-- 0x05  0 1010 0000 0
				-- 0x80  0 0000 0001 1
				-- 0x30  0 0000 1100 0
				-- 0x40  0 0000 0010 1
				-- 0x01  0 1000 0000 1
				-- 0x01  0 1000 0000 1
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 6 us;
				rx_uart <= '1';
				wait for 5 us;
				
				rx_uart <= '0';
				wait for 8 us;
				rx_uart <= '1';
				wait for 6 us;

				rx_uart <= '0';
				wait for 5 us;
				rx_uart <= '1';
				wait for 2 us;
				rx_uart <= '0';
				wait for 3 us;
				rx_uart <= '1';
				wait for 6 us;
		

				rx_uart <= '0';
				wait for 7 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 6 us;		


				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '1';
				wait for 1 us;
				rx_uart <= '0';
				wait for 7 us;
				rx_uart <= '1';
				wait for 6 us;	

				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '0';
				wait for 1 us;
				rx_uart <= '0';
				wait for 7 us;
				rx_uart <= '0';
				wait for 1 us;	
				rx_uart <= '1';
				wait for 6 us;	


				wait for 520 us;

				wait;
			end process;
		process	
		begin
				res <= '1';
	

				case hal_data is
						when "101" =>  
							hal_data<="100";
						when "100"  =>  
							hal_data<="110";
						when "110"  =>  
							hal_data<="010";
						when "010"  =>  
							hal_data<="011";
						when "011"  =>  
							hal_data<="001";
						when "001"  =>  
							hal_data<="101";
						when others => 
							hal_data<="100";
						end case;

			
			wait for hal_period;
				
		end process;
		
impulse_process :
process
begin
	impulse  <=  '0';
	wait  for 10 us;
	impulse  <=  '1';
	wait  for 10 us;
end  process;


clk_process :
process
begin
	clk  <=  '0';
	wait  for clk_period/2;
	clk  <=  '1';
	wait  for clk_period/2;
end  process;


			
			
	i_slave_data <= bus_data;
	bus_data <=  o_slave_data when o_data_en = '1' else  'Z'; 

			
end t_behaviour;