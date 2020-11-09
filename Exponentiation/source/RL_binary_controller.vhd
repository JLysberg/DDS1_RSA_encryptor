library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.math_real.all; 

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
    signal true_bit_ready_i : STD_LOGIC;
    signal next_bit_ready_i : STD_LOGIC;
    signal output_ready_i   : STD_LOGIC;
    signal valid_out_i      : STD_LOGIC;
    
    signal output_valid_i   : STD_LOGIC;
    
    signal output_valid_P_i : STD_LOGIC;
    signal output_valid_C_i : STD_LOGIC;
    signal output_valid_P_r : STD_LOGIC;
    signal output_valid_C_r : STD_LOGIC;
    
    signal bit_index_r      : STD_LOGIC_VECTOR ( 10 downto 0 );
    signal bit_index_i      : STD_LOGIC_VECTOR ( 10 downto 0 );
    --signal index            : integer;
    signal width            : integer;
    
    type state_type is (STATE_IDLE, STATE_START, STATE_WAITING);
    signal state_r, state_nxt : state_type;
    

begin
    ready_in_i      <= ready_out;   
    ready_in        <= ready_in_i;
    input_ready_i   <= valid_in and ready_in_i;
    input_ready     <= input_ready_i;
    width           <= C_block_size;
    
    process(clk, reset_n)   begin
        if(reset_n = '0') then
            state_r             <= STATE_IDLE;
            --output_valid_i      <= '0';
            --true_bit_ready_i    <= '0';
            --next_bit_ready_i    <= '0';
            --output_ready_i      <= '0';
            --valid_out_i         <= '0';
            output_valid_P_r      <= '0';
            output_valid_C_r      <= '0';
            bit_index_r               <= (others => '0');
        elsif(clk'event and clk = '1') then
            state_r             <= state_nxt;
            bit_index_r         <= bit_index_i;
            output_valid_P_r    <= output_valid_P_i;
            output_valid_C_r    <= output_valid_C_i;
        end if;
    end process;
    
    process(state_r, output_valid_P, output_valid_C, input_ready_i) begin
        -- Default assignments
        
        case(state_r) is
            when STATE_IDLE =>
                if(input_ready_i = '1') then
                    state_nxt <= STATE_START;
                else
                    state_nxt       <= STATE_IDLE;
                end if;
                output_valid_i      <= '0';
                true_bit_ready_i    <= '0';
                next_bit_ready_i    <= '0';
                output_ready_i      <= '0';
                valid_out_i         <= '0';
                bit_index_i         <= (others => '0');
                output_valid_C_i    <= '0';
                output_valid_P_i    <= '0';
            when STATE_START =>
                output_valid_C_i     <= '0';
                output_valid_P_i     <= '0';
                if(to_integer(unsigned(bit_index_r)) = width) then
                    bit_index_i          <= (others => '0');
                    output_valid_i       <= '1';
                    true_bit_ready_i     <= '0';
                    next_bit_ready_i     <= '0';
                    valid_out_i          <= '1';
                    output_ready_i       <= '1';
                    state_nxt            <= STATE_IDLE;
                else
                    output_valid_i       <= '0';
                    if (key(to_integer(unsigned(bit_index_r))) = '1') then
                        true_bit_ready_i <= '1';
                    else
                        true_bit_ready_i <= '0';
                    end if;
                    next_bit_ready_i     <= '1';
                    valid_out_i          <= '0';
                    output_ready_i       <= '0';
                    bit_index_i          <= std_logic_vector(unsigned(bit_index_r) + 1);
                    state_nxt            <= STATE_WAITING;
                end if;
            when STATE_WAITING =>
                if(output_valid_P = '1') then
                    output_valid_P_i    <= '1';
                    next_bit_ready_i    <= '0';
                else
                    output_valid_P_i <= output_valid_P_r;
                end if;
                if(output_valid_C = '1') then
                    output_valid_C_i <= '1';
                    true_bit_ready_i    <= '0';
                else
                    output_valid_C_i <= output_valid_C_r;
                end if;
                if(output_valid_P_r = '1' and output_valid_C_r = '1') then
                    output_valid_i <= '1';
                    state_nxt <= STATE_START;
                else
                    output_valid_i <= '0';
                    state_nxt      <= STATE_WAITING;
                end if;
                true_bit_ready_i    <= '1';
                next_bit_ready_i    <= '1';
                output_ready_i      <= '0';
                valid_out_i         <= '0';
                bit_index_i         <= bit_index_r;
            when others =>
                state_nxt           <= STATE_IDLE;
                output_valid_i      <= '0';
                true_bit_ready_i    <= '0';
                next_bit_ready_i    <= '0';
                output_ready_i      <= '0';
                valid_out_i         <= '0';
                bit_index_i         <= (others => '0');
                output_valid_C_i    <= '0';
                output_valid_P_i    <= '0';
        end case;
    end process;

    output_valid    <= output_valid_i;
    output_ready    <= output_ready_i;
    true_bit_ready  <= true_bit_ready_i;
    next_bit_ready  <= next_bit_ready_i;
    valid_out       <= valid_out_i;

end Behavioral;