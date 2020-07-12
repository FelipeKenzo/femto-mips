-- /////////////////////
-- // ROM with timing //
-- /////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is 
    generic (
        addrSize : natural := 16;
        wordSize : natural := 8;
        -- Timing
        Tread : time := 5000 ps
    );
    port (
        addr : in  std_logic_vector(addrSize-1 downto 0);
        data : out std_logic_vector(wordSize-1 downto 0)
    );
end rom;

architecture timing of rom is
    type rom_type is array (2**addrSize - 1 to 0) of std_logic_vector(wordSize-1 downto 0);
    signal memory: rom_type;
begin
    data <= memory(to_integer(unsigned(addr))) after Tread;
end timing;
