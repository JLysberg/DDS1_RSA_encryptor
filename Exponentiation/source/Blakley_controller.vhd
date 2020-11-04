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
use IEEE.numeric_std.all;

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
        clk                 : in STD_LOGIC;
        reset_n             : in STD_LOGIC;
    
        input_b             : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        bit_ready           : in STD_LOGIC;
        
        add_en              : out STD_LOGIC;
        output_valid        : out STD_LOGIC
    );
end Blakley_controller;

architecture Behavioral of Blakley_controller is
    -- Internal signals  
    signal add_en_i         : STD_LOGIC;
    
    signal output_valid_i   : STD_LOGIC;
    
    signal bit_index        : unsigned(10 downto 0);
    signal width            : integer;
    
    type state_type is (STATE_IDLE, STATE_ADD, STATE_MOD1, STATE_MOD2, STATE_SH);
    signal state_r, state_nxt : state_type;
    
begin
    width   <= C_block_size - 1;

    -- Clocked state switch and reset signal
    process(clk, reset_n) begin
        if(reset_n = '0') then
            state_r             <= STATE_IDLE;
            --output_valid_i      <= '0';
            --add_en_i            <= '0';
            --bit_index           <= (others => '0');
        elsif(clk'event and clk = '1') then
            state_r             <= state_nxt;
        end if;
    end process;
   
    -- FSM
    process(state_r, bit_ready) begin        
        case(state_r) is 
            when STATE_IDLE =>
                output_valid_i  <= '1';
                add_en_i        <= '0';
                bit_index       <= (others => '0');
                
                if(bit_ready = '1') then
                    state_nxt       <= STATE_ADD;
                    output_valid_i  <= '0';
                end if;
                
            when STATE_ADD =>
                if(to_integer(bit_index) = width) then
                    output_valid_i  <= '1';
                    state_nxt       <= STATE_IDLE;
                else
                    if(input_b(to_integer(bit_index)) = '1') then
                        add_en_i    <= '1';
                    else
                        add_en_i    <= '0';
                    end if;
                    bit_index   <= bit_index + 1;
                    state_nxt   <= STATE_MOD1;
                end if;
                
            when STATE_MOD1 =>
                state_nxt   <= STATE_MOD2;
                
            when STATE_MOD2 =>
                state_nxt   <= STATE_SH;
                
            when STATE_SH =>
                state_nxt   <= STATE_ADD;
                
            when others =>
                state_nxt           <= STATE_IDLE;
                output_valid_i      <= '0';
                add_en_i            <= '0';
                output_valid_i      <= '0';  
                bit_index           <= (others => '0');
                
        end case;
    end process;
    
    add_en          <= add_en_i;
    output_valid    <= output_valid_i;
   

end Behavioral;
