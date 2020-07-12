-- /////////////////////////
-- // Regfile with timing //
-- /////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
    generic (
        -- Timing
        Tread  : time := 4000 ps;
        Twrite : time := 4000 ps
    );
    port (
        Read1, Read2 : in std_logic_vector(4 downto 0);
        Write1       : in std_logic_vector(4 downto 0);
        WriteData    : in std_logic_vector(31 downto 0);
        RegWrite, rst, clk : in std_logic;
        Data1, Data2  : out std_logic_vector(31 downto 0)
    );
end regfile;

architecture timing of regfile is
    type bank_type is array (31 downto 0) of std_logic_vector(31 downto 0);
    signal data: bank_type;

    signal aux1, aux2, waux : std_logic_vector(31 downto 0);

begin
    process (clk, rst)
	begin
		if rst = '1' then 
			data <= (others => (others => '0'));
			data(28) <= X"00000200";
			data(29) <= X"0000FFFF";
		elsif rising_edge(clk) then 
			if RegWrite = '1' and Write1 /= "00000" then
				data(to_integer(unsigned(Write1))) <= WriteData after Twrite;
			end if;
		end if;
	end process;

	aux1 <= data(to_integer(unsigned(Read1)));
	aux2 <= data(to_integer(unsigned(Read2)));

	Data1 <= aux1 after Tread;
	Data2 <= aux2 after Tread;

end timing;