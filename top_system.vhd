library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_system is
    Port (
        CLK100MHZ : in STD_LOGIC;
        btn       : in STD_LOGIC_VECTOR(0 downto 0); -- Nút reset (BTN0)
        
        -- C?ng ra VGA Pmod
        vga_r     : out STD_LOGIC_VECTOR(3 downto 0);
        vga_g     : out STD_LOGIC_VECTOR(3 downto 0);
        vga_b     : out STD_LOGIC_VECTOR(3 downto 0);
        vga_hs    : out STD_LOGIC;
        vga_vs    : out STD_LOGIC
    );
end top_system;

architecture Behavioral of top_system is
    -- Tín hi?u n?i b? ?? n?i dây gi?a các kh?i
    signal clk_25mhz : std_logic;
    signal reset     : std_logic;
    
    signal active_vid_sig : std_logic;
    signal frame_tick_sig : std_logic;
    signal px_x, px_y     : integer;
    signal rgb_internal   : std_logic_vector(11 downto 0);

begin
    reset <= btn(0); -- Gán nút nh?n 0 làm Reset

    -- 1. G?i kh?i Clock Divider
    inst_clk_div: entity work.clock_div
    port map (
        clk_in  => CLK100MHZ,
        clk_out => clk_25mhz
    );

    -- 2. G?i kh?i VGA Controller
    inst_vga_ctrl: entity work.vga_controller
    port map (
        clk_vga      => clk_25mhz,
        rst          => reset,
        active_video => active_vid_sig,
        h_sync       => vga_hs,
        v_sync       => vga_vs,
        pixel_x      => px_x,
        pixel_y      => px_y,
        frame_tick   => frame_tick_sig
    );

    -- 3. G?i kh?i Text Generator
    inst_text_gen: entity work.text_generator
    port map (
        clk          => clk_25mhz,
        rst          => reset,
        active_video => active_vid_sig,
        pixel_x      => px_x,
        pixel_y      => px_y,
        frame_tick   => frame_tick_sig,
        rgb_out      => rgb_internal
    );

    -- Gán màu ra chân v?t lý
    vga_r <= rgb_internal(11 downto 8);
    vga_g <= rgb_internal(7 downto 4);
    vga_b <= rgb_internal(3 downto 0);

end Behavioral;