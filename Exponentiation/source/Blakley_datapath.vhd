library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Blakley_datapath is
    generic (
        C_block_size : integer := 256;
        Padding      : integer := 4
    );
    Port (
        -- Utility
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        
        -- Input control
        add_en          : in STD_LOGIC;
        run_en          : in STD_LOGIC;
        
        -- Input data    
        modulus         : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        input_a         : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        
        -- Output data        
        output          : out STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 )      
    );
end Blakley_datapath;

architecture Behavioral of Blakley_datapath is
    -- Internal registers
    signal R1_r     : STD_LOGIC_VECTOR ( C_block_size - 1 + padding downto 0 );
    signal R2_r     : STD_LOGIC_VECTOR ( C_block_size - 1 + padding downto 0 );
    signal R3_r     : STD_LOGIC_VECTOR ( C_block_size - 1 + padding downto 0 );
    signal R3s_r    : STD_LOGIC_VECTOR ( C_block_size - 1 + padding downto 0 );
    signal R4_r     : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
    
    -- Internal register inputs
    signal R1_i     : STD_LOGIC_VECTOR ( C_block_size - 1 + padding downto 0 );
    signal R2_i     : STD_LOGIC_VECTOR ( C_block_size - 1 + padding downto 0 );
    signal R3_i     : STD_LOGIC_VECTOR ( C_block_size - 1 + padding downto 0 );
    signal R4_i     : STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
    
begin
    -- Clocks new values into registers
    process (clk, reset_n) begin
        if(reset_n = '0') then
            R1_r   <= (others => '0');
            R2_r   <= (others => '0');
            R3_r   <= (others => '0');
            R3s_r  <= (others => '0');
            
        elsif(clk'event and clk = '1') then
        
            -- Only updates registers if state machine is NOT in IDLE state
            if (run_en = '1') then
                R1_r    <= R1_i;
                R2_r    <= R2_i;
                R3_r    <= R3_i;
                R3s_r   <= R3_r( C_block_size - 2 + padding downto 0 ) & '0';
                R4_r    <= R4_i;
            else
                R1_r    <= (others => '0');
                R2_r    <= (others => '0');
                R3_r    <= (others => '0');
                R3s_r   <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Adds the input to the register if bit is true
    process (add_en, R3s_r) begin
        if(add_en = '1') then
        
            -- Pads signal to make it possible to double 256 bit number
            R1_i    <= std_logic_vector(unsigned(x"0" & input_a) + unsigned(R3s_r));
        else
            R1_i    <= R3s_r;
        end if;
    end process;
    
    -- Subtracts modulus from the current value if current value is greater than or equal to padded modulus
    process (R1_r, modulus) begin
        if(R1_r >= (x"0" & modulus)) then
            R2_i   <= std_logic_vector(unsigned(R1_r) - unsigned(modulus));
        else 
            R2_i   <= R1_r;
        end if;            
    end process;
    
    -- Subtracts modulus from the current value if current value is greater than or equal to padded modulus
    process (R2_r, modulus) begin
        if(R2_r >= (x"0" & modulus)) then
            R3_i   <= std_logic_vector(unsigned(R2_r) - unsigned(modulus));
        else 
            R3_i   <= R2_r;
        end if;              
    end process;
    
    -- Updates output register and removes the padding if the state machine is NOT in the IDLE state
    process (run_en, R3_r, R4_r) begin
        if (run_en = '1') then
            R4_i    <= R3_r( C_block_size - 1 downto 0 );
        else
            R4_i    <= R4_r;
        end if;
    end process;
    
    output  <= R4_r;
                
end Behavioral;












