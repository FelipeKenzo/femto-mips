library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

entity rom_tb is
end rom_tb;

architecture tb of rom_tb is

    component rom is 
        generic (
            addrSize : natural := 16;
            wordSize : natural := 8;
            -- Timing
            Tread : time := 5000 ps;
            NA : string := "mrom.txt"
        );
        port (
            addr  : in  std_logic_vector(addrSize-1 downto 0);
            d_out : out std_logic_vector((wordSize*4)-1 downto 0)
        );
    end component;

    signal addr : std_logic_vector(15 downto 0) := x"0000";
    signal d_out : std_logic_vector(31 downto 0);

begin
    uut: rom generic map (
        addrSize => 16,
        wordSize => 8,
        NA => "sort.txt"
    )
    port map (
        addr => addr,
        d_out => d_out
    );

    process
    begin
        report "BOT.";

        addr <= x"0000";
        wait for 5 ns;
        assert(d_out = x"20040100") severity Error;

        wait for 10 ns;
        addr <= x"0004";
        wait for 5 ns;
        assert(d_out = x"8C050150") severity Error;

        wait for 10 ns;
        report "EOT.";
        wait;
    end process;

end tb;