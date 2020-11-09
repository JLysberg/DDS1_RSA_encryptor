library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Blakley is
    generic (
        C_block_size    : integer := 260
    );
    Port (
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;

        modulus         : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        input_a         : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        input_b         : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        input_valid     : in STD_LOGIC;
        
        output          : out STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        output_valid    : out STD_LOGIC
    );
end Blakley;

architecture Behavioral of Blakley is
    signal add_en           : STD_LOGIC;
    signal run_en           : STD_LOGIC;
begin

    Blakley_datapath : entity work.Blakley_datapath port map(
        clk             => clk,
        reset_n         => reset_n,
        
        input_a         => input_a,
        modulus         => modulus,
        
        output          => output,
        
        add_en          => add_en,
        run_en          => run_en
    );
    
    Blakley_controller : entity work.Blakley_controller port map(
        clk             => clk,
        reset_n         => reset_n,
    
        input_b         => input_b,
        input_valid     => input_valid,
        
        output_valid    => output_valid,
        
        add_en          => add_en,
        run_en          => run_en
    );
    
end Behavioral;
