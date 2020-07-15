--------------------------------------------
-- femto_MIPS Toplevel                    --
--------------------------------------------
-- Control Unit and Datapath              --
-- author: Felipe Kenzo Kusakawa Mashuda  --
--------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity f_mips is
    generic(
        program : string
    );
    port (
        clk : in std_logic;
        rst : in std_logic
    );
end f_mips;

architecture structural of f_mips is

    component datapath is
        generic (
            program : string;
            IF_ID_size  : natural := 64;
            ID_EX_size  : natural := 154;
            EX_MEM_size : natural := 106;
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
    end component;

    component controlUnit is
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
    end component;

    signal IF_PC_sel    : std_logic_vector(1 downto 0);
    signal EX_ALU_sel_A : std_logic;
    signal EX_ALU_sel_B : std_logic;
    signal EX_sel_dst   : std_logic_vector(1 downto 0);
    signal EX_ALU_Op    : std_logic_vector(2 downto 0); 
    signal MEM_RAM_r_w  : std_logic;
    signal MEM_sel_wd   : std_logic_vector(1 downto 0);
    signal WB_RegWrite  : std_logic;
    signal instr     : std_logic_vector(31 downto 0);
    signal equal     : std_logic;

begin
    CU : controlUnit port map (
        instr        => instr,
        equal        => equal,
        IF_PC_sel    => IF_PC_sel,   
        EX_ALU_sel_A => EX_ALU_sel_A,
        EX_ALU_sel_B => EX_ALU_sel_B,
        EX_sel_dst   => EX_sel_dst,  
        EX_ALU_Op    => EX_ALU_Op,   
        MEM_RAM_r_w  => MEM_RAM_r_w, 
        MEM_sel_wd   => MEM_sel_wd,  
        WB_RegWrite  => WB_RegWrite  
    );

    FD : datapath generic map (
        program => program
    )
    port map (
        clk,
        IF_PC_sel,   
        EX_ALU_sel_A,
        EX_ALU_sel_B,
        EX_sel_dst, 
        EX_ALU_Op,   
        MEM_RAM_r_w, 
        MEM_sel_wd,  
        WB_RegWrite,
        instr,
        equal,
        rst
    );

end structural;