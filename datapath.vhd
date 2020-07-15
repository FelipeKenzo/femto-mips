--------------------------------------------
-- femto_MIPS Datapath                    --
--------------------------------------------
-- Pipeline + Hazard and Forwarding Units --
-- author: Felipe Kenzo Kusakawa Mashuda  --
--------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    generic (
        program : string;
        IF_ID_size  : natural := 64;
        ID_EX_size  : natural := 154;
        EX_MEM_size : natural := 105;
        MEM_WB_size : natural := 38
    );
    port (
        clk : in std_logic;

        -- IF control signals
        IF_PC_sel : in std_logic_vector(1 downto 0);
        
        -- EX control signals
        EX_ALU_sel_A   : in std_logic;
        EX_ALU_sel_B   : in std_logic;
        EX_sel_dst     : in std_logic_vector(1 downto 0);
        EX_ALU_Op      : in std_logic_vector(2 downto 0); 
        
        -- MEM control signals
        MEM_RAM_r_w : in std_logic;
        MEM_sel_wd  : in std_logic_vector(1 downto 0);

        -- WB control signals
        WB_RegWrite : in std_logic;

        -- Signals to control
        instr : out std_logic_vector(31 downto 0);
        equal : out std_logic;

        rst : std_logic
    );
end datapath;

