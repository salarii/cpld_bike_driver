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
			
			io_data : inout std_logic_vector(7 downto 0);
			i_miso : in std_logic;
			i_transaction : transaction_type;
			i_enable : in std_logic;
			i_stall : in std_logic;
			
			o_sck : out std_logic;
			o_ss : out std_logic;	
			o_mosi : out std_logic;
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
begin	


process(clk)



		constant period : integer := freq/bound;
		constant half : integer := period/2;
		constant separate : integer := period*2;
		
		variable cnt: integer  range separate downto 0;
		variable seq : integer  range 15 downto 0;
		
		variable bit_cnt : integer  range 11 downto 0;
				
		variable shift_reg: unsigned(7 downto 0);-- := (others => '0');
		

begin
		

		
	if rising_edge(clk)  then
			
		bit_cnt_debug  <= to_unsigned(bit_cnt, bit_cnt_debug'length); 
		cycle_cnt_debug  <= to_unsigned(cnt, cycle_cnt_debug'length);
		shift_reg_debug <= shift_reg;
		if res = '0' then
			
				busy_internal <= '0';
				received_internal <= '0';
				bit_cnt := 0;
				o_ss <= '1';
				io_data <= (others => 'Z');
				o_mosi <= '1';
				o_sck <= '1';
				shift_reg := (others => '0');
		else
				if  received_internal = '1' then
					received_internal <= '0';
				end if;
				
				if i_enable = '1' then	
				
					o_ss <= '0';
					if  busy_internal = '0' then
						busy_internal <= '1';
			
						cnt := period-1;
						shift_reg := (others => '0');
						bit_cnt := 0;
					else
						if cnt = half  then 
							o_sck <= '0';
							if i_transaction = Write then

								if bit_cnt = 0 then
									shift_reg := unsigned(io_data);	
								end if;
								o_mosi <= shift_reg(0);							
							elsif i_transaction = Read then
					--o_data <= std_logic_vector(shift_reg);
					--shift_reg(7) := i_rx;
							end if;	

						elsif cnt = 0  then 
							o_sck <= '1';
								
							if bit_cnt = 7  then
								--o_data <= std_logic_vector(shift_reg(7 downto 0));
								cnt:= separate;
								bit_cnt := 0;
							else
								shift_reg := shift_right(shift_reg, 1);
								cnt:= period;
								bit_cnt := bit_cnt + 1;
							end if;
	

						end if;
						
						cnt := cnt - 1;
					end if;	
					
				else
					io_data <= (others => 'Z');
					o_ss <= '1';	
					o_mosi <= '1';
					o_sck <= '1';
				end if;
				
				
				
		end if;
				
	end if;
	

end  process;

process(busy_internal,received_internal)
begin
	o_busy <= busy_internal;
	o_received <= received_internal;
end process;



end behaviour;
