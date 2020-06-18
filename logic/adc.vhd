

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.interface_data.all;



entity adc is
	generic (
		adc_mesur_per_sec	: integer;	
		freq : integer;
		spi_bound : integer);

	port(
		clk : in  std_logic;
		res : in  std_logic;
		
		i_channel : in unsigned( 2 downto 0 );
		
		i_spi : in type_to_spi;
		o_measurement : out unsigned( 15 downto 0 );
		o_spi : out type_from_spi

		);
end adc;

architecture behaviour of adc is

		component spi is
			generic ( 
				freq : integer;
				bound : integer
				);
				
			port(
					res : in std_logic;		
					clk : in std_logic;	
					
					io_data : inout std_logic_vector(7 downto 0);
					i_spi : in type_to_spi;
					i_enable : in std_logic;
					
					o_spi : out type_from_spi;
					o_received : out std_logic;
					o_busy	: out std_logic
				);
		end component spi;

		constant wait_cnt : integer := freq/adc_mesur_per_sec;

		signal enable_uart  : std_logic;
		
		signal channels_data : std_logic_vector(39 downto 0);


		signal data_spi : std_logic_vector(7 downto 0):= (others => 'Z');
		signal busy_spi : std_logic;
		signal en_spi : std_logic;
		signal received_spi : std_logic;
begin	
	
		spi_function : spi
			generic map ( 
		 	freq => freq,
			bound => spi_bound )
				
			port map(
					res => res,		
					clk => clk,
					
					io_data => data_spi,
					i_spi => i_spi,
					i_enable => en_spi,
					
					o_spi => o_spi,
					o_received =>received_spi,
					o_busy	=> busy_spi
				);
	
	process(clk)
		variable uart_sized : boolean := False; 
	
		type state_type is (wait_adc, setup_adc,read_adc_h,read_adc_l);
		

		variable cnt : integer := 0;			
		variable channel_cnt : integer  range 3 downto 0 := 0;
		
		variable state : state_type := wait_adc;
		
		
		variable time_tmp : unsigned(15 downto 0);
	begin

		if rising_edge(clk)  then
			if res = '0' then
				cnt :=0;
				channel_cnt := 0;
			else
				if cnt = wait_cnt then
					cnt := 0;
				else
					cnt := cnt + 1;
				end if;
			
				if state = setup_adc then
					data_spi <=(others => '0');
					data_spi(0) <= '1';
					
					if received_spi = '1' then
						state := read_adc_h;
					end if;
					en_spi <= '1';
					if busy_spi = '1' then
						en_spi <= '0';
					end if;
					
				elsif state = read_adc_h then
					data_spi <=(others => '0');
					data_spi(7) <='1';
					data_spi(6 downto 4) <= std_logic_vector(to_unsigned(channel_cnt, 3));
					if received_spi = '1' then
						state := read_adc_l;
					end if;
					en_spi <= '1';
					if busy_spi = '1' then
						en_spi <= '0';
					end if;
					
				elsif state = read_adc_l then
					if received_spi = '1' then
						if channel_cnt = 3 then
							channel_cnt :=  0;
							state := wait_adc;
						else
							state := setup_adc;
							channel_cnt := channel_cnt +1;
						end if;
						state := read_adc_l;
					end if;
					en_spi <= '1';
					if busy_spi = '1' then
						en_spi <= '0';
					end if;
				
				end if;			
			
			end if;

		end if;

	end process;


	
end behaviour;