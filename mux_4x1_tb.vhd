library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_4x1_tb is
end entity;

architecture tb of mux_4x1_tb is

    component mux_4x1 is
        generic (
            wordSize : natural := 32;
            -- Timing
            Tsel  : time := 500 ps;
            Tdata : time := 250 ps 
        );
        port (
            in0 : in  std_logic_vector(wordSize-1 downto 0);
            in1 : in  std_logic_vector(wordSize-1 downto 0);
            in2 : in  std_logic_vector(wordSize-1 downto 0);
            in3 : in  std_logic_vector(wordSize-1 downto 0);
            sel : in  std_logic_vector(1 downto 0);
            res : out std_logic_vector(wordSize-1 downto 0)
        );
    end component;

    signal in0, in1, in2, in3, res : std_logic_vector(31 downto 0);
    signal sel : std_logic_vector(1 downto 0);

begin

    uut: mux_4x1 port map (in0, in1, in2, in3, sel, res);

    process
    begin
        report "BOT";

        in0 <= x"000000FF";
        in1 <= x"0000FF00";
        in2 <= x"00FF0000";
        in3 <= x"FF000000";

        -- Test 1
        sel <= "00";
        wait for 500 ps;
        assert(res = in0) report "Test 1 failed." severity error;
        wait for 500 ps;

        -- Test 2
        sel <= "01";
        wait for 500 ps;
        assert(res = in1) report "Test 2 failed." severity error;
        wait for 500 ps;

        -- Test 3
        sel <= "10";
        wait for 500 ps;
        assert(res = in2) report "Test 3 failed." severity error;
        wait for 500 ps;

        -- Test 4
        sel <= "11";
        wait for 500 ps;
        assert(res = in3) report "Test 4 failed." severity error;
        wait for 500 ps;

        report "EOT";
        wait;
    end process;

end tb;
