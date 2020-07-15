-- ///////////////////////////////////////
-- // Hazard Detection Unit with timing //
-- ///////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazard is
    generic (
        Tprop : time := 500 ps
    );
    port (
        instr  : in std_logic_vector(31 downto 0);
        EX_wr  : in std_logic_vector( 4 downto 0);
        MEM_wr : in std_logic_vector( 4 downto 0);
        ID_EX_WB_RegWrite  : in std_logic;
        ID_EX_MEM_sel_wd   : in std_logic_vector(1 downto 0);
        EX_MEM_sel_wd      : in std_logic_vector(1 downto 0);
        stall : out std_logic
    );
end hazard;

-- BRA or JR one after arith
-- BRA or JR one after LW
-- BRA or JR two after LW
-- arith one after LW

architecture timing of hazard is
    signal aux_stall  : std_logic := '0';
    
    signal opcode : std_logic_vector(5 downto 0);
    signal funct  : std_logic_vector(5 downto 0);
    signal rs     : std_logic_vector(4 downto 0);
    signal rt     : std_logic_vector(4 downto 0);

    signal BRA     : boolean := false;
    signal JR      : boolean := false;
    signal arith   : boolean := false;
    signal sameWr1 : boolean := false;
    signal sameWr2 : boolean := false;

begin
    opcode <= instr(31 downto 26);
    rs     <= instr(25 downto 21);
    rt     <= instr(20 downto 16);
    funct  <= instr( 5 downto  0);

    BRA   <= opcode = "000100" or opcode = "000101";
    JR    <= opcode = "000000" and funct = "001000";
    arith <= not (
        JR or opcode = "000010" or opcode = "000011" or
        opcode = "000100" or opcode = "000101"
    );

    sameWr1 <= rs = EX_wr or rt = EX_wr;
    sameWr2 <= rs = MEM_wr or rt = MEM_wr;

    aux_stall <= '1' when (BRA or JR) and ID_EX_WB_RegWrite = '1' and sameWr1 else -- BRA or JR one after arith
            '1' when (BRA or JR) and ID_EX_MEM_sel_wd = "01" and sameWr1 else      -- BRA or JR one after LW
            '1' when (BRA or JR) and EX_MEM_sel_wd = "01" and sameWr2 else         -- BRA or JR two after LW
            '1' when arith and ID_EX_MEM_sel_wd = "01" and sameWr1 else            -- arith one after LW
            '0';
    
    stall <= aux_stall after Tprop;
        
end timing;