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

    --clock wires
    signal w_clk, w_clock_reset, w_clk_tdm : std_logic;
    
    --twoscomp wires
    signal w_mux : std_logic_vector(7 downto 0);
    --bc K=4
    signal w_D3 : std_logic;
    signal w_D2, w_D1, w_D0 : std_logic_vector(3 downto 0);

    --sevensegdecoder wires
    signal w_data : std_logic_vector(3 downto 0);
    signal w_seg : std_logic_vector(6 downto 0);
    
    --controller wires
    signal w_controller_reset : std_logic;
    signal w_cycle : std_logic_vector(3 downto 0);
    
    --ALU wires
    signal w_A, w_B, w_result : std_logic_vector(7 downto 0);
    signal w_flags : std_logic_vector(3 downto 0);
    
    --TDM4 wires
    signal w_sel : std_logic_vector(3 downto 0);

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
            o_hund : out std_logic_vector(3 downto 0);
            o_tens : out std_logic_vector(3 downto 0);
            o_ones : out std_logic_vector(3 downto 0)
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
            o_seg_n : out std_logic_vector(6 downto 0)
        );
    end component sevenseg_decoder;
   
  
begin
    
    w_clock_reset <= btnU;
    w_controller_reset <= btnU;
    
	-- PORT MAPS ----------------------------------------
    
        THEALU : ALU
            port map (
                i_A => w_A,
                i_B => w_B,
                i_op => sw(2 downto 0),
                o_result => w_result,
                o_flags => w_flags
            );
    
        twoscomp : twos_comp
            port map (
                i_bin => w_mux,
                o_sign => w_D3, --sign
                o_hund => w_D2, --hundreds
                o_tens => w_D1, --tens
                o_ones => w_D0 --ones
            );
    
        seveseg : sevenseg_decoder
            port map(
                i_Hex => w_data,
                o_seg_n => w_seg
            );
            
        controller : controller_fsm
            port map(
                i_reset => w_controller_reset,
                i_adv => btnC,
                o_cycle => w_cycle
            );
    	   
        uut_inst : clock_divider 
	       generic map ( k_DIV => 25000000 )
	       port map (
		      i_clk => clk,
		      i_reset => w_clock_reset,
		      o_clk	=> w_clk
	       );  
	       
        THEtdm4 : TDM4
            port map(
                i_clk => w_clk_tdm,
                i_reset => w_controller_reset,
                --doesn't show sign in TDM4
                i_D3 => "0000",
                i_D2 => w_D2,
                i_D1 => w_D1,
                i_D0 => w_D0,
                o_data => w_data,
                o_sel => w_sel
            );
	      
	-- CONCURRENT STATEMENTS ----------------------------
	--C3C Putter helped walk me through these. I provided my own comments to prove my understanding of what each line of code does.
	
    --"making" a mux through the wire
	w_mux <= w_A when (w_cycle = "0010")else
	         w_B when (w_cycle = "0100") else
	         w_result when (w_cycle = "1000");
	         
	--logic for the display      
	an(3 downto 0) <= "1111" when (w_cycle = "0001") else
	                   w_sel;
	seg(6 downto 0) <= w_seg(6 downto 0) when (w_cycle = not "0001") else
	                   "0111111" when ((w_cycle = "1000") and (w_flags(3) = '1') and (w_sel = "0111")) else
	                   w_seg(6 downto 0);
	                   
	--logic for LEDs
	led(15 downto 12) <= w_flags(3 downto 0);
	
    led(3 downto 0) <= "0001" when w_cycle = "0001" else
                       "0010" when w_cycle = "0010" else 
                       "0100" when w_cycle = "0100" else  
                       "1000" when w_cycle = "1000" else  
                       "0000";  --catch all
                       
    --the registers at the start. they synchronize the inputs with the ALU
        REG_A : process(w_cycle)
        begin 
            if rising_edge(w_cycle(1)) then
                w_A <= sw(7 downto 0); 
            end if; 
    end process REG_A; 
    
    REG_B : process(w_cycle)
        begin 
            if rising_edge(w_cycle(2)) then
                w_B <= sw(7 downto 0); 
            end if; 
    end process REG_B; 
	
	
end top_basys3_arch;
