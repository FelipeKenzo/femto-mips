-- ///////////////////////
-- // Adder with timing //
-- ///////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
    generic (
        wordSize : natural := 32;
        -- Timing
        Tprop : time := 1000 ps
    );
    port (
        A, B : in  std_logic_vector(wordSize-1 downto 0);
        res  : out std_logic_vector(wordSize-1 downto 0)
    );
end entity;

architecture timing of adder is
begin
    res <= std_logic_vector(unsigned(A) + unsigned(B)) after Tprop;
end timing;