architecture pipeline of datapath is

    signal stall : std_logic;

    ----------------
    -- IF signals --
    ----------------
    signal IF_sel_mux : std_logic_vector( 1 downto 0);
    signal IF_PC_D    : std_logic_vector(31 downto 0);
    signal IF_PC_Q    : std_logic_vector(31 downto 0);
    signal IF_PC_clk  : std_logic;
    signal IF_PC_ce   : std_logic;
    signal IF_instr   : std_logic_vector(31 downto 0);
    signal IF_PC_4    : std_logic_vector(31 downto 0);

    --------------------
    -- IF/ID register --
    --------------------
    signal IF_ID_D  : std_logic_vector(IF_ID_size-1 downto 0);
    signal IF_ID_Q  : std_logic_vector(IF_ID_size-1 downto 0);
    signal IF_ID_ce : std_logic; 

    ----------------
    -- ID signals --
    ----------------
    signal ID_instr   : std_logic_vector(31 downto 0);
    signal ID_rs      : std_logic_vector( 4 downto 0);
    signal ID_rt      : std_logic_vector( 4 downto 0);
    signal ID_rd      : std_logic_vector( 4 downto 0);
    signal ID_imm_16  : std_logic_vector(15 downto 0);
    signal ID_imm_32  : std_logic_vector(31 downto 0);
    signal ID_imm_sll : std_logic_vector(31 downto 0);
    signal ID_addr    : std_logic_vector(25 downto 0);
    signal ID_ra      : std_logic_vector(31 downto 0);
    signal ID_ra_fwrd : std_logic_vector(31 downto 0);
    signal ID_rb      : std_logic_vector(31 downto 0);
    signal ID_rb_fwrd : std_logic_vector(31 downto 0);
    signal ID_clk     : std_logic;
    signal ID_PC_B    : std_logic_vector(31 downto 0);
    signal ID_PC_J    : std_logic_vector(31 downto 0);
    signal ID_PC_4    : std_logic_vector(31 downto 0);
    signal ID_PC_8    : std_logic_vector(31 downto 0);
    signal ID_ctrls   : std_logic_vector(10 downto 0);
    signal ID_ctrls_save : std_logic_vector(10 downto 0);

    -------------------
    -- ID/EX signals --
    -------------------
    signal ID_EX_D         : std_logic_vector(ID_EX_size-1 downto 0);
    signal ID_EX_Q         : std_logic_vector(ID_EX_size-1 downto 0);
    signal ID_EX_ALU_sel_A : std_logic;
    signal ID_EX_ALU_sel_B : std_logic;
    signal ID_EX_sel_dst   : std_logic_vector(1 downto 0);
    signal ID_EX_ALU_Op    : std_logic_vector(2 downto 0);
    -- To EX/MEM
    signal ID_EX_PC_8        : std_logic_vector(31 downto 0);
    signal ID_EX_MEM_RAM_r_w : std_logic;
    signal ID_EX_MEM_sel_wd  : std_logic_vector(1 downto 0);
    signal ID_EX_WB_RegWrite : std_logic;

    ----------------
    -- EX signals --
    ----------------
    signal EX_imm      : std_logic_vector(31 downto 0);
    signal EX_ra       : std_logic_vector(31 downto 0);
    signal EX_rb       : std_logic_vector(31 downto 0);
    signal EX_ra_fwrd  : std_logic_vector(31 downto 0);
    signal EX_rb_fwrd  : std_logic_vector(31 downto 0);
    signal EX_rs       : std_logic_vector(4 downto 0);
    signal EX_rt       : std_logic_vector(4 downto 0);
    signal EX_rd       : std_logic_vector(4 downto 0);
    signal EX_wr       : std_logic_vector(4 downto 0);
    signal EX_ALU_A    : std_logic_vector(31 downto 0);
    signal EX_ALU_b    : std_logic_vector(31 downto 0);
    signal EX_ALU_out  : std_logic_vector(31 downto 0);

    --------------------
    -- EX/MEM signals --
    --------------------
    signal EX_MEM_D       : std_logic_vector(104 downto 0);
    signal EX_MEM_Q       : std_logic_vector(104 downto 0);
    signal EX_MEM_RAM_r_w : std_logic;
    signal EX_MEM_sel_wd  : std_logic_vector(1 downto 0);
    -- To MEM/WB
    signal EX_MEM_WB_RegWrite : std_logic;
    signal MEM_PC_8 : std_logic_vector(31 downto 0);

    -----------------
    -- MEM signals --
    -----------------
    signal MEM_alu_out : std_logic_vector(31 downto 0);
    signal MEM_rb      : std_logic_vector(31 downto 0);
    signal MEM_wd      : std_logic_vector(31 downto 0);
    signal MEM_wr      : std_logic_vector( 4 downto 0);
    signal MEM_out     : std_logic_vector(31 downto 0);
    signal MEM_clk     : std_logic;

    --------------------
    -- MEM/WB signals --
    --------------------
    signal MEM_WB_D : std_logic_vector(MEM_WB_size-1 downto 0);
    signal MEM_WB_Q : std_logic_vector(MEM_WB_size-1 downto 0);

    ----------------
    -- WB signals --
    ----------------
    signal WB_wr : std_logic_vector(4 downto 0);
    signal WB_wd : std_logic_vector(31 downto 0);
    signal WB_rw : std_logic;

    -----------------------------
    -- Forwarding Unit signals --
    -----------------------------
    signal ID_sel_ra : std_logic;
    signal ID_sel_rb : std_logic;
    signal EX_sel_ra : std_logic_vector(1 downto 0);
    signal EX_sel_rb : std_logic_vector(1 downto 0);


