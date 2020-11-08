----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/19/2020 03:00:09 PM
-- Design Name: 
-- Module Name: Blakley - Behavioral
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

entity Blakley is
    generic (
        C_block_size    : integer := 256
    );
    Port (
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;

        input_a         : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        input_b         : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        key_n           : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        
        output          : out STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        
        bit_ready       : in STD_LOGIC;
        
        output_valid    : out STD_LOGIC
    );
end Blakley;

architecture Behavioral of Blakley is
    signal add_en           : STD_LOGIC;
begin

    Blakley_datapath : entity work.Blakley_datapath port map(
        clk             => clk,
        reset_n         => reset_n,
        
        input_a         => input_a,
        key_n           => key_n,
        add_en          => add_en,
        
        output          => output
    );
    
    Blakley_controller : entity work.Blakley_controller port map(
        clk             => clk,
        reset_n         => reset_n,
    
        input_b         => input_b,
        bit_ready       => bit_ready,
        
        add_en          => add_en,
        output_valid    => output_valid
    );
    
end Behavioral;
