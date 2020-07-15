entity f_mips_tb is
end entity;

library ieee;
use ieee.std_logic_1164.all;

architecture tb of f_mips_tb is

    component f_mips is
        generic(
            program : string
        );
        port (
            clk : in std_logic;
            rst : in std_logic
        );
    end component;

    signal clk, rst : std_logic;

begin

    uut: f_mips generic map (
        program => "test4.txt"
    )
    port map (
        clk => clk,
        rst => rst
    );

    clock: process
    variable cycles : integer := 0;
    begin
        if (cycles = 10) then
            wait;
        end if;
        
        clk <= '0';
        wait for 7500 ps;
        clk <= '1';
        wait for 7500 ps;

        cycles := cycles + 1;
    end process;

    test: process
    begin
        rst <= '1';
        wait for 2 ns;
        rst <= '0';

        wait;
    end process;


end architecture;