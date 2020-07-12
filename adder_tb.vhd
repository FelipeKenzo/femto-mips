library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_tb is
end entity;

architecture tb of adder_tb is

    component adder is
        generic (
            wordSize : natural := 32;
            -- Timing
            Tprop : time := 1000 ps
        );
        port (
            A, B : in  std_logic_vector(wordSize-1 downto 0);
            res  : out std_logic_vector(wordSize-1 downto 0)
        );
    end component;

    signal A, B, res : std_logic_vector(31 downto 0);

begin

    uut: adder port map(A, B, res);

    process
    begin
        report "BOT.";
        A <= std_logic_vector(to_unsigned(900,32));
        B <= std_logic_vector(to_unsigned(300,32));
        wait for 1 ns;
        assert(res = std_logic_vector(to_unsigned(1200,32))) report "Test failed." severity Error;
        wait for 1 ns;
        report "EOT.";
        wait;
    end process;

end tb;