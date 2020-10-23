----------------------------------------------------------------------------------
-- Company: 
-- Engineer:
-- 
-- Create Date: 12.10.2020 18:21:26
-- Design Name: 
-- Module Name: RL_binary_datapath - Behavioral
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

entity RL_binary_datapath is
	generic (
		C_block_size : integer := 256
	);
    Port (
        -- Clocks and resets
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        
        -- Data in interface 
        input_ready     : in STD_LOGIC;
        output_ready    : in STD_LOGIC;
        message         : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        P_nxt           : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        C_nxt           : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        output_valid    : in STD_LOGIC;
        
        -- Data out interface
        P               : out STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        C               : out STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        result          : out STD_LOGIC_VECTOR ( C_block_size-1 downto 0 )
        );
end RL_binary_datapath;

architecture Behavioral of RL_binary_datapath is
    
    -- Signals associated with the input registers
    signal P_r: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    signal C_r: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    
    -- Constants
    constant one: std_logic_vector(C_block_size-1 downto 0) := (0 => '1', others => '0');

begin

    process (clk, reset_n) begin
        if(reset_n = '0') then
            P_r <= (others => '0');
            C_r <= (others => '0');
                  
        elsif(clk'event and clk = '1') then
        
            if(input_ready = '1') then
                P_r <= message;
                C_r <= one;
                
            elsif(output_valid = '1') then
                P_r <= P_nxt;
                C_r <= C_nxt;      
            end if;
                       
        end if;
    end process;
    
    process (C_r, output_ready) begin
        if(output_ready = '1') then
            result <= C_r;
        else
            result <= (others => '0');
        end if;
    end process;
    
    P <= P_r;
    C <= C_r;
    
end Behavioral;
