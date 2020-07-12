library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_tb is
end reg_tb;

architecture tb of reg_tb is
    component reg is
        generic (
            size:	natural := 32;
            def:	natural := 0;
            -- Timing
            Tsetup:	time := 250 ps;
            Tprop:	time := 1000 ps
        );
        port (
            D : in  std_logic_vector(size - 1 downto 0);
            Q :	out std_logic_vector(size - 1 downto 0);
            clk, ce, rst : in std_logic
        );
    end component;

    signal D, Q : std_logic_vector(31 downto 0);
    signal clk, rst, ce : std_logic;
    signal simulating : std_logic;
    
begin
    
    uut: reg port map (D, Q, clk, ce, rst);

    clock: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;

        if (simulating = '0') then
            wait;
        end if;
    end process;

    tests: process
    begin
        report "BOT";
        simulating <= '1';
        rst <= '0';
        ce <= '1';
        
        -- normal operation
        D <= x"000000AB";
        wait for 6 ns;
        assert(Q = D) report "Q is wrong." severity error;
        
        -- violate Tsetup
        wait for 8 ns;
        wait for 850 ps;
        D <= x"0000FFFF";
        wait for 150 ps;
        wait for 15 ns;
        simulating <= '0';
        report "EOT";
        wait;
    end process;
end tb;