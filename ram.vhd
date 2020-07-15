-- /////////////////////
-- // RAM with timing //
-- /////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

entity ram is 
    generic (
        addrSize : natural := 16;
        wordSize : natural := 8;
        -- Timing
        Tread  : time := 5000 ps;
        Twrite : time := 5000 ps;
        NA : string := "mram.txt"
    );
    port (
        addr     : in  std_logic_vector(addrSize-1 downto 0);
        in_data  : in  std_logic_vector((wordSize*4)-1 downto 0);
        out_data : out std_logic_vector((wordSize*4)-1 downto 0);
        clk, r_w : in  std_logic
    );
end ram;

architecture timing of ram is
    type ram_type is array (2**addrSize - 1 downto 0) of std_logic_vector(wordSize-1 downto 0);
    signal memory: ram_type;
    signal init : boolean := true;
begin

    wololo :process(clk, r_w) -- Roda somente uma vez na inicializa��o
    impure function fill_memory return ram_type is
        type HexTable is array (character range <>) of integer;
        -- Caracteres HEX válidos: 0, 1, 2 , 3, 4, 5, 6, 6, 7, 8, 9, A, B, C, D, E, F  (somente caracteres maiúsculos)
        constant lookup: HexTable ('0' to 'F') :=
            (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, -1, -1, -1, -1, -1, -1, -1, 10, 11, 12, 13, 14, 15);
        file infile: text open read_mode is NA; -- Abre o arquivo para leitura
        variable buff: line; 
        variable addr_s: string ((integer(ceil(real(addrSize)/4.0)) + 1) downto 1); -- Digitos de endereço mais um espaço
        variable data_s: string ((integer(ceil(real(wordSize)/4.0)) + 1) downto 1); -- Ultimo byte sempre tem um espaço separador
        variable addr_1, pal_cnt: integer;
        variable data: std_logic_vector(wordSize-1 downto 0);
        variable up: integer;
        variable upreal: real;
        variable Mem: ram_type := ( others  => (others => '0')) ;
        begin
            while (not endfile(infile)) loop
                readline(infile,buff); -- Lê um linha do infile e coloca no buff
                read(buff, addr_s);    -- Leia o conteudo de buff até encontrar um espaço e atribui � addr_s, ou seja, leio o endereço
                read(buff, pal_cnT);   -- Leia o número de bytes da próxima linha
                addr_1 := 0;
                upreal := real(addrSize)/4.0;
                up := integer((ceil(upreal)));
                for i in (up + 1) downto 2 loop
                    addr_1 := addr_1 + lookup(addr_s(i))*16**(i - 2);
                end loop;
                readline(infile, buff);
                for i in 1 to pal_cnt loop
                    read(buff, data_s); -- Leia dois dígitos Hex e o espaço separador
                    data := (others => '0');
                    upreal := real(wordSize)/4.0;
                    up := integer((ceil(upreal)));
                    --- report "Indice de conteudo = " & real'image(upreal) & " Indice de conteudo inteiro = " & integer'image(up);
                    for j in (up + 1) downto 2 loop
                        data((4*(j-2))+3 downto 4*(j-2)) := std_logic_vector(to_unsigned(lookup(data_s(j)),4));
                    end loop;
                    Mem(addr_1) := data;  -- Converte o conteúdo da palavra para std_logic_vector
                    addr_1 := addr_1 + 1; -- Endereça a próxima palavra a ser carregada
                end loop;
            end loop;
        return Mem;
    end fill_memory;
    begin
        if (init) then
            report "ram loading from file " & NA;
            memory <= fill_memory;
            init <= false;
        end if;

        if (rising_edge(clk) and r_w = '1') then
            memory(to_integer(unsigned(addr))) <= in_data(31 downto 24) after Twrite;
            memory(to_integer(unsigned(addr))+1) <= in_data(23 downto 16) after Twrite;
            memory(to_integer(unsigned(addr))+2) <= in_data(15 downto  8) after Twrite;
            memory(to_integer(unsigned(addr))+3)   <= in_data( 7 downto  0) after Twrite;
        end if;
    end process;

    out_data <= memory(to_integer(unsigned(addr))) & 
                memory(to_integer(unsigned(addr))+1) & 
                memory(to_integer(unsigned(addr))+2) & 
                memory(to_integer(unsigned(addr))+3)
    after Tread;

end timing;