--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals

    signal w_clk : std_logic;
    signal w_clock_reset : std_logic;
    signal w_controller_reset : std_logic;
    signal w_data : std_logic_vector(3 downto 0);
    signal w_clk_tdm : std_logic;
    signal w_D3 : std_logic;
    signal w_D2 : std_logic;
    signal w_D1 : std_logic;
    signal w_D0 : std_logic;


    

    component controller_fsm is
        port(
            i_reset : in std_logic;
            i_adv : in std_logic;
            o_cycle : out std_logic_vector(3 downto 0)
        );
    end component controller_fsm;
    
	component clock_divider is
        generic ( constant k_DIV : natural := 2	); -- How many clk cycles until slow clock toggles
                                                   -- Effectively, you divide the clk double this 
                                                   -- number (e.g., k_DIV := 2 --> clock divider of 4)
        port ( 	i_clk    : in std_logic;
                i_reset  : in std_logic;		   -- asynchronous
                o_clk    : out std_logic 	       -- divided (slow) clock
        );
    end component clock_divider;
    
    component ALU is
        port(
            i_A : in std_logic_vector(7 downto 0);
            i_B : in std_logic_vector(7 downto 0);
            i_op : in std_logic_vector(2 downto 0);
            o_result : out std_logic_vector(7 downto 0);
            o_flags : out std_logic_vector(3 downto 0)
        );
    end component ALU;
    
    component twos_comp is
        port(
            i_bin : in std_logic_vector(7 downto 0);
            o_sign : out std_logic;
            o_hund : out std_logic;
            o_tens : out std_logic;
            o_ones : out std_logic
        );
    end component twos_comp;
    
	component TDM4 is
		generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
        Port ( i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC; -- asynchronous
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	   );
    end component TDM4;
    
    component sevenseg_decoder is
        port(
            i_hex : in std_logic_vector(3 downto 0);
            o_seg : out std_logic_vector(6 downto 0)
        );
    end component sevenseg_decoder;
   
  
begin
    
    w_clock_reset <= btnU;
    w_controller_reset <= btnU;
    
	-- PORT MAPS ----------------------------------------
    
        THEALU : ALU
            port map (
                i_A => 
                i_B =>
                i_op => sw(2 downto 0);
                o_result => 
                o_flags => led(15 downto 12)
            );
    
        twoscomp : twos_comp
            port map (
                i_bin =>
                o_sign => w_D3;
                o_hund => w_D2;
                o_tens => w_D1;
                o_ones => w_D0;
            );
    
        seveseg : sevenseg_decoder
            port map(
                i_Hex => w_data,
                o_seg => seg
            );
    	   
        uut_inst : clock_divider 
	       generic map ( k_DIV => 25000000 )
	       port map (
		      i_clk => clk,
		      i_reset => clock_reset,
		      o_clk	=> w_clk
	       );  
	      
	
	
	-- CONCURRENT STATEMENTS ----------------------------
	
	
	
end top_basys3_arch;
