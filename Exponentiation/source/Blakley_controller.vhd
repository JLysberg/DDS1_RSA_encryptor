library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

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
    signal add_en_r             : STD_LOGIC;
    signal add_en_i             : STD_LOGIC;
    
    signal output_valid_i       : STD_LOGIC;

    signal bit_index_r          : STD_LOGIC_VECTOR ( 10 downto 0 );
    signal bit_index_i          : STD_LOGIC_VECTOR ( 10 downto 0 );
    signal width                : integer;
    
    type state_type is (STATE_IDLE, STATE_ADD, STATE_MOD1, STATE_MOD2, STATE_SH);
    signal state_r, state_nxt   : state_type;
    
begin
    width   <= C_block_size;
    --width   <= 256;

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
        end if;
    end process;
   
    -- FSM
    process(state_r, bit_ready, input_b) begin        
        case(state_r) is 
            when STATE_IDLE =>
                output_valid_i  <= '0';
                add_en_i        <= '0';
                bit_index_i     <= (others => '0');
                
                if(bit_ready = '1') then
                    state_nxt           <= STATE_ADD;
                else 
                    state_nxt           <= STATE_IDLE;
                end if;
                
            when STATE_ADD =>
                if(to_integer(unsigned(bit_index_r)) = width) then
                    bit_index_i     <= (others => '0');
                    output_valid_i  <= '1';
                    add_en_i        <= '0';
                    state_nxt       <= STATE_IDLE;
                else
                    if(input_b(width - to_integer(unsigned(bit_index_r)) - 1) = '1') then
                        add_en_i    <= '1';
                    else
                        add_en_i    <= '0';
                    end if;
                    bit_index_i     <= std_logic_vector(unsigned(bit_index_r) + 1);
                    state_nxt       <= STATE_MOD1;
                    output_valid_i  <= '0';
                end if;
                
            when STATE_MOD1 =>
                state_nxt           <= STATE_MOD2;
                bit_index_i         <= bit_index_r;
                output_valid_i      <= '0';
                add_en_i            <= add_en_r;
                
            when STATE_MOD2 =>
                state_nxt           <= STATE_SH;
                bit_index_i         <= bit_index_r;
                output_valid_i      <= '0';
                add_en_i            <= add_en_r;
                
            when STATE_SH =>
                state_nxt           <= STATE_ADD;
                bit_index_i         <= bit_index_r;
                output_valid_i      <= '0';
                add_en_i            <= add_en_r;
                
            when others =>
                state_nxt           <= STATE_IDLE;
                bit_index_i         <= (others => '0');
                output_valid_i      <= '0';  
                add_en_i            <= '0';
                
        end case;
    end process;
    
    add_en          <= add_en_r;
    output_valid    <= output_valid_i;
   

end Behavioral;
