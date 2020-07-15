-- /////////////////////////////////
-- // Forwarding Unit with timing //
-- /////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forwarding is
    generic (
        Tprop : time := 500 ps
    );
    port (
        ID_rs  : in std_logic_vector(4 downto 0);
        ID_rt  : in std_logic_vector(4 downto 0);
        EX_rs  : in std_logic_vector(4 downto 0);
        EX_rt  : in std_logic_vector(4 downto 0);
        MEM_wr : in std_logic_vector(4 downto 0);
        WB_wr  : in std_logic_vector(4 downto 0);
        EX_MEM_WB_RegWrite : in std_logic;
        WB_rw              : in std_logic;
        
        ID_sel_ra : out std_logic;
        ID_sel_rb : out std_logic;

        EX_sel_ra : out std_logic_vector(1 downto 0);
        EX_sel_rb : out std_logic_vector(1 downto 0)
    );
end forwarding;

-- BRA or JR two after arithmetic; x
-- arithmetic one after arithmetic;
-- arithmetic two after arithmetic;
-- arithmetic two after lw;

architecture timing of forwarding is

begin
    ID_sel_ra <= '1' when ID_rs = MEM_wr and EX_MEM_WB_RegWrite = '1' else
                 '0';

    ID_sel_rb <= '1' when ID_rt = MEM_wr and EX_MEM_WB_RegWrite = '1' else
                 '0';

    EX_sel_ra <= "01" when EX_rs = WB_wr and WB_rw = '1' else
                 "10" when EX_rs = MEM_wr and EX_MEM_WB_RegWrite = '1' else
                 "00";

    EX_sel_rb <= "01" when EX_rt = WB_wr and WB_rw = '1' else
                 "10" when EX_rt = MEM_wr and EX_MEM_WB_RegWrite = '1' else
                 "00";

end timing;