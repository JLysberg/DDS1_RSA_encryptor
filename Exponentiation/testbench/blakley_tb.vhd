----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.11.2020 14:14:27
-- Design Name: 
-- Module Name: blakley_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity blakley_tb is
    generic (
		C_block_size : integer := 260
	);
end blakley_tb;

architecture Behavioral of blakley_tb is

    -- Constants
    constant CLK_PERIOD    : time := 5 ns;
    constant RESET_TIME    : time := 5 ns;

    signal clk          : STD_LOGIC := '0';
    signal reset_n      : STD_LOGIC := '0';
    
    signal input_a      : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 ) := (others => '0');
    signal input_b      : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 ) := (others => '0');
    signal modulus        : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 ) := (others => '0');
    signal bit_ready    : STD_LOGIC := '0';
    
    signal output       : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 ) := (others => '0');
    signal output_valid : STD_LOGIC := '0';
    
begin

    i_blakley : entity work.Blakley
        port map (
            clk             => clk          ,
            reset_n         => reset_n      ,
            input_a         => input_a      ,
            input_b         => input_b      ,
            modulus           => modulus        ,
            bit_ready       => bit_ready    ,
            output          => output       ,
            output_valid    => output_valid
        );       
            
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2;
    
    -- Reset generation
    reset_proc: process
    begin
        wait for RESET_TIME;
        reset_n     <= '1';
        wait;
    end process;
    
    -- Stimuli generation
    stimuli_proc: process
    begin
        wait for 2 * CLK_PERIOD;
        bit_ready       <= '1';
        input_a         <= x"03026c469918f5ea097f843dc5d5259192f9d3510415841ce834324f4c237ac7";
        input_b         <= x"0cea1651ef44be1f1f1476b7539bed10d73e3aac782bd9999a1e5a790932bfe9";
        modulus           <= x"09925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
        wait until output_valid = '1';
        bit_ready       <= '0';
        wait for 20 * CLK_PERIOD;
        bit_ready       <= '1';
        wait until output_valid = '1';
        wait for 2 * CLK_PERIOD;
        
        assert (not output = x"69b7f088465a71925d7828dbbc3914e783789cc79b2bec228654b09591e4df7") report "Test completed with correct output" severity note;
        assert false report "Test failed" severity failure;
        
    end process;

end Behavioral;
