----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.10.2020 17:54:18
-- Design Name: 
-- Module Name: RL-binary - Behavioral
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

entity RL_binary is
	generic (
		C_block_size : integer := 256
	);
    Port ( 
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        
        key             : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        valid_in        : in STD_LOGIC;
        ready_out       : in STD_LOGIC;
        modulus         : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        message         : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 )
    );
end RL_binary;

architecture Behavioral of RL_binary is

begin

    RL_binary : entity work.RL_binary port map(
        clk         => clk,
        reset_n     => reset_n,
        
        key         => key,
        valid_in    => valid_in,
        ready_out   => ready_out,
        modulus     => modulus,
        message     => message
        
    );


end Behavioral;
