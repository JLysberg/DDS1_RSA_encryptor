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
use ieee.numeric_std.all;

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
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
    
        input_a         : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        key_n           : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        add_en          : in STD_LOGIC;
        
        output          : out STD_LOGIC_VECTOR ( C_block_size-1 downto 0 )
    );
end Blakley_datapath;

architecture Behavioral of Blakley_datapath is
    signal R1_i   : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    signal R2_i   : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    signal R3_i   : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    signal R1_r     : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    signal R2_r     : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    signal R3_r     : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    signal R3s_r    : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
begin
    process (clk, reset_n) begin
        if(reset_n = '0') then
            R1_r   <= (others => '0');
            R2_r   <= (others => '0');
            R3_r   <= (others => '0');
            R3s_r  <= (others => '0');
            
        elsif(clk'event and clk = '1') then
            R1_r    <= R1_i;
            R2_r    <= R2_i;
            R3_r    <= R3_i;
            R3s_r   <= R3_r(C_block_size - 2 downto 0) & '0';
        end if;
    end process;
    
    process (add_en, R3s_r) begin
        if(add_en = '1') then
            R1_i   <= std_logic_vector(unsigned(input_a) + unsigned(R3s_r));
        else
            R1_i  <= R3s_r;
        end if;
    end process;
    
    process (R1_r, key_n) begin
        if(R1_r >= key_n) then
            R2_i   <= std_logic_vector(unsigned(R1_r) - unsigned(key_n));
        else 
            R2_i   <= R1_r;
        end if;            
    end process;
    
    process (R2_r, key_n) begin
        if(R2_r >= key_n) then
            R3_i   <= std_logic_vector(unsigned(R2_r) - unsigned(key_n));
        else 
            R3_i   <= R2_r;
        end if;              
    end process;
    
    output  <= R3_r;
                
end Behavioral;












