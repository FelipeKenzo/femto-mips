library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signExtend_tb is
end entity;

architecture tb of signExtend_tb is

    component signExtend is
        generic (
            inSize  : natural := 16;
            outSize : natural := 32;
            -- Timing:
            Tgate : time := 250 ps
        );
        port (
            smol : in  std_logic_vector(inSize-1 downto 0);
            big  : out std_logic_vector(outSize-1 downto 0)
        );
    end component;

    signal smol : std_logic_vector(15 downto 0);
    signal big  : std_logic_vector(31 downto 0);

begin
    
    uut: signExtend port map (smol, big);

    process
    begin
        report "BOT.";

        -- Teste 1
        smol <= x"0BCD";
        wait for 500 ps;
        assert (big = x"00000BCD") report "Test 1 failed." severity Error;
        wait for 500 ps;

        -- Teste 2
        smol <= x"FABC";
        wait for 500 ps;
        assert (big = x"FFFFFABC") report "Test 2 failed. " & integer'image(to_integer(unsigned(big))) severity Error;
        wait for 500 ps;

        report "EOT.";
        wait;
    end process;
end tb;