library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

entity ram_tb is
end ram_tb;

architecture tb of ram_tb is

    component ram is 
        generic (
            addrSize : natural := 16;
            wordSize : natural := 8;
            -- Timing
            Tread  : time := 5000 ps;
            Twrite : time := 5000 ps;
            NA : string := "mram.txt"
        );
        port (
            addr     : in  std_logic_vector(addrSize-1 downto 0);
            in_data  : in  std_logic_vector((wordSize*4)-1 downto 0);
            out_data : out std_logic_vector((wordSize*4)-1 downto 0);
            clk, r_w : in  std_logic
        );
    end component;

    signal addr : std_logic_vector(15 downto 0) := x"0000";
    signal in_data : std_logic_vector(31 downto 0);
    signal out_data : std_logic_vector(31 downto 0);
    signal clk, r_w, simulating : std_logic;

begin
    uut: ram generic map (
        addrSize => 16,
        wordSize => 8,
        NA => "sort.txt"
    )
    port map (
        addr => addr,
        in_data => in_data,
        out_data => out_data,
        clk => clk,
        r_w => r_w
    );

    clock: process
    begin
        clk <= '0';
        wait for 50 ns;
        clk <= '1';
        wait for 50 ns;

        if (simulating = '0') then
            wait;
        end if;
    end process;

    process
    begin
        report "BOT.";
        simulating <= '1';
        in_data <= x"5FA8B001";
        r_w <= '0';

        addr <= x"0000";
        wait for 5 ns;
        assert(out_data = x"20040100") severity Error;

        wait until rising_edge(clk);
        addr <= x"0004";
        wait for 5 ns;
        assert(out_data = x"8C050150") severity Error;

        wait until falling_edge(clk);
        addr <= x"0008";
        r_w <= '1';
        wait until rising_edge(clk);
        wait for 10 ns;
        assert(out_data = x"5FA8B001") severity Error;
        
        wait until falling_edge(clk);
        simulating <= '0';
        report "EOT.";
        wait;
    end process;

end tb;