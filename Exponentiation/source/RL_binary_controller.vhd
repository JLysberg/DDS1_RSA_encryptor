library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.math_real.all; 

entity RL_binary_controller is
	generic (
		C_block_size            : integer := 256
	);
    Port (
        -- Utility 
        clk                     : in STD_LOGIC;
        reset_n                 : in STD_LOGIC;
        
        -- Input control
        msgin_valid             : in STD_LOGIC;
        msgin_ready             : out STD_LOGIC;
        system_start            : out STD_LOGIC;
        
        -- Input data
        key                     : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        
        -- Ouput control
        msgout_ready            : in STD_LOGIC;
        msgout_valid            : out STD_LOGIC;
        
        -- Blakley control
        blakley_C_input_valid   : out STD_LOGIC;
        blakley_P_input_valid   : out STD_LOGIC;
        blakley_C_output_valid  : in STD_LOGIC;
        blakley_P_output_valid  : in STD_LOGIC;
        blakley_finished        : out STD_LOGIC
    
    );
end RL_binary_controller;

architecture Behavioral of RL_binary_controller is
    -- Internal registers
    signal bit_index_r              : STD_LOGIC_VECTOR ( 10 downto 0 );
    signal blakley_C_output_valid_r : STD_LOGIC;
    signal blakley_P_output_valid_r : STD_LOGIC;
    
    -- Internal register inputs
    signal bit_index_i              : STD_LOGIC_VECTOR ( 10 downto 0 );
    signal blakley_C_input_valid_i  : STD_LOGIC;
    signal blakley_P_input_valid_i  : STD_LOGIC;
    
    -- Internal control signal
    signal msgin_ready_i            : STD_LOGIC;
    signal system_start_i           : STD_LOGIC;
    signal msgout_valid_i           : STD_LOGIC;
    signal blakley_C_output_valid_i : STD_LOGIC;
    signal blakley_P_output_valid_i : STD_LOGIC;
    signal blakley_finished_i       : STD_LOGIC;
    
    -- State registers and signals
    type state_type is (STATE_IDLE, STATE_START, STATE_WAITING);
    signal state_r, state_nxt       : state_type;
    

begin
    msgin_ready_i   <= msgout_ready;   
    msgin_ready     <= msgin_ready_i;
    system_start_i  <= msgin_valid and msgin_ready_i;
    system_start    <= system_start_i;
    
    process(clk, reset_n)   begin
        if(reset_n = '0') then
            state_r                     <= STATE_IDLE;
            blakley_P_output_valid_r    <= '0';
            blakley_C_output_valid_r    <= '0';
            bit_index_r                 <= (others => '0');
        elsif(clk'event and clk = '1') then
            state_r                     <= state_nxt;
            bit_index_r                 <= bit_index_i;
            blakley_P_output_valid_r    <= blakley_P_output_valid_i;
            blakley_C_output_valid_r    <= blakley_C_output_valid_i;
        end if;
    end process;
    
    process(state_r, blakley_P_output_valid, blakley_C_output_valid, system_start_i, blakley_P_output_valid_r, blakley_C_output_valid_r, bit_index_r) begin
        
        case(state_r) is
            when STATE_IDLE =>
                if(system_start_i = '1') then
                    state_nxt   <= STATE_START;
                else
                    state_nxt   <= STATE_IDLE;
                end if;
                blakley_finished_i          <= '0';
                blakley_C_input_valid_i     <= '0';
                blakley_P_input_valid_i     <= '0';
                msgout_valid_i              <= '0';
                bit_index_i                 <= (others => '0');
                blakley_C_output_valid_i    <= '0';
                blakley_P_output_valid_i    <= '0';
            when STATE_START =>
                blakley_C_output_valid_i    <= '0';
                blakley_P_output_valid_i    <= '0';
                if(to_integer(unsigned(bit_index_r)) = C_block_size) then
                    bit_index_i             <= (others => '0');
                    blakley_finished_i      <= '1';
                    blakley_C_input_valid_i <= '0';
                    blakley_P_input_valid_i <= '0';
                    msgout_valid_i          <= '1';
                    state_nxt               <= STATE_IDLE;
                else   
                    if (key(to_integer(unsigned(bit_index_r))) = '1') then
                        blakley_C_input_valid_i <= '1';
                    else
                        blakley_C_input_valid_i <= '0';
                    end if;
                    blakley_finished_i      <= '0';
                    blakley_P_input_valid_i <= '1';
                    msgout_valid_i          <= '0';
                    bit_index_i             <= std_logic_vector(unsigned(bit_index_r) + 1);
                    state_nxt               <= STATE_WAITING;
                end if;
            when STATE_WAITING =>
                if(blakley_P_output_valid = '1') then
                    blakley_P_output_valid_i    <= '1';
                    blakley_P_input_valid_i     <= '0';
                else
                    blakley_P_output_valid_i    <= blakley_P_output_valid_r;
                    blakley_P_input_valid_i     <= '1';
                end if;
                if(blakley_C_output_valid = '1') then
                    blakley_C_output_valid_i    <= '1';
                    blakley_C_input_valid_i     <= '0';
                else
                    blakley_C_output_valid_i    <= blakley_C_output_valid_r;
                    blakley_C_input_valid_i     <= '1';
                end if;
                if(blakley_P_output_valid_r = '1' and blakley_C_output_valid_r = '1') then
                    blakley_finished_i  <= '1';
                    state_nxt           <= STATE_START;
                else
                    blakley_finished_i  <= '0';
                    state_nxt           <= STATE_WAITING;
                end if;
                msgout_valid_i  <= '0';
                bit_index_i     <= bit_index_r;
            when others =>
                state_nxt                   <= STATE_IDLE;
                blakley_finished_i          <= '0';
                blakley_C_input_valid_i     <= '0';
                blakley_P_input_valid_i     <= '0';
                msgout_valid_i              <= '0';
                bit_index_i                 <= (others => '0');
                blakley_C_output_valid_i    <= '0';
                blakley_P_output_valid_i    <= '0';
        end case;
    end process;

    blakley_finished        <= blakley_finished_i;
    blakley_C_input_valid   <= blakley_C_input_valid_i;
    blakley_P_input_valid   <= blakley_P_input_valid_i;
    msgout_valid            <= msgout_valid_i;

end Behavioral;