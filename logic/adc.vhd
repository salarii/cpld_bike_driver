

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
		o_measurement : out unsigned( 9 downto 0 );
		o_spi : out type_from_spi;
		o_temp : out unsigned( 9 downto 0 );
		o_throttle : out unsigned( 9 downto 0 )
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
			
			i_data : in std_logic_vector(7 downto 0);
			i_spi : in type_to_spi;
			i_enable : in std_logic;
			
			o_data : out std_logic_vector(7 downto 0);
			o_spi : out type_from_spi;
			o_received : out std_logic;
			o_busy	: out std_logic
				);
		end component spi;

		component poly is

		
			port(
				res : in std_logic;
				clk : in std_logic;
				i_enable : in std_logic;
				i_val	: in  std_logic_vector(9  downto 0);
				o_calculated : out std_logic;
				o_temp : out std_logic_vector(9  downto 0)
				);
		end component;

		component low_pass is
			port(
				res : in std_logic;		
				clk : in std_logic;		
				i_enable : in std_logic;		
				
				i_no_filter_val  : in unsigned(15 downto 0);
				i_alfa : in  unsigned(7 downto 0);
				o_filtered : out  unsigned(15 downto 0)
				);
		end component low_pass;

		constant wait_cnt : integer := freq/adc_mesur_per_sec;

		signal enable_uart  : std_logic;
		
		signal channels_data : unsigned(39 downto 0):= (others => '0');
		
		signal throttle  : unsigned( 9 downto 0 );
		
		signal poly_enable : std_logic;	
		signal poly_calculated : std_logic;	
		signal poly_temperature : unsigned(9  downto 0) := (others => '0');
		signal poly_temp_out : unsigned(9  downto 0) := (others => '0');


		signal i_data_spi : std_logic_vector(7 downto 0):= (others => '0');
		signal o_data_spi : std_logic_vector(7 downto 0);
		signal busy_spi : std_logic;
		signal en_spi : std_logic;
		signal received_spi : std_logic;
		signal poly_in : unsigned( 9 downto 0 );
		signal enable_filter : std_logic := '0';
		signal filtered : unsigned(15  downto 0);
begin	
	
		spi_function : spi
			generic map ( 
		 	freq => freq,
			bound => spi_bound )
				
			port map(
					res => res,		
					clk => clk,
					
					i_data => i_data_spi,
					i_spi => i_spi,
					i_enable => en_spi,
					
					o_data => o_data_spi,
					o_spi => o_spi,
					o_received =>received_spi,
					o_busy	=> busy_spi
				);
	
		module_poly: poly
		port map (
				res => res,
				clk => clk,
				i_enable => poly_enable,
				i_val	=> std_logic_vector(poly_in),
				o_calculated => poly_calculated,
				unsigned(o_temp) => poly_temp_out
			);	
	
	
		module_filter : low_pass 
				
		port map(
			res => res,
			clk => clk,	
			i_enable =>enable_filter,
				
			i_no_filter_val(9  downto 0) => poly_temperature,
			i_no_filter_val(15 downto 10) =>(others =>'0'),
			i_alfa => x"D0",
			o_filtered => filtered
			);
	
	process(clk)
		variable uart_sized : boolean := False; 
	
		type state_type is (wait_adc, setup_adc,calculate_temperature,read_adc_h,read_adc_l);
		

		variable cnt : integer := 0;			
		variable channel_cnt : integer  range 3 downto 0 := 0;
		
		variable state : state_type := wait_adc;
		
		variable data : unsigned(9 downto 0);
		variable time_tmp : unsigned(15 downto 0);
	begin

		if rising_edge(clk)  then
			if res = '0' then
				cnt :=0;
				channel_cnt := 0;
				channels_data <= (others => '0');
				enable_filter <= '0';
			else
			
			
				case i_channel is
				  when "000" =>   o_measurement <= channels_data( 9 downto 0 );
				  when "001" =>   o_measurement <= channels_data( 19 downto 10 );
				  when "010" =>   o_measurement <= channels_data( 29 downto 20 );
				  when "011" =>   o_measurement <= channels_data( 39 downto 30 );
				  when others => o_measurement <= (others => '0');
				end case;
			
			
			
				if cnt = wait_cnt then
					cnt := 0;
					state := setup_adc;
				else
					cnt := cnt + 1;
				end if;
			
				if state = setup_adc then
					i_data_spi <=(others => '0');
					i_data_spi(0) <= '1';
					
					if received_spi = '1' then
						state := read_adc_h;
					end if;
					en_spi <= '1';
					
				elsif state = read_adc_h then
					i_data_spi <=(others => '0');
					i_data_spi(7) <='1';
					i_data_spi(6 downto 4) <= std_logic_vector(to_unsigned(channel_cnt, 3));
					if received_spi = '1' then
						state := read_adc_l;
						data( 9 downto 8) := unsigned(o_data_spi(1 downto 0));
					end if;
					
				elsif state = read_adc_l then
					if received_spi = '1' then
						data(7 downto 0) := unsigned(o_data_spi);
						case channel_cnt is
					 		when 0 =>  channels_data( 9 downto 0 ) <= data;
				  					   throttle <= data;
				  			when 1 =>  channels_data( 19 downto 10 ) <= data;
				  			when 2 =>  channels_data( 29 downto 20 ) <= data;
				  			when 3 =>  channels_data( 39 downto 30 ) <= data;
				  			when others => channels_data <= (others => '0');
						end case;


						state := calculate_temperature;
						if channel_cnt = 1 then
							poly_in <= channels_data( 19 downto 10 );
							poly_enable <= '1';	
						elsif  channel_cnt = 2 then
							poly_in <= channels_data( 29 downto 20 );
							poly_enable <= '1';	
						end if;
					else
						if busy_spi = '1' then
							en_spi <= '0';
						end if;
					end if;
				elsif state = calculate_temperature then

						if channel_cnt = 3 then
							channel_cnt :=  0;
							state := wait_adc;
							o_temp <= filtered(9 downto 0);
						else
							if channel_cnt = 1 or channel_cnt = 2  then
							
								if poly_enable = '1' then
									poly_enable <= '0';
	
								elsif poly_calculated = '1' then	
									if channel_cnt = 1 then
										poly_temperature <= poly_temp_out;
									elsif channel_cnt = 2 then
										if unsigned(poly_temperature) < unsigned(poly_temp_out) then
											poly_temperature <= poly_temp_out;
										end if;
										enable_filter <= '1';
									end if;
									
										
								end if;
								
								if enable_filter = '1' then
									state := setup_adc;
									channel_cnt := channel_cnt +1;
									enable_filter <= '0';
								end if;
							else
								state := setup_adc;
								channel_cnt := channel_cnt +1;							
							end if;

						end if;

				end if;			
			
			end if;

		end if;

	end process;

	process(throttle)
	begin
		o_throttle <= throttle;	
		
	end process;
	
end behaviour;