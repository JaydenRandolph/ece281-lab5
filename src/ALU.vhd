----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

    component ripple_adder is
        port(
           A : in STD_LOGIC_VECTOR (3 downto 0);
           B : in STD_LOGIC_VECTOR (3 downto 0);
           Cin : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (3 downto 0);
           Cout : out STD_LOGIC
        );
    end component ripple_adder;
    
    signal w_carry  : std_logic;

begin

    rippleadder1 : ripple_adder
    port map(
        A => i_A(3 downto 0),
        B => i_B(3 downto 0),
        Cin => Cin,
        S => S(3 downto 0),
        Cout => w_carry
    );
    
    rippleadder2 : ripple_adder
    port map(
        A => i_A(7 downto 4),
        B => i_B(7 downto 4),
        Cin => w_carry,
        S => S(7 downto 4),
        Cout => Cout
    );

    with i_op select
    o_result <= i_A + i+B when "000", --aDd
                i_A - i_B when "001", --subtract
                i_A and i_B when"010", --aNd
                i_A or i_B when "011", --or
                (others => '0') when others; --catch all
                
    with i_op select          
    o_flags <= 
    
                 
                

end Behavioral;
