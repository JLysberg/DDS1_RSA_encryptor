----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/19/2020 03:00:09 PM
-- Design Name: 
-- Module Name: Blakley_datapath - Behavioral
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

entity Blakley_datapath is
    generic (
        C_block_size : integer := 256
    );
    Port (
        clk         : in STD_LOGIC;
        reset_n     : in STD_LOGIC;
    
        input_b     : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        key_n       : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        add_en      : in STD_LOGIC;
        shift_en    : in STD_LOGIC;
        
        output      : out STD_LOGIC_VECTOR ( C_block_size-1 downto 0 )
    );
end Blakley_datapath;

architecture Behavioral of Blakley_datapath is

begin


end Behavioral;
