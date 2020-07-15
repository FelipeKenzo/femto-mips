-- /////////////////////
-- // ROM with timing //
-- /////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

entity rom is 
    generic (
        addrSize : natural := 16;
        wordSize : natural := 8;
        -- Timing
        Tread : time := 5000 ps;
        NA : string := "mrom.txt"
    );
    port (
        addr : in  std_logic_vector(addrSize-1 downto 0);
        d_out : out std_logic_vector((wordSize*4)-1 downto 0)
    );
end rom;

architecture timing of rom is

    type rom_type is array (2**addrSize - 1 downto 0) of std_logic_vector(wordSize-1 downto 0);
    signal memory: rom_type;

begin
    
    Carga_inicial :process -- Roda somente uma vez na inicializa��o
    impure function fill_memory return rom_type is
        type HexTable is array (character range <>) of integer;
        -- Caracteres HEX válidos: 0, 1, 2 , 3, 4, 5, 6, 6, 7, 8, 9, A, B, C, D, E, F  (somente caracteres mai�sculos)
        constant lookup: HexTable ('0' to 'F') :=
            (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, -1, -1, -1, -1, -1, -1, -1, 10, 11, 12, 13, 14, 15);
        file infile: text open read_mode is NA; -- Abre o arquivo para leitura
        variable buff: line; 
        variable addr_s: string ((integer(ceil(real(addrSize)/4.0)) + 1) downto 1); -- Digitos de endere�o mais um espa�o
        variable data_s: string ((integer(ceil(real(wordSize)/4.0)) + 1) downto 1); -- �ltimo byte sempre tem um espa�o separador
        variable addr_1, pal_cnt: integer;
        variable data: std_logic_vector(wordSize-1 downto 0);
        variable up: integer;
        variable upreal: real;
        variable Mem: rom_type := ( others  => (others => '0')) ;
        begin
            while (not endfile(infile)) loop
                readline(infile,buff); -- Lê um linha do infile e coloca no buff
                read(buff, addr_s);    -- Leia o conteudo de buff até encontrar um espaço e atribui � addr_s, ou seja, leio o endereço
                read(buff, pal_cnT);   -- Leia o número de bytes da próxima linha
                addr_1 := 0;
                upreal := real(addrSize)/4.0;
                up := integer((ceil(upreal)));
                -- report "Valor teto = " & real'image(upreal) & " Endereco = " & integer'image(up);
                for i in (up + 1) downto 2 loop
                    -- report "Indice i = " & integer'image(i);
                    addr_1 := addr_1 + lookup(addr_s(i))*16**(i - 2);
                end loop;
                readline(infile, buff);
                -- report "pal_cnt = " & integer'image(pal_cnt); 
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
        report "rom loading from file " & NA;
        memory <= fill_memory;
        wait;
    end process;

    -- reads four consecutive positions
    d_out <= memory(to_integer(unsigned(addr))) &
             memory(to_integer(unsigned(addr))+1) &
             memory(to_integer(unsigned(addr))+2) &
             memory(to_integer(unsigned(addr))+3)
    after Tread;

end timing;
