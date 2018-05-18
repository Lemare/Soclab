library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity digital_cam_impl is
  Port (
    clk_50 : in STD_LOGIC;
    btn_RESET: in STD_LOGIC; -- KEY0; manual reset;
    slide_sw_resend_reg_values : in STD_LOGIC; -- rewrite all OV7670's registers;
    slide_sw_NORMAL_OR_EDGEDETECT : in STD_LOGIC; -- 0 normal, 1 edge detection;

    ov7670_pclk  : in STD_LOGIC;
    ov7670_xclk  : out STD_LOGIC;
    ov7670_vsync : in STD_LOGIC;
    ov7670_href  : in STD_LOGIC;
    ov7670_data  : in STD_LOGIC_vector(7 downto 0);
    ov7670_sioc  : out STD_LOGIC;
    ov7670_siod  : inout STD_LOGIC;
    ov7670_pwdn  : out STD_LOGIC;
    ov7670_reset : out STD_LOGIC;

    ov7670_address_out : out STD_LOGIC_vector(16 downto 0);
    ov7670_data_out : out STD_LOGIC_vector(11 downto 0);
    we_buffer : out STD_LOGIC;
    reset_global : out STD_LOGIC;
    done_capture_new_frame_out : out std_logic;

    LED_config_finished : out STD_LOGIC; -- lets us know camera registers are now written;
    LED_dll_locked : out STD_LOGIC; -- PLL is locked now;
    LED_done : out STD_LOGIC
  );
end digital_cam_impl;

architecture my_structural of digital_cam_impl4 is

COMPONENT ov7670_controller
PORT(
  clk : IN std_logic;
  resend : IN std_logic;
  siod : INOUT std_logic;
  config_finished : OUT std_logic;
  sioc : OUT std_logic;
  reset : OUT std_logic;
  pwdn : OUT std_logic;
  xclk : OUT std_logic
  );
END COMPONENT;

COMPONENT ov7670_capture
PORT(
  pclk : IN std_logic;
  vsync : IN std_logic;
  href : IN std_logic;
  d : IN std_logic_vector(7 downto 0);
  addr : OUT std_logic_vector(16 downto 0);
  dout : OUT std_logic_vector(11 downto 0);
  we : OUT std_logic;
  end_of_frame : out STD_LOGIC
  );
END COMPONENT;

COMPONENT RGB
PORT(
  Din : IN std_logic_vector(11 downto 0);
  Nblank : IN std_logic;
  R : OUT std_logic_vector(7 downto 0);
  G : OUT std_logic_vector(7 downto 0);
  B : OUT std_logic_vector(7 downto 0)
  );
END COMPONENT;

-- DE2-115 board has an Altera Cyclone V E, which has ALTPLLs;
COMPONENT my_altpll
PORT
(
  areset    : IN STD_LOGIC  := '0';
  inclk0    : IN STD_LOGIC  := '0';
  c0    : OUT STD_LOGIC ;
  c1    : OUT STD_LOGIC ;
  c2    : OUT STD_LOGIC ;
  c3    : OUT STD_LOGIC ;
  locked    : OUT STD_LOGIC
);
END COMPONENT;

COMPONENT debounce
  port(
    clk, reset: in std_logic;
    sw: in std_logic;
    db: out std_logic
  );
end COMPONENT;

-- use the Altera MegaWizard to generate the ALTPLL module; generate 3 clocks,
-- clk0 @ 100 MHz
-- clk1 @ 100 MHz with a phase adjustment of -3ns
-- clk2 @ 50 MHz and
-- clk3 @ 25 MHz
signal clk_100 : std_logic;       -- clk0: 100 MHz
signal clk_33 : std_logic;   -- clk1: 100 MHz with phase adjustment of -3ns
signal clk_50_camera : std_logic; -- clk2: 50 MHz
signal clk_25_vga : std_logic;    -- clk3: 25 MHz
signal dll_locked : std_logic;

signal done_capture_new_frame : out STD_LOGIC := '0';

--user controls;
signal resend_reg_values : std_logic;
signal sw_resend_reg_values : std_logic;

-- clocks generation;
Inst_four_clocks_pll: my_altpll PORT MAP(
  areset => '0', -- reset_general?
  inclk0 => clk_50,
  c0 => clk_100,
  c1 => clk_33, -- not needed anymore;
  c2 => clk_50_camera,
  c3 => clk_25_vga,
  locked => dll_locked -- drives an LED and SDRAM controller;
);

Inst_RGB: RGB PORT MAP(
  Din => data_to_rgb, -- comes from either rddata_buf_1 or rddata_buf_2;
  Nblank => activeArea,
  R => red,
  G => green,
  B => blue
);

-- camera module related blocks;
Inst_ov7670_controller: ov7670_controller PORT MAP(
  clk             => clk_50_camera,
  resend          => resend_reg_values, -- debounced;
  config_finished => LED_config_finished, -- LEDRed[1] notifies user;
  sioc            => ov7670_sioc,
  siod            => ov7670_siod,
  reset           => ov7670_reset,
  pwdn            => ov7670_pwdn --,
  --xclk            => ov7670_xclk
);

ov7670_xclk <= clk_33;
done_capture_new_frame_out <= done_capture_new_frame;

Inst_ov7670_capture: ov7670_capture PORT MAP(
  pclk  => ov7670_pclk,
  vsync => ov7670_vsync,
  href  => ov7670_href,
  d     => ov7670_data,
  addr  => ov7670_address_out, -- wraddress_buf_1 driven by ov7670_capture;
  dout  => ov7670_data_out, -- wrdata_buf_1 driven by ov7670_capture;
  we    => we_buffer, -- goes to mux of wren_buf_1;
  end_of_frame => done_capture_new_frame -- new out signal; did not have it before;
);

-- debouncing slide switches, to get clean signals;
Inst_debounce_resend: debounce PORT MAP(
  clk => clk_100,
  reset => reset_global,
  sw => sw_resend_reg_values,
  db => resend_reg_values
);

end my_structural;
