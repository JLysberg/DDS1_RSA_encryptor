library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RL_binary is
	generic (
		C_block_size    : integer := 256
	);
    Port (
        -- Utility
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        
        -- Input control
        msgin_valid     : in STD_LOGIC;
        msgin_ready     : out STD_LOGIC;
        
        -- Input data
        message         : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        key             : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        modulus         : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        
        -- Ouput control
        msgout_ready    : in STD_LOGIC;
        msgout_valid    : out STD_LOGIC;
        
        -- Output data      
        result          : out STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 )
        
    );
end RL_binary;

architecture Behavioral of RL_binary is
    -- Internal signals
    signal blakley_C_input_valid    : STD_LOGIC;
    signal blakley_P_input_valid    : STD_LOGIC;
    
    signal blakley_C_output_valid   : STD_LOGIC;
    signal blakley_P_output_valid   : STD_LOGIC;
    
    signal system_start             : STD_LOGIC;
    signal blakley_finished         : STD_LOGIC;
    
    signal C                        : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
    signal P                        : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
    
    signal C_nxt                    : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
    signal P_nxt                    : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );    

begin

    RL_binary_datapath : entity work.RL_binary_datapath port map(
        clk                 => clk,
        reset_n             => reset_n,
        
        message             => message,
        P_nxt               => P_nxt,
        C_nxt               => C_nxt,
        system_start        => system_start,
        blakley_finished    => blakley_finished,
        
        P                   => P,
        C                   => C,
        result              => result        
    );
    
    RL_binary_controller : entity work.RL_binary_controller port map(
        clk                     => clk,
        reset_n                 => reset_n,
        
        msgin_ready             => msgin_ready,
        msgin_valid             => msgin_valid,
        
        system_start            => system_start,
        
        key                     => key,
        
        msgout_valid            => msgout_valid,
        msgout_ready            => msgout_ready,
        
        blakley_C_input_valid   => blakley_C_input_valid,
        blakley_P_input_valid   => blakley_P_input_valid,
        blakley_C_output_valid  => blakley_C_output_valid,
        blakley_P_output_valid  => blakley_P_output_valid,        
        blakley_finished        => blakley_finished
    );
    
    Blakley_C : entity work.Blakley port map (
        clk             => clk,
        reset_n         => reset_n,
        
        modulus         => modulus,
        input_a         => P,
        input_b         => C,
        input_valid     => blakley_C_input_valid,
        
        output          => C_nxt,
        output_valid    => blakley_C_output_valid
    );
    
    Blakley_P : entity work.Blakley port map (
        clk             => clk,
        reset_n         => reset_n,
        
        modulus         => modulus,
        input_a         => P,
        input_b         => P,
        input_valid     => blakley_P_input_valid,
        
        output          => P_nxt,
        output_valid    => blakley_P_output_valid
    );

end Behavioral;
