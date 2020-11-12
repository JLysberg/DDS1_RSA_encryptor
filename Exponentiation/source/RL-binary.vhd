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
        msgin_last      : in STD_LOGIC;
        
        -- Input data
        message         : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        key             : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        modulus         : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        
        -- Ouput control
        msgout_ready    : in STD_LOGIC;
        msgout_valid    : out STD_LOGIC;
        msgout_last     : out STD_LOGIC;
        
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
        clk                 => clk              ,
        reset_n             => reset_n          ,
        
        system_start        => system_start     ,
        blakley_finished    => blakley_finished ,
        
        message             => message          ,
        C_nxt               => C_nxt            ,
        P_nxt               => P_nxt            ,
        
        C                   => C                ,
        P                   => P                ,     
        result              => result        
    );
    
    RL_binary_controller : entity work.RL_binary_controller port map(
        clk                     => clk                      ,
        reset_n                 => reset_n                  ,
        
        msgin_valid             => msgin_valid              ,
        msgin_ready             => msgin_ready              ,
        msgin_last              => msgin_last               ,
        
        system_start            => system_start             ,
        
        key                     => key                      ,
        
        msgout_valid            => msgout_valid             ,
        msgout_ready            => msgout_ready             ,
        msgout_last             => msgout_last              ,
        
        blakley_C_input_valid   => blakley_C_input_valid    ,
        blakley_P_input_valid   => blakley_P_input_valid    ,
        blakley_C_output_valid  => blakley_C_output_valid   ,
        blakley_P_output_valid  => blakley_P_output_valid   ,        
        blakley_finished        => blakley_finished
    );
    
    Blakley_C : entity work.Blakley port map (
        clk             => clk                      ,
        reset_n         => reset_n                  ,
        
        input_valid     => blakley_C_input_valid    ,
        
        modulus         => modulus                  ,
        input_a         => P                        ,
        input_b         => C                        ,
        
        output_valid    => blakley_C_output_valid   ,
             
        output          => C_nxt      
    );
    
    Blakley_P : entity work.Blakley port map (
        clk             => clk                      ,
        reset_n         => reset_n                  ,
        
        input_valid     => blakley_P_input_valid    ,
        
        modulus         => modulus                  ,
        input_a         => P                        ,
        input_b         => P                        ,
        
        output_valid    => blakley_P_output_valid   ,
                
        output          => P_nxt      
    );

end Behavioral;
