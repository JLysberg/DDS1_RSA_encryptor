library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RL_binary_datapath is
	generic (
		C_block_size : integer := 256
	);
    Port (
        -- Clocks and resets
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        
        -- Data in interface 
        input_ready     : in STD_LOGIC;
        output_ready    : in STD_LOGIC;
        message         : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        P_nxt           : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        C_nxt           : in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        output_valid    : in STD_LOGIC;
        
        -- Data out interface
        P               : out STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        C               : out STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
        result          : out STD_LOGIC_VECTOR ( C_block_size-1 downto 0 )
        );
end RL_binary_datapath;

architecture Behavioral of RL_binary_datapath is
    
    -- Signals associated with the input registers
    signal P_r: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    signal C_r: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    signal P_i: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    signal C_i: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
    
    -- Constants
    constant one: std_logic_vector(C_block_size-1 downto 0) := (0 => '1', others => '0');

begin

    process (clk, reset_n) begin
        if(reset_n = '0') then
            P_r <= (others => '0');
            C_r <= (others => '0');                
        elsif(clk'event and clk = '1') then     
            P_r <= P_i;
            C_r <= C_i;                            
        end if;
    end process;
    
    process (input_ready, output_valid) begin
        if(input_ready = '1') then
            P_i <= message;
            C_i <= one;
        elsif(output_valid = '1') then
            P_i <= P_nxt;
            C_i <= C_nxt;
        else
            P_i <= P_r;
            C_i <= C_r;
        end if;
    end process;
    
    --process (C_r, output_ready) begin
    --    if(output_ready = '1') then
    --        result <= C_r;
    --    else
    --        result <= (others => '0');
    --    end if;
    --end process;
    
    result <= C_r;
    P <= P_r;
    C <= C_r;
    
end Behavioral;
