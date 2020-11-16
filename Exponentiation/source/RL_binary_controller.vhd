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
        msgin_last              : in STD_LOGIC;
        system_start            : out STD_LOGIC;
        
        -- Input data
        key                     : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        
        -- Ouput control
        msgout_ready            : in STD_LOGIC;
        msgout_valid            : out STD_LOGIC;
        msgout_last             : out STD_LOGIC;
        
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
    signal msgin_last_r             : STD_LOGIC;
    
    -- Internal register inputs
    signal bit_index_i              : STD_LOGIC_VECTOR ( 10 downto 0 );
    signal blakley_C_input_valid_i  : STD_LOGIC;
    signal blakley_P_input_valid_i  : STD_LOGIC;
    signal msgin_last_i             : STD_LOGIC;
    
    -- Internal control signal
    signal msgin_ready_i            : STD_LOGIC;
    signal system_start_i           : STD_LOGIC;
    signal msgout_valid_i           : STD_LOGIC;
    signal msgout_last_i            : STD_LOGIC;
    signal blakley_C_output_valid_i : STD_LOGIC;
    signal blakley_P_output_valid_i : STD_LOGIC;
    signal blakley_finished_i       : STD_LOGIC;
    
    -- State registers and signals
    type state_type is (STATE_IDLE, STATE_START, STATE_WAITING);
    signal state_r, state_nxt       : state_type;
    
begin
    -- Checks if the message coming in is valid and if the message is ready to be sent out
    -- Also checks if encryption is currently running
    -- If the system is not running the next message will be accepted
    process(msgout_ready, state_r) begin
        if(state_r = STATE_IDLE) then
            msgin_ready_i   <= msgout_ready;
        else
            msgin_ready_i   <= '0';
        end if;
    end process;
    
    msgin_ready     <= msgin_ready_i;
    system_start_i  <= msgin_valid and msgin_ready_i;
    system_start    <= system_start_i;
    
    -- Clocks the new value into the state, index and output registers
    process(clk, reset_n)   begin
        if(reset_n = '0') then
            state_r                     <= STATE_IDLE;
            blakley_P_output_valid_r    <= '0';
            blakley_C_output_valid_r    <= '0';
            bit_index_r                 <= (others => '0');
            msgin_last_r                <= '0';
        elsif(clk'event and clk = '1') then
            state_r                     <= state_nxt;
            bit_index_r                 <= bit_index_i;
            blakley_P_output_valid_r    <= blakley_P_output_valid_i;
            blakley_C_output_valid_r    <= blakley_C_output_valid_i;
            if(system_start_i = '1') then
                msgin_last_r                <= msgin_last;
            end if;
            --if ready and valid then
            --    msgin_r <= msgin_last;
            --end
        end if;
    end process;
    
    -- Sets the msgin_last register high when msgin_last is high and keeps it high
    --process(msgin_last, msgin_last_r) begin
    --    if (msgin_last = '1') then
    --        msgin_last_i <= '1';
    --    else
    --        msgin_last_i <= msgin_last_r;
    --    end if;
    --end process;
    
    -- Sets msgout_last high when msgin_last is high and the final message has been encrypted
    msgout_last <= msgin_last_r and msgout_valid_i;
    
    -- State machine
    process(state_r, blakley_P_output_valid, blakley_C_output_valid, system_start_i, blakley_P_output_valid_r, blakley_C_output_valid_r, bit_index_r) begin     
        case(state_r) is
            when STATE_IDLE =>
                --and msgout_valid = '0'
                if(system_start_i = '1' ) then
                    state_nxt   <= STATE_START;
                else
                    state_nxt   <= STATE_IDLE;
                end if;
                
                --if(msgout_valid = '1' and msgout_ready = '1') then
                --    msgout_valid_i <= '0';
                --else
                --    msgout_valid_i <= '1';
                --end if;             
                
                --if(msgout_valid_i = '1' and msgout_ready = '0') then
                --    msgout_valid_i <= '1';
                --else
                --    msgout_valid_i <= '0';
                --end if;
                
                --if(msgout_ready = '1' and blakley_finished = '1') then
                --    msgout_valid_i      <= '1';
                --    blakley_finished_i  <= '1';
                --else
                --    msgout_valid_i      <= '0';
                --    blakley_finished_i  <= '0';
                --end if;
                
                -- Explicitly define signals to avoid latches
                bit_index_i                 <= (others => '0');
                blakley_C_input_valid_i     <= '0';
                blakley_P_input_valid_i     <= '0';
                blakley_C_output_valid_i    <= '0';
                blakley_P_output_valid_i    <= '0';
                blakley_finished_i          <= '0';                             
                
            when STATE_START =>
                -- Check for final iteration
                if(to_integer(unsigned(bit_index_r)) = C_block_size) then
                    state_nxt               <= STATE_IDLE;
                    bit_index_i             <= (others => '0');
                    blakley_finished_i      <= '1';
                    blakley_C_input_valid_i <= '0';
                    blakley_P_input_valid_i <= '0';
                    msgout_valid_i          <= '1';
                    --msgout_valid_i          <= '0';
                else
                    state_nxt               <= STATE_WAITING;
                
                    -- Check for true bit in key at position bit_index and run Blakley to update C if true   
                    if (key(to_integer(unsigned(bit_index_r))) = '1') then
                        blakley_C_input_valid_i <= '1';
                    else
                        blakley_C_input_valid_i <= '0';
                    end if;
                                     
                    -- Blakeley for P should always run
                    blakley_P_input_valid_i <= '1';
                    blakley_finished_i      <= '0';                   
                    msgout_valid_i          <= '0';
                    bit_index_i             <= std_logic_vector(unsigned(bit_index_r) + 1);                    
                end if;
                
                -- Explicitly define signals to avoid latches
                blakley_C_output_valid_i    <= '0';
                blakley_P_output_valid_i    <= '0';
                
            when STATE_WAITING =>
                -- Checks if P is finished, sets the Blakley_P_output_valid register input and stops Blakley P from recieving new data
                if(blakley_P_output_valid = '1') then
                    blakley_P_output_valid_i    <= '1';
                    blakley_P_input_valid_i     <= '0';
                else
                    blakley_P_output_valid_i    <= blakley_P_output_valid_r;
                    blakley_P_input_valid_i     <= '1';
                end if;
                
                -- Checks if C is finished, sets the Blakley_C_output_valid register input and stops Blakley C from recieving new data
                if(blakley_C_output_valid = '1') then
                    blakley_C_output_valid_i    <= '1';
                    blakley_C_input_valid_i     <= '0';
                else
                    blakley_C_output_valid_i    <= blakley_C_output_valid_r;
                    blakley_C_input_valid_i     <= '1';
                end if;
                
                -- Checks if both Blakleys are completed
                if(blakley_P_output_valid_r = '1' and blakley_C_output_valid_r = '1') then
                    state_nxt           <= STATE_START;
                    blakley_finished_i  <= '1';                   
                else
                    state_nxt           <= STATE_WAITING;
                    blakley_finished_i  <= '0';                   
                end if;
                
                -- Explicitly define signals to avoid latches
                msgout_valid_i  <= '0';
                bit_index_i     <= bit_index_r;
                
            when others =>
                -- For undefined state, switch to IDLE and reset all signals
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