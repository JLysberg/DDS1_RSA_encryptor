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
USE ieee.numeric_std.ALL;
use ieee.math_real.all; 

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
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        
        key             : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        ready_out       : in STD_LOGIC;
        output_valid_P  : in STD_LOGIC;
        output_valid_C  : in STD_LOGIC;
        valid_in        : in STD_LOGIC;
        
        true_bit_ready  : out STD_LOGIC;
        next_bit_ready  : out STD_LOGIC;
        ready_in        : out STD_LOGIC;
        valid_out       : out STD_LOGIC;
        input_ready     : out STD_LOGIC;
        output_valid    : out STD_LOGIC;
        output_ready    : out STD_LOGIC
    );
end RL_binary_controller;

architecture Behavioral of RL_binary_controller is
    signal ready_in_i       : STD_LOGIC;
    signal input_ready_i    : STD_LOGIC;
    signal output_valid_i   : STD_LOGIC;
    signal true_bit_ready_i : STD_LOGIC;
    signal next_bit_ready_i : STD_LOGIC;
    signal output_ready_i   : STD_LOGIC;
    signal valid_out_i      : STD_LOGIC;
    signal index            : integer;
    signal width            : integer;
    
    type state_type is (IDLE, STATE_0, STATE_1);
    signal state_r, state_nxt : state_type;
    

begin
    ready_in_i      <= ready_out;   
    ready_in        <= ready_in_i;
    input_ready_i   <= valid_in and ready_in_i;
    input_ready     <= input_ready_i;
    width           <= C_block_size-1;
    
    process(clk, reset_n)   begin
        if(reset_n = '1') then
            state_r             <= IDLE;
            output_valid_i      <= '0';
            true_bit_ready_i    <= '0';
            next_bit_ready_i    <= '0';
            output_ready_i      <= '0';
            valid_out_i         <= '0';
            index               <= 0;
        elsif(clk'event and clk = '1') then
            state_r <= state_nxt;
        end if;
    end process;
    
    process(state_r, output_valid_P, output_valid_C, input_ready_i) begin
        -- Default assignments
        state_nxt           <= IDLE;
        output_valid_i      <= '0';
        true_bit_ready_i    <= '0';
        next_bit_ready_i    <= '0';
        output_ready_i      <= '0';
        valid_out_i         <= '0';
        index               <= 0;
        
        case(state_r) is
            when IDLE =>
                if(input_ready_i = '1') then
                    state_nxt <= STATE_0;
                end if;
                output_valid_i      <= '0';
                true_bit_ready_i    <= '0';
                next_bit_ready_i    <= '0';
                output_ready_i      <= '0';
                valid_out_i         <= '0';
                index               <= 0;
            when STATE_0 =>
                if(index = width) then
                    valid_out_i     <= '1';
                    output_ready_i  <= '1';
                    state_nxt       <= IDLE;
                else
                    output_valid_i <= '0';
                    if (key(index) = '1') then
                        true_bit_ready_i <= '1';
                    else
                        true_bit_ready_i <= '0';
                    end if;
                    next_bit_ready_i     <= '1';
                    index <= index + 1;
                    state_nxt <= STATE_1;
                end if;
            when STATE_1 =>
                if(output_valid_P = '1' and output_valid_C = '1') then
                    output_valid_i <= '1';
                    state_nxt <= STATE_0;
                else
                    output_valid_i <= '0';
                end if;
            when others =>
                state_nxt           <= IDLE;
                output_valid_i      <= '0';
                true_bit_ready_i    <= '0';
                next_bit_ready_i    <= '0';
                output_ready_i      <= '0';
                valid_out_i         <= '0';
                index               <= 0;
        end case;
    end process;

    output_valid    <= output_valid_i;
    output_ready    <= output_ready_i;
    true_bit_ready  <= true_bit_ready_i;
    next_bit_ready  <= next_bit_ready_i;
    valid_out       <= valid_out_i;

end Behavioral;