use work.interface_data.all;
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;



entity spi is
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
end spi;

architecture behaviour of spi is
	signal  received_internal : std_logic := '0';
	signal  busy_internal : std_logic := '0';
	
	
	signal bit_cnt_debug  : unsigned(3 downto 0);	
	signal cycle_cnt_debug  : unsigned(4 downto 0);
	signal shift_reg_debug  : unsigned(7 downto 0);
	signal ss : std_logic := '1';
	signal sck : std_logic := '1';
	signal mosi : std_logic := '1';
begin	


process(clk)

		constant period : integer := freq/bound;
		constant half : integer := period/2;
		constant separate : integer := period*2;
		
		variable cnt: integer  range separate downto 0;
		variable seq : integer  range 15 downto 0;
		
		variable bit_cnt : integer  range 15 downto 0;
				
		variable shift_reg_read: unsigned(7 downto 0) := (others => '0');
		variable shift_reg_write: unsigned(7 downto 0) := (others => '0');	
	

begin
		

		
	if rising_edge(clk)  then
			
		bit_cnt_debug  <= to_unsigned(bit_cnt, bit_cnt_debug'length); 
		cycle_cnt_debug  <= to_unsigned(cnt, cycle_cnt_debug'length);
		shift_reg_debug <= shift_reg_read;
		if res = '0' then
			
				busy_internal <= '0';
				received_internal <= '0';
				bit_cnt := 0;
				ss <= '1';

				mosi <= '1';
				sck <= '1';
				shift_reg_read := (others => '0');
				shift_reg_write := (others => '0');
		else
				if  received_internal = '1' then
					received_internal <= '0';
				end if;
				
				if i_enable = '1' or busy_internal = '1' then	
				
					ss <= '0';
					

					if  busy_internal = '0' then
						busy_internal <= '1';
			
						cnt := period-1;
						shift_reg_read := (others => '0');
						bit_cnt := 0;
						
							
					else
						if cnt = half  then 
							
							
							if bit_cnt = 8  then
								cnt:= separate;
								bit_cnt := 0;
								busy_internal <= '0';
								o_data <= std_logic_vector(shift_reg_read);
								received_internal <= '1';
								
							else

								if bit_cnt = 0 then
									if i_enable = '1' then
										shift_reg_write := unsigned(i_data);
									end if;

							
								end if;
								sck <= '0';
								mosi <= shift_reg_write(7);							

							end if;
						elsif cnt = 0  then 
							sck <= '1';
							shift_reg_read := shift_left(shift_reg_read, 1);
							shift_reg_write := shift_left(shift_reg_write, 1);
							
							shift_reg_read(0) := i_spi.miso;
							
							cnt:= period;
							bit_cnt := bit_cnt + 1;

						end if;
						
						cnt := cnt - 1;
					end if;	
					
				else
					ss <= '1';
					mosi <= '1';
					sck <= '1';
					busy_internal <= '0';
				end if;
				
				
				
		end if;
				
	end if;
	

end  process;


process(busy_internal,received_internal,ss,sck,mosi)
begin
	o_busy <= busy_internal;
	o_received <= received_internal;
	o_spi.mosi <= mosi;
	o_spi.ss <= ss;
	o_spi.sck <= sck;
end process;



end behaviour;
