-- /////////////////////////////////
-- // 4x1 Multiplexer with timing //
-- /////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_4x1 is
    generic (
        wordSize : natural := 32;
        -- Timing
        Tsel  : time := 500 ps;
        Tdata : time := 250 ps 
    );
    port (
        in0 : in  std_logic_vector(wordSize-1 downto 0);
        in1 : in  std_logic_vector(wordSize-1 downto 0);
        in2 : in  std_logic_vector(wordSize-1 downto 0);
        in3 : in  std_logic_vector(wordSize-1 downto 0);
        sel : in  std_logic_vector(1 downto 0);
        res : out std_logic_vector(wordSize-1 downto 0)
    );
end mux_4x1;

architecture timing of mux_4x1 is
begin
    with sel select res <=
        in0 after Tsel when "00",
        in1 after Tsel when "01",
        in2 after Tsel when "10",
        in3 after Tsel when "11",
        (others => 'X') when others;
end timing;