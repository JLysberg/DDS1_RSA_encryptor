library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_buffer_controller is
    Port ( 
    -- Utility 
        clk                     : in STD_LOGIC;
        reset_n                 : in STD_LOGIC;
        
        msgin_ready             : out STD_LOGIC;
        
        msgin_ready_0           : in STD_LOGIC;
        msgin_ready_1           : in STD_LOGIC;
        
        --msgout_ready            : in STD_LOGIC;
        
        --msgout_ready_0          : out STD_LOGIC;
        --msgout_ready_1          : out STD_LOGIC;
        
        msgin_valid             : in STD_LOGIC;
        
        msgin_valid_0            : out STD_LOGIC;
        msgin_valid_1            : out STD_LOGIC
    );
end control_buffer_controller;

architecture Behavioral of control_buffer_controller is
    -- Internal control signal
    signal msgin_valid_0_i  : STD_LOGIC;
    signal msgin_valid_1_i  : STD_LOGIC;
    
    signal msgin_ready_i    : STD_LOGIC;

    --signal msgout_ready_0_i : STD_LOGIC;
    --signal msgout_ready_1_i : STD_LOGIC;
    
    -- State registers and signals
    type state_type is (STATE_0, STATE_1);
    signal state_r, state_nxt       : state_type;

begin

    process(clk, reset_n)   begin
        if(reset_n = '0') then
            state_r                     <= STATE_0;
        elsif(clk'event and clk = '1') then
            state_r                     <= state_nxt;
        end if;
    end process;
    
    process(state_r, msgin_ready_0, msgin_ready_1, msgin_valid) begin
        case(state_r) is

            when STATE_0    =>
                if(msgin_ready_0 = '1' and msgin_valid = '1') then
                    --msgout_ready_0  <= '0';
                    --msgout_ready_1  <= '1';
                    state_nxt       <= STATE_1;
                    msgin_ready_i   <= msgin_ready_0;
                    msgin_valid_0_i <= '1';
                    msgin_valid_1_i <= '0';
                else
                    
                    --msgout_ready_0  <= '1';
                    --msgout_ready_1  <= '0';
                    msgin_ready_i   <= '0';
                    state_nxt       <= STATE_0;
                    msgin_valid_0_i <= '0';
                    msgin_valid_1_i <= '0';
                end if;
                
       
            when STATE_1    =>
                if(msgin_ready_1 = '1' and msgin_valid = '1') then
                    --msgout_ready_1  <= '0';
                    --msgout_ready_0  <= '1';
                    state_nxt       <= STATE_0;
                    msgin_ready_i   <= msgin_ready_1;
                    msgin_valid_0_i <= '0';
                    msgin_valid_1_i <= '1';
                else
                    --msgout_ready_0  <= '0';
                    --msgout_ready_1  <= '1';
                    msgin_ready_i   <= '0';
                    state_nxt       <= STATE_1;
                    msgin_valid_0_i <= '0';
                    msgin_valid_1_i <= '0';
                end if;
                
            when others =>
                -- For undefined state, switch to IDLE and reset all signals
                state_nxt                   <= STATE_0;
                msgin_valid_0_i <= '0';
                msgin_valid_1_i <= '0';
        end case;
    end process;
    
    
    msgin_ready     <= msgin_ready_i;
    msgin_valid_0   <= msgin_valid_0_i;
    msgin_valid_1   <= msgin_valid_1_i;
    --msgout_ready_0  <= msgout_ready_0_i;
    --msgout_ready_1  <= msgout_ready_1_i;

end Behavioral;
