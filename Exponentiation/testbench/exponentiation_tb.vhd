library ieee;
use ieee.std_logic_1164.all;


entity exponentiation_tb is
	generic (
		C_block_size : integer := 260
	);
end exponentiation_tb;


architecture expBehave of exponentiation_tb is

    -- Constants
    constant CLK_PERIOD    : time := 5 ns;
    constant RESET_TIME    : time := 5 ns;
    
    signal clk 			: STD_LOGIC := '0';
    signal reset_n 		: STD_LOGIC := '0';

	signal message 		: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ) := (others => '0');
	signal key 			: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 ) := (others => '0');
	signal valid_in 	: STD_LOGIC := '0';
	signal ready_in 	: STD_LOGIC := '0';
	signal ready_out 	: STD_LOGIC := '0';
	signal valid_out 	: STD_LOGIC := '0';
	signal result 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0) := (others => '0');
	signal modulus 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0) := (others => '0');
	--signal restart 		: STD_LOGIC := '0';

begin
	i_exponentiation : entity work.exponentiation
		port map (
			message   => message  ,
			key       => key      ,
			valid_in  => valid_in ,
			ready_in  => ready_in ,
			ready_out => ready_out,
			valid_out => valid_out,
			result    => result   ,
			modulus   => modulus  ,
			clk       => clk      ,
			reset_n   => reset_n
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
        ready_out       <= '1';
        valid_in        <= '1';
        --message         <= x"0000000000000000000000000000000000000000000000000000000000000015";
        --key             <= x"0000000000000000000000000000000000000000000000000000000000000085";
        --modulus         <= x"00000000000000000000000000000000000000000000000000000000000000FF";
        message         <= x"00000000011111111222222223333333344444444555555556666666677777777";
        key             <= x"00000000000000000000000000000000000000000000000000000000000010001";
        modulus         <= x"099925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
        wait for 1 * CLK_PERIOD;
        valid_in        <= '0';
        wait until valid_out = '1';
        wait for 2 * CLK_PERIOD;
        assert (not result = x"23026c469918f5ea097f843dc5d5259192f9d3510415841ce834324f4c237ac7") report "Test completed with correct output" severity note;
        assert false report "Test failed" severity failure;
        
    end process;


end expBehave;
