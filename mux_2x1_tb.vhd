library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_2x1_tb is
end entity;

architecture tb of mux_2x1_tb is

    component mux_2x1 is
        generic (
            wordSize : natural := 32;
            -- Timing
            Tsel  : time := 500 ps;
            Tdata : time := 250 ps 
        );
        port (
            in0 : in  std_logic_vector(wordSize-1 downto 0);
            in1 : in  std_logic_vector(wordSize-1 downto 0);
            sel : in  std_logic;
            res : out std_logic_vector(wordSize-1 downto 0)
        );
    end component;

    signal in0, in1, in2, in3, res : std_logic_vector(31 downto 0);
    signal sel : std_logic;

begin

    uut: mux_2x1 port map (in0, in1, sel, res);

    process
    begin
        report "BOT";

        in0 <= x"000000FF";
        in1 <= x"0000FF00";

        -- Test 1
        sel <= '0';
        wait for 500 ps;
        assert(res = in0) report "Test 1 failed." severity error;
        wait for 500 ps;

        -- Test 2
        sel <= '1';
        wait for 500 ps;
        assert(res = in1) report "Test 2 failed." severity error;
        wait for 500 ps;

        report "EOT";
        wait;
    end process;

end tb;
