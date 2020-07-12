-- ////////////////////////////
-- // Comparator with timing //
-- ////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator_tb is
end entity;

architecture tb of comparator_tb is

    component comparator is
        generic (
            wordSize : natural := 32;
            -- Timing
            Tprop : time := 250 ps
        );
        port (
            A, B  : in  std_logic_vector(wordSize-1 downto 0);
            equal : out std_logic 
        );
    end component;

    signal A, B : std_logic_vector(31 downto 0);
    signal equal : std_logic;

begin

    uut: comparator port map (A, B, equal);

    process
    begin
        report "BOT";

        -- Test 1
        A <= x"0000FFBA";
        B <= x"0000FFBB";
        wait for 250 ps;
        assert (equal = '0') report "Test 1 failed." severity Error;

        -- Test 2
        B <= x"0000FFBA";
        wait for 250 ps;
        assert (equal = '1') report "Test 2 failed." severity Error;

        wait for 250 ps;
        wait;

        report "EOT";
    end process;
end tb;