begin

    -- /////////////////////////////
    -- // Instruction Fetch Stage //
    -- /////////////////////////////

    IF_PC_clk <= clk after 1250 ps;

    -- Next instruction MUX
    MUX_0 : entity work.mux_4x1(timing) port map (
        in0 => IF_PC_4,
        in1 => ID_PC_J,
        in2 => ID_PC_B,
        in3 => ID_ra_fwrd,
        sel => IF_PC_sel,
        res => IF_PC_D
    );

    -- Program Counter
    PC : entity work.reg(timing) port map (
        D   => IF_PC_D,
        Q   => IF_PC_Q,
        clk => IF_PC_clk,
        ce  => IF_PC_ce,
        rst => rst
    );

    -- Instruction Memory (ROM)
    IMEM : entity work.rom(timing) generic map (
        NA => program
    )
    port map (
        addr => IF_PC_Q(15 downto 0),
        d_out => IF_instr
    );

    -- Adder for PC+4
    ADD_0 : entity work.adder(timing) port map (
        A => IF_PC_Q,
        B => x"00000004",
        res => IF_PC_4
    );

    -----------------------------
    -- IF/ID Pipeline Register --
    -----------------------------
    -- [31: 0] - instruction
    -- [63:32] - pc+4
    -----------------------------

    IF_ID : entity work.reg(timing) generic map (
        size => 64
    )
    port map (
        D   => IF_ID_D,
        Q   => IF_ID_Q,
        clk => clk,
        ce  => IF_ID_ce,
        rst => rst
    );

    IF_ID_D <= IF_PC_4 & IF_instr;

    -- //////////////////////////////
    -- // Instruction Decode Stage //
    -- //////////////////////////////

    ID_instr  <= IF_ID_Q(31 downto  0);
    ID_rs     <= IF_ID_Q(25 downto 21);
    ID_rt     <= IF_ID_Q(20 downto 16);
    ID_rd     <= IF_ID_Q(15 downto 11);
    ID_imm_16 <= IF_ID_Q(15 downto  0);
    ID_addr   <= IF_ID_Q(25 downto  0);
    ID_PC_4   <= IF_ID_Q(63 downto 32);

    instr <= ID_instr; 
    ID_clk <= clk after 1250 ps;

    ID_ctrls <= ( WB_RegWrite &
        Mem_sel_wd &
        MEM_RAM_r_w &
        EX_ALU_Op &
        EX_sel_dst &
        EX_ALU_sel_B &
        EX_ALU_sel_A
    );

    -- Register File
    registers : entity work.regfile(timing) port map (
        Read1     => ID_rs,
        Read2     => ID_rt,
        Write1    => WB_wr,
        WriteData => WB_wd,
        RegWrite  => WB_rw,
        rst       => rst,
        clk       => ID_clk,
        Data1     => ID_ra,
        Data2     => ID_rb
    );

    -- Immediate Sign Extension
    sig_ext : entity work.signExtend(timing) port map (
        smol => ID_imm_16,
        big  => ID_imm_32
    );

    -- Immediate shift left
    ID_imm_sll  <= ID_imm_32(29 downto 0) & "00";

    -- Branch addr calculation
    ADD_1 : entity work.adder(timing) port map (
        A => ID_PC_4,
        B => ID_imm_sll,
        res => ID_PC_B
    );

    -- Jal return addr calculation
    ADD_2 : entity work.adder(timing) port map (
        A => ID_PC_4,
        B => x"00000004",
        res => ID_PC_8
    );
    
    -- Jump addr calculation
    ID_PC_J <= IF_ID_Q(63 downto 60) & ID_addr & "00";

    -- Forwarding muxes
    MUX_1 : entity work.mux_2x1(timing) port map (
        in0 => ID_ra,
        in1 => MEM_alu_out,
        sel => ID_sel_ra,
        res => ID_ra_fwrd -- Jump Register addr
    );

    MUX_2 : entity work.mux_2x1(timing) port map (
        in0 => ID_rb,
        in1 => MEM_alu_out,
        sel => ID_sel_rb,
        res => ID_rb_fwrd
    );

    -- Comparator for branches
    cmp : entity work.comparator(timing) port map (
        A     => ID_ra_fwrd,
        B     => ID_rb_fwrd,
        equal => equal
    );

    -- Hazard stall mux
    MUX_9 : entity work.mux_2x1(timing) generic map (
        wordSize => 11
    )
    port map (
        in0 => ID_ctrls,
        in1 => "00000000000",
        sel => stall,
        res => ID_ctrls_save
    );

    -----------------------------
    -- ID/EX Pipeline Register --
    -----------------------------
    -- [  4:  0] - rd
    -- [  9:  5] - rt
    -- [ 14: 10] - rs
    -- [ 46: 15] - imm
    -- [ 78: 47] - rb
    -- [110: 79] - ra
    -- [142:111] - pc+8
    --
    -- EX control signals:
    -- [143] - ALU_sel_A
    -- [144] - ALU_sel_B
    -- [146:145] - sel_dst
    -- [149:147] - ALU_Op
    --
    -- MEM control signals:
    -- [150] - RAM_r_w
    -- [152:151] - sel_wd
    --
    -- WB control signals:
    -- [153] RegWrite
    -----------------------------

    ID_EX : entity work.reg(timing) generic map (
        size => ID_EX_size
    )
    port map (
        D   => ID_EX_D,
        Q   => ID_EX_Q,
        clk => clk,
        ce  => '1',
        rst => rst
    );

    ID_EX_D <= (
        ID_ctrls_save &
        ID_PC_8 &
        ID_ra &
        ID_rb &
        ID_imm_32 &
        ID_rs &
        ID_rt &
        ID_rd
    );

    -- ///////////////////
    -- // Execute Stage //
    -- ///////////////////

    -- To next register
    ID_EX_PC_8        <= ID_EX_Q(142 downto 111);
    ID_EX_MEM_RAM_r_w <= ID_EX_Q(150);
    ID_EX_MEM_sel_wd  <= ID_EX_Q(152 downto 151);
    ID_EX_WB_RegWrite <= ID_EX_Q(153);
    
    -- Control signals
    ID_EX_ALU_sel_A <= ID_EX_Q(143);
    ID_EX_ALU_sel_B <= ID_EX_Q(144);
    ID_EX_sel_dst   <= ID_EX_Q(146 downto 145);
    ID_EX_ALU_Op    <= ID_EX_Q(149 downto 147);

    EX_ra  <= ID_EX_Q(110 downto 79);
    EX_rb  <= ID_EX_Q( 78 downto 47);
    EX_imm <= ID_EX_Q( 46 downto 15);
    EX_rs  <= ID_EX_Q( 14 downto 10);
    EX_rt  <= ID_EX_Q(  9 downto  5);
    EX_rd  <= ID_EX_Q(  4 downto  0);

    -- Forwarding muxes
    MUX_3 : entity work.mux_4x1(timing) port map (
        in0 => EX_ra,
        in1 => WB_wd,
        in2 => MEM_alu_out,
        in3 => x"00000000",
        sel => EX_sel_ra,
        res => EX_ra_fwrd
    );

    MUX_4 : entity work.mux_4x1(timing) port map (
        in0 => EX_rb,
        in1 => WB_wd,
        in2 => MEM_alu_out,
        in3 => x"00000000",
        sel => EX_sel_rb,
        res => EX_rb_fwrd
    );

    -- WR decision mux
    MUX_5 : entity work.mux_4x1(timing) generic map (
        wordSize => 5
    )
    port map (
        in0 => EX_rt,
        in1 => EX_rd,
        in2 => "11111",
        in3 => "00000",
        sel => ID_EX_sel_dst,
        res => EX_wr
    );
    
    -- Immediate decision mux
    MUX_6 : entity work.mux_2x1(timing) port map (
        in0 => EX_ra_fwrd,
        in1 => EX_imm,
        sel => ID_EX_ALU_sel_A,
        res => EX_ALU_A
    );

    MUX_7 : entity work.mux_2x1(timing) port map (
        in0 => EX_rb_fwrd,
        in1 => EX_imm,
        sel => ID_EX_ALU_sel_B,
        res => EX_ALU_B
    );

    -- Arithmetic Logic Unit
    ALU : entity work.ula(comportamental) port map (
        A        => EX_ALU_A,
        B        => EX_ALU_B,
        Controle => ID_EX_ALU_Op,
        VemUm    => '0',
        C        => EX_ALU_out,
        Zero     => open,
        Overflow => open
    );

    ------------------------------
    -- EX/MEM Pipeline Register --
    ------------------------------
    -- [  4:  0] - wr
    -- [ 36:  5] - rb
    -- [ 68: 37] - aluout
    -- [100: 69] - pc+8
    --
    -- MEM control signals:
    -- [101] - RAM_r_w
    -- [103:102] - sel_wd
    --
    -- WB control signals:
    -- [104] RegWrite
    -----------------------------

    EX_MEM : entity work.reg(timing) generic map (
        size => 105
    )
    port map (
        D   => EX_MEM_D,
        Q   => EX_MEM_Q,
        clk => clk,
        ce  => '1',
        rst => rst
    );

    EX_MEM_D <= (
        ID_EX_WB_RegWrite &
        ID_EX_MEM_sel_wd &
        ID_EX_MEM_RAM_r_w &
        ID_EX_PC_8 &
        EX_ALU_out &
        EX_rb_fwrd &
        EX_wr
    );

    -- //////////////////
    -- // Memory Stage //
    -- //////////////////

    -- To next register
    EX_MEM_WB_RegWrite <= EX_MEM_Q(104);
    
    -- Control signals
    EX_MEM_RAM_r_w <= EX_MEM_Q(101);
    EX_MEM_sel_wd  <= EX_MEM_Q(103 downto 102);
    
    MEM_PC_8    <= EX_MEM_Q(100 downto 69);
    MEM_ALU_out <= EX_MEM_Q(68 downto 37);
    MEM_rb      <= EX_MEM_Q(36 downto  5);
    MEM_wr      <= EX_MEM_Q( 4 downto  0);

    MEM_clk <= clk after 1250 ps;

    -- Data memory (RAM)
    DMEM : entity work.ram(timing) generic map (
        NA => program
    )
    port map (
        addr     => MEM_alu_out(15 downto 0),
        in_data  => MEM_rb,
        out_data => MEM_out,
        clk      => MEM_clk,
        r_w      => EX_MEM_RAM_r_w
    );

    -- wd decision mux
    MUX_8 : entity work.mux_4x1(timing) port map (
        in0 => MEM_alu_out,
        in1 => MEM_out,
        in2 => MEM_PC_8,
        in3 => x"00000000",
        sel => EX_MEM_sel_wd,
        res => MEM_wd
    );

    ------------------------------
    -- MEM/WB Pipeline Register --
    ------------------------------
    -- [ 4: 0] - wr
    -- [36: 5] - wd
    --
    -- WB control signals:
    -- [37] RegWrite
    -----------------------------

    MEM_WB : entity work.reg(timing) generic map (
        size => MEM_WB_size
    )
    port map (
        D   => MEM_WB_D,
        Q   => MEM_WB_Q,
        clk => clk,
        ce  => '1',
        rst => rst
    );

    MEM_WB_D <= (
        EX_MEM_WB_RegWrite &
        MEM_wd &
        MEM_wr
    );

    -- //////////////////////
    -- // Write Back Stage //
    -- //////////////////////

    WB_wr <= MEM_WB_Q( 4 downto 0);
    WB_wd <= MEM_WB_Q(36 downto 5);
    WB_rw <= MEM_WB_Q(37);

    -- ///////////////////////////
    -- // Hazard Detection Unit //
    -- ///////////////////////////

    HDU : entity work.hazard(timing) port map (
        instr             => ID_instr,
        EX_wr             => EX_wr,
        MEM_wr            => MEM_wr,
        ID_EX_WB_RegWrite => ID_EX_WB_RegWrite,
        ID_EX_MEM_sel_wd  => ID_EX_MEM_sel_wd,
        EX_MEM_sel_wd     => EX_MEM_sel_wd,
        stall             => stall
    );

    IF_PC_ce <= not stall;
    IF_ID_ce <= not stall;

    -- /////////////////////
    -- // Forwarding Unit //
    -- /////////////////////

    FU : entity work.forwarding(timing) port map (
        ID_rs              => ID_rs,
        ID_rt              => ID_rt,
        EX_rs              => EX_rs,
        EX_rt              => EX_rt,
        MEM_wr             => MEM_wr,
        WB_wr              => WB_wr,
        EX_MEM_WB_RegWrite => EX_MEM_WB_RegWrite,
        WB_rw              => WB_rw,
        ID_sel_ra          => ID_sel_ra,
        ID_sel_rb          => ID_sel_rb,
        EX_sel_ra          => EX_sel_ra,
        EX_sel_rb          => EX_sel_rb
    );

end pipeline;
