library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is

	generic (
		Tread:	time := 4 ns;
		Twrite:	time := 4 ns
	);
    port (
		clk:		 in std_logic;
		wr_en:		 in std_logic;
		reset:		 in std_logic;

		read_addr1:	 in std_logic_vector(4 downto 0);
		read_addr2:	 in std_logic_vector(4 downto 0);
		write_addr:	 in std_logic_vector(4 downto 0);

		write_data:	 in std_logic_vector(31 downto 0);
		read_data1:	out std_logic_vector(31 downto 0);
		read_data2:	out std_logic_vector(31 downto 0)
    );

end entity;

architecture behavior of reg_file is

	type data_array is array (0 to 31) of std_logic_vector(31 downto 0);
	signal data: data_array;

	signal aux1, aux2: std_logic_vector(31 downto 0);

begin

	process (clk, reset)
	begin
		if reset = '1' then 
			data <= (others => (others => '0'));
			data(28) <= X"00000200";
			data(29) <= X"0000FFFF";
			data(30) <= X"0000FFFF";
		elsif rising_edge(clk) then 
			if (wr_en = '1' and write_addr /= "00000") then
				data(to_integer(unsigned(write_addr))) <= write_data after Twrite;
			end if;
		end if;
	end process;

	aux1 <= data(to_integer(unsigned(read_addr1)));
	aux2 <= data(to_integer(unsigned(read_addr2)));

	read_data1 <= aux1 after Tread;
	read_data2 <= aux2 after Tread;

end architecture;