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
        message         : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        
        valid_out       : out STD_LOGIC;
        result          : out STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        ready_in        : out STD_LOGIC
    );
end RL_binary;

architecture Behavioral of RL_binary is
    signal true_bit_valid   : STD_LOGIC;
    signal next_bit_valid   : STD_LOGIC;
    signal output_valid_P   : STD_LOGIC;
    signal output_valid_C   : STD_LOGIC;
    signal output_ready     : STD_LOGIC;
    signal input_ready      : STD_LOGIC;
    signal output_valid     : STD_LOGIC;
    
    signal P              : STD_LOGIC_VECTOR (C_block_size-1 downto 0 );
    signal P_nxt          : STD_LOGIC_VECTOR (C_block_size-1 downto 0 );
    signal C              : STD_LOGIC_VECTOR (C_block_size-1 downto 0 );
    signal C_nxt          : STD_LOGIC_VECTOR (C_block_size-1 downto 0 );
begin

    RL_binary_datapath : entity work.RL_binary_datapath port map(
        clk             => clk,
        reset_n         => reset_n,
        
        input_ready     => input_ready,
        output_ready    => output_ready,
        message         => message,
        P_nxt           => P_nxt,
        C_nxt           => C_nxt,
        output_valid  => output_valid,
        
        P               => P,
        C               => C,
        result          => result        
    );
    
    RL_binary_controller : entity work.RL_binary_controller port map(
        clk             => clk,
        reset_n         => reset_n,
        
        valid_in        => valid_in,
        key             => key,
        ready_out       => ready_out,
        output_valid_P  => output_valid_P,
        output_valid_C  => output_valid_C,
        
        true_bit_ready  => true_bit_valid,
        next_bit_ready  => next_bit_valid,
        ready_in        => ready_in,
        valid_out       => valid_out,
        input_ready     => input_ready,
        output_valid    => output_valid,
        output_ready    => output_ready
    );
    
    Blakley_true_bit : entity work.Blakley port map (
        clk             => clk,
        reset_n         => reset_n,
        
        input_a         => P,
        input_b         => C,
        key_n           => modulus,
        bit_ready       => true_bit_valid,
        
        output          => C_nxt,
        output_valid    => output_valid_C
    );
    
    Blakley_next_bit : entity work.Blakley port map (
        clk             => clk,
        reset_n         => reset_n,
        
        input_a         => P,
        input_b         => P,
        key_n           => modulus,
        bit_ready       => next_bit_valid,
        
        output          => P_nxt,
        output_valid    => output_valid_P
    );

end Behavioral;
