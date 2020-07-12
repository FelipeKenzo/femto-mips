-- /////////////////////
-- // RAM with timing //
-- /////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is 
    generic (
        addrSize : natural := 16;
        wordSize : natural := 8;
        -- Timing
        Tread  : time := 5000 ps;
        Twrite : time := 5000 ps
    );
    port (
        addr     : in  std_logic_vector(addrSize-1 downto 0);
        in_data  : in  std_logic_vector(wordSize-1 downto 0);
        out_data : out std_logic_vector(wordSize-1 downto 0);
        clk, r_w : in  std_logic
    );
end ram;

architecture timing of ram is
    type ram_type is array (2**addrSize - 1 to 0) of std_logic_vector(wordSize-1 downto 0);
    signal memory: ram_type;
begin

    process(clk, r_w)
    begin
        if (rising_edge(clk) and r_w = '1') then
            memory(to_integer(unsigned(addr))) <= in_data after Twrite;
        end if;
    end process;

    out_data <= memory(to_integer(unsigned(addr))) after Tread;
end timing;