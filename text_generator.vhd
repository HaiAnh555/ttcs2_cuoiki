library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity text_generator is
    Port (
        clk          : in  STD_LOGIC; -- 25MHz
        rst          : in  STD_LOGIC;
        active_video : in  STD_LOGIC;
        pixel_x      : in  INTEGER;
        pixel_y      : in  INTEGER;
        frame_tick   : in  STD_LOGIC;
        rgb_out      : out STD_LOGIC_VECTOR(11 downto 0)
    );
end text_generator;

architecture Behavioral of text_generator is

    type font_mem is array (0 to 127) of std_logic_vector(63 downto 0);
    constant FONT : font_mem := (
        -- Ch? Hoa
        65 => x"183C66667E666600", -- A
        68 => x"786C6666666C7800", -- D
        72 => x"6666667E66666600", -- H
        76 => x"6060606060607E00", -- L
        84 => x"7E18181818181800", -- T
        
        -- Ch? Th??ng
        97 => x"00003C063E663E00", -- a
        99 => x"00003C6060603C00", -- c
        101=> x"00003C607C603C00", -- e
        104=> x"60605C6666666600", -- h
        105=> x"1800181818181800", -- i
        110=> x"00005C6666666600", -- n
        111=> x"00003C6666663C00", -- o
        112=> x"00007C66667C6060", -- p
        114=> x"00005C6660606000", -- r
        115=> x"00003C603C063C00", -- s
        116=> x"18187E1818180C00", -- t
        117=> x"0000666666663E00", -- u

        -- S?
        48 => x"3C66666666663C00", -- 0
        49 => x"1818381818183C00", -- 1
        50 => x"3C660C1830607E00", -- 2
        54 => x"1C30607C66663C00", -- 6
        
        32 => x"0000000000000000", -- Space
        others => x"FFFFFFFFFFFFFFFF" 
    );
    
    -- "Le Hai Anh DT060102 Thuc tap co so 2" 
    -- T?ng c?ng 36 ký t? bao g?m kho?ng tr?ng
    type text_arr is array (0 to 35) of integer;
    constant MSG : text_arr := (
        76, 101, 32,                    -- Le_
        72, 97, 105, 32,                -- Hai_a
        65, 110, 104, 32,               -- Anh_
        68, 84, 48, 54, 48, 49, 48, 50, -- DT060102_
        32, 84, 104, 117, 99, 32,       -- _Thuc_
        116, 97, 112, 32,               -- tap_
        99, 111, 32,                    -- co_
        115, 111, 32, 50                -- so_2
    );

    signal scroll_offset : integer := 0;
    signal speed_cnt     : integer := 0;
    signal color_idx     : integer range 0 to 2 := 0;
    
    constant SCALE   : integer := 4; 
    constant CHAR_W  : integer := 8 * SCALE; 

begin
    -- LOGIC 1: V? Pixel
    process(clk)
        variable x_scroll    : integer;
        variable char_idx    : integer;
        variable col_in_char : integer;
        variable row_in_char : integer;
        variable rom_data    : std_logic_vector(63 downto 0);
        variable char_code   : integer;
    begin
        if rising_edge(clk) then
            rgb_out <= (others => '0');
            if active_video = '1' then
                x_scroll := pixel_x + scroll_offset;
                
                if (pixel_y >= 200 and pixel_y < 200 + CHAR_W) then
                    char_idx := (x_scroll / CHAR_W); 
                    col_in_char := (x_scroll mod CHAR_W) / SCALE;
                    row_in_char := (pixel_y - 200) / SCALE;
                    
                    -- L?y mã ký t? (L?p l?i chu?i 36 ký t?)
                    char_code := MSG(char_idx mod 36);

                    rom_data := FONT(char_code);
                    
                    if rom_data( (7-row_in_char)*8 + (7-col_in_char) ) = '1' then
                        case color_idx is
                            when 0 => rgb_out <= x"F00"; -- ??
                            when 1 => rgb_out <= x"0F0"; -- L?c
                            when 2 => rgb_out <= x"00F"; -- Lam
                            when others => rgb_out <= x"FFF";
                        end case;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- LOGIC 2: ?i?u khi?n cu?n
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                scroll_offset <= 0;
                speed_cnt <= 0;
            elsif frame_tick = '1' then
                -- T?c ?? cu?n
                scroll_offset <= scroll_offset + 2; 
                
                -- ??i màu m?i khi cu?n ???c 1 ?o?n
                if (scroll_offset mod 128) = 0 then
                    if color_idx = 2 then color_idx <= 0;
                    else color_idx <= color_idx + 1; end if;
                end if;
                
                -- Reset cu?n khi ?i h?t chu?i (36 ký t? * chi?u r?ng + l? màn hình)
                if scroll_offset > (36 * CHAR_W + 640) then
                    scroll_offset <= 0;
                end if;
            end if;
        end if;
    end process;

end Behavioral;