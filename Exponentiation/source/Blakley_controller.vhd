library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Blakley_controller is
    generic (
        C_block_size : integer := 260
    );
    Port (
        clk                 : in STD_LOGIC;
        reset_n             : in STD_LOGIC;
    
        input_b             : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        input_valid         : in STD_LOGIC;
        
        output_valid        : out STD_LOGIC;
        
        add_en              : out STD_LOGIC;
        run_en              : out STD_LOGIC
    );
end Blakley_controller;

architecture Behavioral of Blakley_controller is
    -- Internal registers
    signal add_en_r             : STD_LOGIC;
    signal output_valid_r       : STD_LOGIC;
    signal bit_index_r          : STD_LOGIC_VECTOR ( 10 downto 0 );
    
    -- Internal register inputs
    signal add_en_i             : STD_LOGIC;
    signal output_valid_i       : STD_LOGIC;
    signal bit_index_i          : STD_LOGIC_VECTOR ( 10 downto 0 );
    
    -- Internal control signal
    signal run_en_i             : STD_LOGIC;
    
    type state_type is (STATE_IDLE, STATE_ADD, STATE_MOD1, STATE_MOD2, STATE_SH);
    signal state_r, state_nxt   : state_type;
    
begin
    -- Clocked state switch and reset signal
    process(clk, reset_n) begin
        if(reset_n = '0') then
            state_r             <= STATE_IDLE;
            bit_index_r         <= (others => '0');
            add_en_r            <= '0';
        elsif(clk'event and clk = '1') then
            state_r             <= state_nxt;
            bit_index_r         <= bit_index_i;
            add_en_r            <= add_en_i;
            output_valid_r      <= output_valid_i;
        end if;
    end process;
   
    -- State machine
    process(state_r, input_valid, input_b) begin        
        case(state_r) is 
            when STATE_IDLE =>
                -- Switch to operating state if input is valid
                if(input_valid = '1') then
                    state_nxt   <= STATE_ADD;
                else 
                    state_nxt   <= STATE_IDLE;
                end if;
                
                -- Explicitly define signals to avoid latches
                add_en_i        <= '0';
                run_en_i        <= '0';
                bit_index_i     <= (others => '0');
                output_valid_i  <= output_valid_r;
                
            when STATE_ADD =>
                -- Enable synchronous clocking of data path registers
                run_en_i        <= '1';
                
                -- Check for final iteration
                if(to_integer(unsigned(bit_index_r)) = C_block_size) then
                    state_nxt       <= STATE_IDLE;
                    add_en_i        <= '0';
                    bit_index_i     <= (others => '0');
                    output_valid_i  <= '1';
                else
                    state_nxt       <= STATE_MOD1;
                    
                    -- Check for true bit of input_b at position bit_index, and signal addition to data path
                    if(input_b(C_block_size - to_integer(unsigned(bit_index_r)) - 1) = '1') then
                        add_en_i    <= '1';
                    else
                        add_en_i    <= '0';
                    end if;
                    
                    bit_index_i     <= std_logic_vector(unsigned(bit_index_r) + 1);
                    output_valid_i  <= '0';
                end if;
                
            when STATE_MOD1 =>
                -- Switch state
                state_nxt           <= STATE_MOD2;
                
                -- Explicitly define signals to avoid latches
                run_en_i            <= '1';
                bit_index_i         <= bit_index_r;
                output_valid_i      <= output_valid_r;
                add_en_i            <= add_en_r;
                
            when STATE_MOD2 =>
                -- Switch state
                state_nxt           <= STATE_SH;
                
                -- Explicitly define signals to avoid latches
                run_en_i            <= '1';
                bit_index_i         <= bit_index_r;
                output_valid_i      <= output_valid_r;
                add_en_i            <= add_en_r;
                
            when STATE_SH =>
                -- Switch state
                state_nxt           <= STATE_ADD;
                
                -- Explicitly define signals to avoid latches
                run_en_i            <= '1';
                bit_index_i         <= bit_index_r;
                output_valid_i      <= '0';
                add_en_i            <= add_en_r;
                
            when others =>
                -- For undefined state, switch to IDLE and reset all signals
                state_nxt           <= STATE_IDLE;
                run_en_i            <= '0';
                bit_index_i         <= (others => '0');
                output_valid_i      <= '0';  
                add_en_i            <= '0';
                
        end case;
    end process;
    
    run_en          <= run_en_i;
    add_en          <= add_en_r;
    output_valid    <= output_valid_r;
   

end Behavioral;
