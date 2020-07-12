-- /////////////////////////////
-- // Sign Extend with timing //
-- /////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signExtend is
    generic (
        inSize  : natural := 16;
        outSize : natural := 32;
        -- Timing:
        Tgate : time := 250 ps
    );
    port (
        smol : in  std_logic_vector(inSize-1 downto 0);
        big  : out std_logic_vector(outSize-1 downto 0)
    );
end signExtend;

architecture timing of signExtend is
    signal extension : std_logic_vector(outSize-inSize-1 downto 0);
begin
    extension <= (others => ('1' and smol(inSize-1))) after Tgate;
    big <= extension & smol;
end timing;