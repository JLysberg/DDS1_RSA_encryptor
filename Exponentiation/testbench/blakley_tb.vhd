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
		C_block_size : integer := 256
	);
end blakley_tb;

architecture Behavioral of blakley_tb is

    -- Constants
    constant CLK_PERIOD    : time := 20 ns;
    constant RESET_TIME    : time := 20 ns;

    signal clk          : STD_LOGIC := '0';
    signal reset_n      : STD_LOGIC := '0';
    
    signal input_a      : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 ) := (others => '0');
    signal input_b      : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 ) := (others => '0');
    signal key_n        : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 ) := (others => '0');
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
            key_n           => key_n        ,
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
        reset_n <= '1';
        wait;
    end process;
    
    -- Stimuli generation
    stimuli_proc: process
    begin
        wait for 1*CLK_PERIOD;
        bit_ready       <= '1';
        input_a         <= (0 => '1', 3 => '1', others => '0');
        input_b         <= (0 => '1', 3 => '1', others => '0');
        key_n           <= (1 => '1', 3 => '1', others => '0');
        wait;
    end process;


end Behavioral;
