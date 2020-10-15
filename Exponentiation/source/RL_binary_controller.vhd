----------------------------------------------------------------------------------
-- Company: 
-- Engineer:
-- 
-- Create Date: 12.10.2020 18:21:26
-- Design Name: 
-- Module Name: RL_binary_controller - Behavioral
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

entity RL_binary_controller is
	generic (
		C_block_size : integer := 256
	);
    Port ( 
         clk            : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        
        key             : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        ready_out       : in STD_LOGIC;
        output_valid_P  : in STD_LOGIC;
        output_valid_C  : in STD_LOGIC;
        
        true_bit_ready  : out STD_LOGIC;
        next_bit_ready  : out STD_LOGIC;
        ready_in        : out STD_LOGIC;
        valid_out       : out STD_LOGIC
    );
end RL_binary_controller;

architecture Behavioral of RL_binary_controller is

begin


end Behavioral;