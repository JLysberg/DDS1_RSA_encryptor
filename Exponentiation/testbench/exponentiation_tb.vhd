library ieee;
use ieee.std_logic_1164.all;


entity exponentiation_tb is
	generic (
		C_block_size       : integer := 256
	);
end exponentiation_tb;


architecture expBehave of exponentiation_tb is

    -- Constants
    constant CLK_PERIOD    : time := 5 ns;
    constant RESET_TIME    : time := 5 ns;
    
    -- Utility
    signal clk 			   : STD_LOGIC := '0';
    signal reset_n 		   : STD_LOGIC := '0';
    
    -- Input control
    signal msgin_valid     : STD_LOGIC := '0';
	signal msgin_ready     : STD_LOGIC := '0';
	signal msgin_last      : STD_LOGIC := '0';
	
	-- Input data
	signal message 		   : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ) := (others => '0');
	signal key 			   : STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ) := (others => '0');
	signal modulus 		   : STD_LOGIC_VECTOR(C_block_size-1 downto 0) := (others => '0');
	
	-- Ouput control
	signal msgout_ready    : STD_LOGIC := '0';
	signal msgout_valid    : STD_LOGIC := '0';
	signal msgout_last     : STD_LOGIC := '0';
	
	-- Output data
	signal result 		   : STD_LOGIC_VECTOR(C_block_size-1 downto 0) := (others => '0');

begin
	i_exponentiation : entity work.exponentiation
		port map (
		    clk       => clk             ,
			reset_n   => reset_n         ,
			
			msgin_valid  => msgin_valid  ,
			msgin_ready  => msgin_ready  ,
			msgin_last   => msgin_last   ,
			
			message   => message         ,
			key       => key             ,
			modulus   => modulus         ,
			
			msgout_ready => msgout_ready ,
			msgout_valid => msgout_valid ,
			msgout_last  => msgout_last  ,
			
			result    => result   
		);
		
    -- Clock generation
	clk <= not clk after CLK_PERIOD/2;
	
	-- Reset generation
    reset_proc: process
    begin
        wait for RESET_TIME;
        reset_n     <= '1';
        wait;
    end process;
    
    -- Stimuli generation
    stimuli_proc: process
    begin
        wait for 2 * CLK_PERIOD;
        msgout_ready       <= '1';
        msgin_valid        <= '1';
        --message         <= x"0000000000000000000000000000000000000000000000000000000000000015";
        --key             <= x"0000000000000000000000000000000000000000000000000000000000000085";
        --modulus         <= x"00000000000000000000000000000000000000000000000000000000000000FF";
        message         <= x"0000000011111111222222223333333344444444555555556666666677777777";
        key             <= x"0000000000000000000000000000000000000000000000000000000000010001";
        modulus         <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
        wait for 2 * CLK_PERIOD;
        --msgin_valid        <= '0';
        wait until msgin_ready = '1';
        msgin_last      <= '1';
        message         <= x"8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff";
        wait until msgout_valid = '1';
        wait for 2 * CLK_PERIOD;
        msgin_last      <= '0';
        msgin_valid     <= '0';
        msgout_ready    <= '0';
        --assert (result = x"023026c469918f5ea097f843dc5d5259192f9d3510415841ce834324f4c237ac7") report "Encryption failed" severity failure;
        report "Encryption completed";
        wait for 2 * CLK_PERIOD;
        msgin_valid        <= '1';
        msgin_last         <= '1';
        msgout_ready       <= '1';
        wait until msgin_ready = '1';
        message         <= x"23026c469918f5ea097f843dc5d5259192f9d3510415841ce834324f4c237ac7";
        key             <= x"0cea1651ef44be1f1f1476b7539bed10d73e3aac782bd9999a1e5a790932bfe9";
        wait for 1 * CLK_PERIOD;
        wait until msgout_valid = '1';
        msgin_valid        <= '0';
        msgin_last         <= '0';
        msgout_ready       <= '0';
        --assert (not result = x"00000000011111111222222223333333344444444555555556666666677777777") report "Test completed with correct output" severity failure;
        wait for 2 * CLK_PERIOD;
        assert false report "Test failed" severity failure;
        
    end process;
    
end expBehave;
