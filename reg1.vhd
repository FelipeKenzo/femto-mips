library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is

	generic (
		size:	natural := 32;
		Tsetup:	time := 250 ps;
		Tprop:	time := 1000 ps;
		def:	natural := 0
	);

	port (
		clk:	 in std_logic;
		en:		 in std_logic;
		clear:	 in std_logic;
		D_in:	 in std_logic_vector(size - 1 downto 0);
		D_out:	out std_logic_vector(size - 1 downto 0)
	);

end entity;

architecture save of reg is

	signal data: std_logic_vector(size - 1 downto 0) := (others => '0');

begin

	process(clk, clear)
	begin

		if clear = '1' then
			data <= std_logic_vector(to_unsigned(def, data'length));
		end if;

		if rising_edge(clk) and clear = '0' and en = '1' then 
			if D_in'last_event > Tsetup then
				data <= D_in;
			else data <= (others => 'X');
			end if;
		end if;

	end process;

	D_out <= data after Tprop;
	
end architecture;