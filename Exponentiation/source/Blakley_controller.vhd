----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/19/2020 03:00:09 PM
-- Design Name: 
-- Module Name: Blakley_controller - Behavioral
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

entity Blakley_controller is
    generic (
        C_block_size : integer := 256
    );
    Port (
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
    
        input_a         : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        bit_ready       : in STD_LOGIC;
        
        add_en          : out STD_LOGIC;
        shift_en        : out STD_LOGIC;
        output_valid    : out STD_LOGIC
    );
end Blakley_controller;

architecture Behavioral of Blakley_controller is

begin


end Behavioral;
