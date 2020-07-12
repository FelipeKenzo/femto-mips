-- ////////////////////////////
-- // Comparator with timing //
-- ////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator is
    generic (
        wordSize : natural := 32;
        -- Timing
        Tprop : time := 250 ps
    );
    port (
        A, B  : in  std_logic_vector(wordSize-1 downto 0);
        equal : out std_logic 
    );
end comparator;

architecture timing of comparator is
begin

    equal <= '1' after Tprop when A = B else
             '0' after Tprop;

end architecture;