-- //////////////////////////////
-- // Control Unit with timing //
-- //////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controlUnit is
    generic (
        -- Timing
        Tprop : time := 500 ps
    );
    port (
        -- Inputs
        instr : in std_logic_vector(31 downto 0);
        equal : in std_logic;
        
        -- IF control signals
        IF_PC_sel : out std_logic_vector(1 downto 0);
        
        -- EX control signals
        EX_ALU_sel_A : out std_logic;
        EX_ALU_sel_B : out std_logic;
        EX_sel_dst   : out std_logic_vector(1 downto 0);
        EX_ALU_Op    : out std_logic_vector(2 downto 0); 
        
        -- MEM control signals
        MEM_RAM_r_w : out std_logic;
        MEM_sel_wd  : out std_logic_vector(1 downto 0);

        -- WB control signals
        WB_RegWrite : out std_logic
    );
end controlUnit;

architecture timing of controlUnit is
    signal opcode : std_logic_vector(5 downto 0);
    signal funct : std_logic_vector(5 downto 0);

    signal PC_sel    : std_logic_vector(1 downto 0);
    signal ALU_sel_A : std_logic;
    signal ALU_sel_B : std_logic;
    signal sel_dst   : std_logic_vector(1 downto 0);
    signal ALU_Op    : std_logic_vector(2 downto 0); 
    signal RAM_r_w   : std_logic;
    signal sel_wd    : std_logic_vector(1 downto 0);
    signal RegWrite  : std_logic;

    -- FUNCT constants
    constant ADD  : std_logic_vector(5 downto 0) := "100000";
    constant ADDU : std_logic_vector(5 downto 0) := "100001";
    constant SLT  : std_logic_vector(5 downto 0) := "101010";
    constant JR   : std_logic_vector(5 downto 0) := "001000";
    constant LSL  : std_logic_vector(5 downto 0) := "000000";
    -- OPCODE constants
    constant R    : std_logic_vector(5 downto 0) := "000000";
    constant J    : std_logic_vector(5 downto 0) := "000010";
    constant JAL  : std_logic_vector(5 downto 0) := "000011";
    constant LW   : std_logic_vector(5 downto 0) := "100011";
    constant SW   : std_logic_vector(5 downto 0) := "101011";
    constant ADDi : std_logic_vector(5 downto 0) := "001000";
    constant SLTI : std_logic_vector(5 downto 0) := "001010";
    constant BEQ  : std_logic_vector(5 downto 0) := "000100";
    constant BNE  : std_logic_vector(5 downto 0) := "000101";

begin

    opcode <= instr(31 downto 26);
    funct  <= instr(5 downto 0);

    PC_sel <= "01" when opcode = J or opcode = JAL else
              "10" when (opcode = BEQ and equal = '1') or
                        (opcode = BNE and equal = '0') else
              "11" when (opcode = R and funct = JR) else
              "00";
    
    ALU_sel_A <= '1' when opcode = R and funct = LSL else
                 '0';

    ALU_sel_B <= '1' when opcode = LW or opcode = SW or
                          opcode = ADDI or opcode = SLTI else
                 '0';

    sel_dst <= "01" when opcode = R else
               "10" when opcode = JAL else
               "00";

    ALU_Op <= "001" when opcode = R and funct = LSL else
              "010" when opcode = R and funct = ADDU else
              "011" when (opcode = R and funct = ADD) or
                         opcode = LW or opcode = SW or
                         opcode = ADDI else
              "100" when (opcode = R and funct = SLT) or
                         opcode = SLTI else
              "000";

    RAM_r_w <= '1' when opcode = SW else
               '0';

    sel_wd <= "01" when opcode = LW else
              "10" when opcode = JAL else
              "00";

    RegWrite <= '1' when (opcode = R and (funct = ADD or
                            funct = ADDU or
                            funct = SLT or
                            funct = LSL)) or
                          opcode = JAL or
                          opcode = LW or
                          opcode = ADDI or
                          opcode = SLTI else
                '0';

    -- Timing
    IF_PC_sel    <= PC_sel    after Tprop;
    EX_ALU_sel_A <= ALU_sel_A after Tprop;
    EX_ALU_sel_B <= ALU_sel_B after Tprop;
    EX_sel_dst   <= sel_dst   after Tprop;
    EX_ALU_Op    <= ALU_Op    after Tprop;
    MEM_RAM_r_w  <= RAM_r_w   after Tprop;
    MEM_sel_wd   <= sel_wd    after Tprop;
    WB_RegWrite  <= RegWrite  after Tprop;
end;