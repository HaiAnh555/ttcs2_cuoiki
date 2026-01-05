library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_div is
    Port (
        clk_in  : in  STD_LOGIC; -- 100MHz t? Arty
        clk_out : out STD_LOGIC  -- 25MHz cho VGA
    );
end clock_div;

architecture Behavioral of clock_div is
    signal count : unsigned(1 downto 0) := "00";
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            count <= count + 1;
        end if;
    end process;
    
    -- L?y bit th? 1 (chia 4): 100MHz / 4 = 25MHz
    clk_out <= count(1);
end Behavioral;