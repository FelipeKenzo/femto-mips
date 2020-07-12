library ieee;
use ieee.std_logic_1164.all;

entity reg_tb is
end entity;

architecture behavior of reg_tb is

	component reg is
	
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
	
	end component;

	signal clk: std_logic;
	signal en: std_logic;
	signal clear: std_logic;
	signal D_in: std_logic_vector(31 downto 0);
	signal D_out: std_logic_vector(31 downto 0);

begin

	uut: reg generic map (
		Tsetup => 3 ns,
		Tprop =>  4 ns,
		def => 65535
	) port map (
		clk => clk,
		en => en,
		clear => clear,
		D_in => D_in,
		D_out => D_out
	);

	process
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
	end process;

	process
	begin
		clear <= '0';
		D_in <= X"441725F6";
		en <= '0';
		wait for 15 ns;
		en <= '1';
		wait for 33 ns;
		D_in <= X"FFFF8421";
		wait for 30 ns;
		clear <= '1';
		wait for 20 ns;
		en <= '0';
		wait for 15 ns;
		clear <= '0';
		en <= '1';
		wait for 15 ns;
		assert false report "EOT" severity failure;
	end process;

end architecture;