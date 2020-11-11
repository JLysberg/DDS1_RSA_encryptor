library ieee;
use ieee.std_logic_1164.all;

entity exponentiation is
	generic (
		C_block_size  : integer := 256
	);
	port (
	    --utility
		clk           : in STD_LOGIC;
		reset_n       : in STD_LOGIC;
	
		-- Input control
		msgin_valid   : in STD_LOGIC;
		msgin_ready   : out STD_LOGIC;

		-- Input data
		message       : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
		key           : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        modulus       : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );

		-- Ouput control
		msgout_ready  : in STD_LOGIC;
		msgout_valid  : out STD_LOGIC;

		-- Output data
		result        : out STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 )
		
		-- Last message
		--msgin_last  : in STD_LOGIC;
		--msgout_last : out STD_LOGIC
	);
end exponentiation;


architecture expBehave of exponentiation is
begin
	
	RL_binary : entity work.RL_binary port map (
	   clk             => clk,
	   reset_n         => reset_n,
	   
	   msgin_valid     => msgin_valid,
	   msgin_ready     => msgin_ready,
	   
	   message         => message,
	   key             => key,
	   modulus         => modulus,

	   msgout_ready    => msgout_ready,
	   msgout_valid    => msgout_valid,
	   
	   result          => result
        
       --msgin_last    => msgin_last,
	   --msgout_last   => msgout_last,
	);
	
end expBehave;













