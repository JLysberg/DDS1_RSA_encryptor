library ieee;
use ieee.std_logic_1164.all;

entity control_buffer is
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
		msgin_last    : in STD_LOGIC;
		
		--msgin_ready_0 : in STD_LOGIC;
		--msgin_ready_1 : in STD_LOGIC;
	   
	    --msgin_valid_0 : out STD_LOGIC;
		--msgin_valid_1 : out STD_LOGIC;

		-- Input data
		message       : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
		key           : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );
        modulus       : in STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 );

		-- Ouput control
		msgout_ready  : in STD_LOGIC;
		msgout_valid  : out STD_LOGIC;

		msgout_last   : out STD_LOGIC;

		-- Output data
		result        : out STD_LOGIC_VECTOR ( C_block_size - 1 downto 0 )
		
	);
end control_buffer;


architecture behaviour of control_buffer is
    -- Internal signals
    signal msgin_ready_0   : STD_LOGIC;
    signal msgin_ready_1   : STD_LOGIC;
    signal msgin_valid_0   : STD_LOGIC;
    signal msgin_valid_1   : STD_LOGIC;
    signal msgout_valid_0  : STD_LOGIC;
    signal msgout_valid_1  : STD_LOGIC;
    signal msgout_last_0   : STD_LOGIC;
    signal msgout_last_1   : STD_LOGIC;
    signal result_0        : STD_LOGIC_VECTOR( C_block_size - 1 downto 0 );
    signal result_1        : STD_LOGIC_VECTOR( C_block_size - 1 downto 0 );
    signal exp0_finished   : STD_LOGIC;
    signal exp1_finished   : STD_LOGIC;
    --signal msgout_ready_0  : STD_LOGIC;
    --signal msgout_ready_1  : STD_LOGIC;
begin
	
	Exponentiation0 : entity work.exponentiation port map (
	   clk             => clk          ,
	   reset_n         => reset_n      ,
	   
	   msgin_valid     => msgin_valid_0  ,
	   msgin_ready     => msgin_ready_0  ,
	   msgin_last      => msgin_last   ,
	   
	   message         => message      ,
	   key             => key          ,
	   modulus         => modulus      ,

	   msgout_ready    => msgout_ready ,
	   msgout_valid    => msgout_valid_0 ,
	   msgout_last     => msgout_last_0  ,
	   exp_finished    => exp0_finished,
	   
	   result          => result_0
	);
	
    Exponentiation1 : entity work.exponentiation port map (
	   clk             => clk          ,
	   reset_n         => reset_n      ,
	   
	   msgin_valid     => msgin_valid_1  ,
	   msgin_ready     => msgin_ready_1  ,
	   msgin_last      => msgin_last   ,
	   
	   message         => message      ,
	   key             => key          ,
	   modulus         => modulus      ,

	   msgout_ready    => msgout_ready ,
	   msgout_valid    => msgout_valid_1 ,
	   msgout_last     => msgout_last_1  ,
	   exp_finished    => exp1_finished,
	   
	   result          => result_1
	);
	
	Control_buffer_controller : entity work.control_buffer_controller port map (
	   clk             => clk,
	   reset_n         => reset_n,
       msgin_ready      => msgin_ready,
	   msgin_valid     => msgin_valid,
	   msgin_ready_0   => msgin_ready_0,
	   --msgout_ready    => msgout_ready,
	   msgin_ready_1   => msgin_ready_1,
	   --msgout_ready_0  => msgout_ready_0,
       --msgout_ready_1  => msgout_ready_1,
	   msgin_valid_0   => msgin_valid_0,
       msgin_valid_1   => msgin_valid_1

       --msgin_last_0    => msgin_last_0,
       --msgin_last_1    => msgin_last_1
       
    );
    
    Control_buffer_datapath : entity work.control_buffer_datapath port map (
        clk             => clk,
        reset_n         => reset_n,
        result_0        => result_0,
        result_1        => result_1,
        msgout_ready    => msgout_ready,
        exp0_finished   => exp0_finished,
        exp1_finished   => exp1_finished,
        --msgout_ready_0  => msgout_ready_0,
        --msgout_ready_1  => msgout_ready_1,
        msgout_valid    => msgout_valid,
        msgout_valid_0  => msgout_valid_0,
        msgout_valid_1  => msgout_valid_1,
        msgout_last     => msgout_last,
        msgout_last_0   => msgout_last_0,
        msgout_last_1   => msgout_last_1,
        result          => result
    );   
end behaviour;
