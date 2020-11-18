library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_buffer_datapath is
	generic (
		C_block_size  : integer := 256
	);
    Port ( 
    -- Utility 
        clk                     : in STD_LOGIC;
        reset_n                 : in STD_LOGIC;
        
        result_0                : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        result_1                : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        
        msgout_ready            : in STD_LOGIC;
        --msgout_ready_0          : out STD_LOGIC;
        --msgout_ready_1          : out STD_LOGIC;
        
        exp0_finished           : out STD_LOGIC;
        exp1_finished           : out STD_LOGIC;
        
        msgout_last             : out STD_LOGIC;
        msgout_last_0           : in STD_LOGIC;
        msgout_last_1           : in STD_LOGIC;
        
        msgout_valid            : out STD_LOGIC;
        msgout_valid_0          : in STD_LOGIC;
        msgout_valid_1          : in STD_LOGIC;
        
        result                  : out STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 )
    );
end control_buffer_datapath;

architecture Behavioral of control_buffer_datapath is
    signal result_r : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
    signal result_i : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );

    signal msgout_valid_i   : STD_LOGIC;
    signal msgout_valid_0_i : STD_LOGIC;
    signal msgout_valid_1_i : STD_LOGIC;
    signal msgout_valid_r   : STD_LOGIC;
    
    signal exp0_finished_i    : STD_LOGIC;
    signal exp1_finished_i    : STD_LOGIC;
    
    signal exp0_finished_r  : STD_LOGIC;
    signal exp1_finished_r  : STD_LOGIC;

    --signal msgout_ready_0_i     : STD_LOGIC;
    --signal msgout_ready_1_i     : STD_LOGIC;
    signal msgout_last_i    : STD_LOGIC;
    --signal msgout_last_r    : STD_LOGIC;
begin

    process (clk, reset_n) begin
        if(reset_n = '0') then
            result_r <= (others => '0');
            msgout_valid_r <= '0';                     
        elsif(clk'event and clk = '1') then
            result_r <= result_i;
            msgout_valid_r  <= msgout_valid_i;
            exp0_finished_r <= exp0_finished_i;
            exp1_finished_r <= exp1_finished_i;                                        
        end if;
    end process;

    process(msgout_valid_0, msgout_valid_1, result_r, result_0, result_1, msgout_valid_i, msgout_ready, exp0_finished) begin
    
        if(msgout_valid_i = '1' and msgout_ready = '1' and exp0_finished = '0') then
            --msgout_valid_i <= '1';
            --msgout_valid_i <= '0';
            exp1_finished_i <= '0';
            exp0_finished_i <= '1';
            --result_i <= result_0;
            --msgout_last_i <= msgout_last_0;
        elsif(msgout_valid_i = '1' and msgout_ready = '1') then
            --msgout_valid_i <= '0';
            --msgout_valid_i <= '1';
            exp1_finished_i <= '1';
            exp0_finished_i <= '1';
            --result_i <= result_1;
            --msgout_last_i <= msgout_last_1;
        else
            --msgout_valid_i <= msgout_valid_r;
            --msgout_last_i   <= '0';
            --exp0_finished_i <= '0';
            --exp1_finished_i <= '0';
            --result_i <= result_r;
            --msgout_valid_i  <= '0';
        end if;
        if(msgout_valid_0 = '1') then
            result_i <= result_0;
            msgout_valid_i <= '1';
            msgout_last_i <= msgout_last_0;
        elsif(msgout_valid_1 = '1' and exp0_finished_i = '1') then
            result_i <= result_1;
            --exp1_finished_i <= '1';
            msgout_valid_i <= '1';
            --result_i <= result_1;
            msgout_last_i <= msgout_last_1;
        else
            --exp0_finished_i <= '0';
            --exp1_finished_i <= '0';
            msgout_valid_i  <= '0';
            --msgout_valid_1_i  <= '0';
            msgout_last_i   <= '0';
            result_i <= result_r;
        end if;
    end process;
    
    --msgout_ready_0  <= msgout_ready_0_i;
    --msgout_ready_1  <= msgout_ready_1_i;
    exp0_finished <= exp0_finished_i;
    exp1_finished <= exp1_finished_i;
    msgout_valid <= msgout_valid_i;
    msgout_last <= msgout_last_i;
    result <= result_r; 

end Behavioral;