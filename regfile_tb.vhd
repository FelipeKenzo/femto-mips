library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile_tb is
end entity;

architecture tb of regfile_tb is
    component regfile is
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
    end component;

    signal Read1, Read2, Write1 : std_logic_vector(4 downto 0) := "00000";
    signal Data1, Data2, WriteData : std_logic_vector(31 downto 0);
    signal RegWrite, rst, clk : std_logic;
    signal simulating : bit;

begin

    uut: regfile port map (Read1, Read2, Write1, WriteData,RegWrite, rst,
        clk, Data1, Data2);

    clock: process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;

        if (simulating = '0') then
            wait;
        end if;
    end process;

    tests: process
    begin
        report "BOT.";
        simulating <= '1';
        Read1 <= "00000";
        Read2 <= "00001";
        Write1 <= "00001";
        WriteData <= x"00FF00AB";
        RegWrite <= '0';

        -- reset
        rst <= '1';
        wait for 5 ns;
        rst <= '0';

        -- Test 1: read value;
        wait for 5 ns;
        Read1 <= "11101";
        wait for 4 ns;
        assert(Data1 = x"0000ffff") report "Test 1 fail" severity error;

        -- Test 2: write value;
        wait until falling_edge(clk);
        RegWrite <= '1';
        wait until rising_edge(clk);
        wait for 8 ns;
        assert(Data2 = x"00FF00AB") report "Test 2 fail" severity error;

        -- Test 3: write on zero
        wait until falling_edge(clk);
        Write1 <= "00000";
        Read1 <= "00000";
        wait until rising_edge(clk);
        wait for 8 ns;
        assert(Data1 = x"00000000") report "Test 3 fail" severity error;

        simulating <= '0';
        report "EOT.";
        wait;
    end process;
end architecture;

