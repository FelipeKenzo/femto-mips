library ieee;
use ieee.std_logic_1164.all;

entity controlUnit_tb is
end entity;

architecture behavior of controlUnit_tb is

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

	signal instr : std_logic_vector(31 downto 0);
	signal equal :  std_logic;
	signal IF_PC_sel :  std_logic_vector(1 downto 0);
	signal EX_ALU_sel_A : std_logic;
	signal EX_ALU_sel_B : std_logic;
	signal EX_sel_dst   : std_logic_vector(1 downto 0);
	signal EX_ALU_Op    : std_logic_vector(2 downto 0); 
	signal MEM_RAM_r_w : std_logic;
	signal MEM_sel_wd  : std_logic_vector(1 downto 0);
	signal WB_RegWrite : std_logic;

begin

	uut: controlUnit port map (
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

	
	process
	begin
		equal <= '0';
		-- 100011 LW
		instr <= X"8C000000";
		wait for 10 ns;
		-- 101011 SW
		instr <= X"AC000000";
		wait for 10 ns;
		-- 001000 ADDI
		instr <= X"20000000";
		wait for 10 ns;
		-- 000100 BEQ
		instr <= X"10000000";
		wait for 5 ns;
		equal <= '1';
		wait for 5 ns;
		equal <= '0';
		-- 001010 SLTI
		instr <= X"28000000";
		wait for 10 ns;
		-- 000101 BNE
		instr <= X"14000000";
		wait for 5 ns;
		equal <= '1';
		wait for 5 ns;
		equal <= '0';
		-- 100000 ADD
		instr <= X"00000020";
		wait for 10 ns;
		-- 101010 SLT
		instr <= X"0000002A";
		wait for 10 ns;
		-- 001000 JR
		instr <= X"00000008";
		wait for 10 ns;
		-- 100001 ADDU
		instr <= X"00000021";
		wait for 10 ns;
		-- 000000 SLL
		instr <= X"00000000";
		wait for 10 ns;
		-- 000010 J
		instr <= X"08000000";
		wait for 10 ns;
		-- 000011 JAL
		instr <= X"0C000000";
		wait for 10 ns;
		wait;
	end process;

 end architecture;