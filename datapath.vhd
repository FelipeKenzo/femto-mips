-- /////////////////////////
-- // femto_MIPS datapath //
-- /////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    port (
        -- IF control signals
        PC_slt : in std_logic
        
        -- EX control signals
        ALU_slt_A   : in std_logic;
        ALU_slt_B   : in std_logic;
        WB_slt_dst  : in std_logic_vector(1 downto 0);
        ALU_ctrl_in : in std_logic_vector(5 downto 0); 
        
        -- EX control signals
        RAM_r_w : in std_logic;

        -- WB control signals
        WB_slt_data : 

    )
