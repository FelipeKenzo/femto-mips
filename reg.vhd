-- //////////////////////////////////
-- // Generic Register with timing //
-- //////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
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
end entity;

architecture save of reg is
	signal Qi: std_logic_vector(size - 1 downto 0) := std_logic_vector(to_unsigned(def, size));
begin

	process(clk, rst)
	begin
		if rst = '1' then
			Qi <= std_logic_vector(to_unsigned(def, size));
		elsif rising_edge(clk) and ce = '1' then 
            if (D'last_event < Tsetup) then
                report "Tsetup violation in reg.";
                Qi <= (others => 'X');
            else
                Qi <= D;
			end if;
		end if;
	end process;

	Q <= Qi after Tprop;
end architecture;