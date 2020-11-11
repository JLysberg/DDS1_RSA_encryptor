library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Blakley is
    generic (
        C_block_size    : integer := 256
    );
    Port (
        -- Utility
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        
        -- Input control
        input_valid     : in STD_LOGIC;
        
        -- Input data
        modulus         : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        input_a         : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        input_b         : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        
        -- Ouput control
        output_valid    : out STD_LOGIC;
        
        -- Output data
        output          : out STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 )                
    );
end Blakley;

architecture Behavioral of Blakley is
    -- Internal signals
    signal add_en           : STD_LOGIC;
    signal run_en           : STD_LOGIC;
    
begin

    Blakley_datapath : entity work.Blakley_datapath port map(
        clk             => clk      ,
        reset_n         => reset_n  ,
        
        add_en          => add_en   ,
        run_en          => run_en   ,
        
        modulus         => modulus  ,
        input_a         => input_a  ,
             
        output          => output       
    );
    
    Blakley_controller : entity work.Blakley_controller port map(
        clk             => clk          ,
        reset_n         => reset_n      ,
        
        input_valid     => input_valid  ,
    
        input_b         => input_b      ,
        
        output_valid    => output_valid ,
        
        add_en          => add_en       ,
        run_en          => run_en
    );
    
end Behavioral;
