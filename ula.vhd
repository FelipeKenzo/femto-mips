library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    generic (
        wordSize : integer := 32 -- Para fins de testbench.
        -- Timing
        Tadd : time := 1000 ps;
        Tsub : time := 1250 ps
    );
    port (
        A,B      : in  std_logic_vector(wordSize-1 downto 0);
        Controle : in  std_logic_vector( 2 downto 0);
        VemUm    : in  std_logic;
        C        : out std_logic_vector(wordSize-1 downto 0);
        Zero     : out std_logic;
        Overflow : out std_logic
    );
end entity;

architecture comportamental of ula is
    -- Operações
    signal aux_or  : std_logic_vector(wordSize-1 downto 0) := (others => '0');
    signal aux_and : std_logic_vector(wordSize-1 downto 0) := (others => '0');
    signal aux_add : std_logic_vector(wordSize   downto 0) := (others => '0'); -- Tem um bit a mais para detectar overflow
    signal aux_sub : std_logic_vector(wordSize   downto 0) := (others => '0'); -- Tem um bit a mais para detectar overflow
    signal aux_slt : std_logic_vector(wordSize-1 downto 0) := (others => '0');
    signal aux_nop : std_logic_vector(wordSize-1 downto 0) := (others => '0');
    signal aux_cin : std_logic_vector(wordSize   downto 0) := (others => '0'); -- Sinal para representar o vem-um como vector para poder fazer contas.
   
    -- Saídas
    signal aux_c   : std_logic_vector(wordSize-1 downto 0) := (others => '0');
    constant zeros : std_logic_vector(wordSize-1 downto 0) := (others => '0'); -- Constante de zeros para calcular saída Zero.
    signal overflow_add, overflow_sub : std_logic := '0'; -- Sinais para overflow da soma e subtração em complemento de dois.


begin

    -- Controle = 000 (AND):
    aux_and <= A AND B;

    -- Controle = 001 (OR):
    aux_or <= A OR B;

    -- Controle = 010 (Add unsigned) e 011 (Add unsigned):
    -- Para realizar uma soma de 'std_logic_vector', primeiro converto  A e B para o tipo 'unsigned' e depois reconverto o resultado
    -- para 'std_logic_vector'.
    -- 
    -- OBS: O resultado de uma soma/subtração signed e unsigned é exatamente o mesmo, a nível de bits. Muda só a sua interpretação.
    aux_cin(0) <= VemUm;
    aux_add    <= std_logic_vector(unsigned('0' & A) + unsigned(B) + unsigned(aux_cin)) after Tsoma;
    
    -- Controle = 100 (select on less than): olha-se apenas o sinal da subtração de A e B.
    aux_slt    <= (0      => aux_sub(wordSize-1),
                   others => '0');

    -- Controle = 101 (Subtract unsigned) e 110 (Subtract signed) fazem o mesmo cálculo:
    aux_sub    <= std_logic_vector(unsigned('0' & A) - unsigned(B)) after Tsub;

    -- Controle = 111 (no operation):
    aux_nop <= (others => '0');

    -- Saída C: Multiplexação da saída usando a entrada Controle como chave.
    with Controle select aux_c <=
        aux_and                     when "000",
        aux_or                      when "001",
        aux_add(wordSize-1 downto 0) when "010",
        aux_add(wordSize-1 downto 0) when "011",
        aux_slt                     when "100",
        aux_sub(wordSize-1 downto 0) when "101",
        aux_sub(wordSize-1 downto 0) when "110",
        aux_nop                     when others;

    C <= aux_c;
    
    -- Saída Zero: comparo o resultado com o sinal de zeros.
    Zero <= '0' when Controle = "111" else -- NOP faz saída igual a zero, mas não deveria levantar a flag.
            '1' when aux_c = zeros else 
            '0';
    
    -- Saída Overflow. Apesar de os resultados da adição e da subtração em complemento de 2 ou sem sinal serem os mesmos,
    -- interpreta-se o overflow de forma diferente:
    --
    --     Soma comp. de dois: Sinais de entrada com mesmo sinal, resultado com sinal diferente.
    overflow_add <= '1' when A(wordSize-1) /= aux_add(wordSize-1) AND B(wordSize-1) /= aux_add(wordSize-1) else '0';
    --
    --     Sub. comp. de dois: Sinal B e resultado com mesmo sinal, A com sinal diferente.
    overflow_sub <= '1' when A(wordSize-1) /= aux_sub(wordSize-1) AND B(wordSize-1) = aux_sub(wordSize-1) else '0';

    with Controle select Overflow <=
        aux_add(wordSize) when "010", -- Soma unsigned: caso haja carry, houve overflow.
        overflow_add     when "011", -- Soma complemento de dois.
        overflow_sub     when "100", -- SLT (subtração complemento de dois)
        aux_sub(wordSize) when "101", -- Sub. unsigned: caso haja carry, houve overflow.
        overflow_sub     when "110", -- Sub. complemento de dois.
        '0' when others;

end architecture;