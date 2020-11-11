library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RL_binary_datapath is
	generic (
		C_block_size        : integer := 256
	);
    Port (
        -- Utility
        clk                 : in STD_LOGIC;
        reset_n             : in STD_LOGIC;
        
        -- Input control
        system_start        : in STD_LOGIC;
        blakley_finished    : in STD_LOGIC;
        
        -- Input data
        message             : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        C_nxt               : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        P_nxt               : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        
        -- Output data
        C                   : out STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );  
        P                   : out STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 ); 
        result              : out STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 )       
        );
end RL_binary_datapath;

architecture Behavioral of RL_binary_datapath is
    -- Internal registers
    signal C_r      : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
    signal P_r      : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
    
    -- Internal register inputs
    signal C_i      : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
    signal P_i      : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
    
    -- Constants
    constant one    : std_logic_vector( C_block_size - 1 downto 0 ) := (0 => '1', others => '0');

begin
    -- Clocks the new value into the C and P registers
    process (clk, reset_n) begin
        if(reset_n = '0') then
            C_r <= (others => '0');  
            P_r <= (others => '0');                       
        elsif(clk'event and clk = '1') then
            C_r <= C_i;     
            P_r <= P_i;                                        
        end if;
    end process;
    
    -- Mux to decide which value to put in C and R register inputs
    process (system_start, blakley_finished, message, P_r, C_r, P_nxt, C_nxt) begin
        -- Puts the initial values into the C and P register inputs
        if(system_start = '1') then
            C_i <= one;
            P_i <= message;
                        
        -- Puts the value from the finished blakley blocks into the C and P register inputs
        elsif(blakley_finished = '1') then
            C_i <= C_nxt;
            P_i <= P_nxt;         
        else
            C_i <= C_r;
            P_i <= P_r;          
        end if;
    end process;
    
    C       <= C_r;
    P       <= P_r;
    result  <= C_r;
    
end Behavioral;
