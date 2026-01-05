library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
    Port (
        clk_vga      : in  STD_LOGIC; -- Xung 25MHz
        rst          : in  STD_LOGIC;
        active_video : out STD_LOGIC; -- =1 khi ???c phép hi?n th? màu
        h_sync       : out STD_LOGIC;
        v_sync       : out STD_LOGIC;
        pixel_x      : out INTEGER;   -- T?a ?? ngang
        pixel_y      : out INTEGER;   -- T?a ?? d?c
        frame_tick   : out STD_LOGIC  -- Báo hi?u h?t 1 khung hình
    );
end vga_controller;

architecture Behavioral of vga_controller is
    -- Thông s? VGA 640x480 @ 60Hz
    constant H_TOTAL : integer := 800;
    constant V_TOTAL : integer := 525;
    
    signal h_cnt : integer range 0 to H_TOTAL-1 := 0;
    signal v_cnt : integer range 0 to V_TOTAL-1 := 0;
begin
    process(clk_vga, rst)
    begin
        if rst = '1' then
            h_cnt <= 0;
            v_cnt <= 0;
        elsif rising_edge(clk_vga) then
            if h_cnt = H_TOTAL - 1 then
                h_cnt <= 0;
                if v_cnt = V_TOTAL - 1 then
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
                end if;
            else
                h_cnt <= h_cnt + 1;
            end if;
        end if;
    end process;

    -- Tín hi?u ??ng b? (Sync)
    h_sync <= '0' when (h_cnt < 96) else '1';
    v_sync <= '0' when (v_cnt < 2) else '1';
    
    -- Vùng hi?n th? (Active Video)
    -- D? li?u hi?n th? t? (144, 35) ??n (784, 515)
    active_video <= '1' when (h_cnt >= 144 and h_cnt < 784 and v_cnt >= 35 and v_cnt < 515) else '0';
    
    -- Xu?t t?a ?? (G?c 0,0 là góc trên trái vùng hi?n th?)
    pixel_x <= h_cnt - 144;
    pixel_y <= v_cnt - 35;
    
    -- Xung báo h?t frame (dùng ?? ?i?u ch?nh t?c ?? ch?y ch?)
    frame_tick <= '1' when (h_cnt = H_TOTAL-1 and v_cnt = V_TOTAL-1) else '0';

end Behavioral;