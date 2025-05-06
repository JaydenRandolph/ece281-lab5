----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2025 01:35:19 PM
-- Design Name: 
-- Module Name: sevenseg_decoder - Behavioral
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

entity sevenseg_decoder is
    Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
           o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
end sevenseg_decoder;

architecture Behavioral of sevenseg_decoder is

signal connecting_wire : std_logic_vector(3 downto 0);

begin

--Wires up the Hex to a connecting wire that will then transfer the 4 bits to 7 bits in the box
connecting_wire(0) <= i_Hex(0);
connecting_wire(1) <= i_Hex(1);
connecting_wire(2) <= i_Hex(2);
connecting_wire(3) <= i_Hex(3);

--Codes the logic in the sevenseg decoder
    with connecting_wire select
        o_seg_n <=  "1000000" when "0000",
                "1111001" when "0001",
                "0100100" when "0010",
                "0110000" when "0011",
                "0011001" when "0100",
                "0010010" when "0101",
                "0000010" when "0110",
                "1111000" when "0111",
                "0000000" when "1000",
                "0011000" when "1001",
                "0001000" when "1010",
                "0000011" when "1011",
                "0100111" when "1100",
                "0100001" when "1101",
                "0000110" when "1110",
                "0001110" when "1111",
                "1111111" when others;

end Behavioral;
