--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.7
--  \   \         Application : xaw2vhdl
--  /   /         Filename : sysclk_pll.vhd
-- /___/   /\     Timestamp : 11/20/2014 23:21:00
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: xaw2vhdl-st E:/Projects/cgs-pcie/v2/gkhy/GH5007_video_sample/src/clk_rst/sysclk_pll.xaw E:/Projects/cgs-pcie/v2/gkhy/GH5007_video_sample/src/clk_rst/sysclk_pll
--Design Name: sysclk_pll
--Device: xc5vlx50t-1ff1136
--
-- Module sysclk_pll
-- Generated by Xilinx Architecture Wizard
-- Written for synthesis tool: XST
-- For block PLL_ADV_INST, Estimated PLL Jitter for CLKOUT0 = 0.149 ns
-- For block PLL_ADV_INST, Estimated PLL Jitter for CLKOUT1 = 0.178 ns
-- For block PLL_ADV_INST, Estimated PLL Jitter for CLKOUT2 = 0.130 ns
-- For block PLL_ADV_INST, Estimated PLL Jitter for CLKOUT3 = 0.280 ns

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity sysclk_pll is
   port ( CLKIN1_IN    : in    std_logic; 
          RST_IN       : in    std_logic; 
          CLKFBOUT_OUT : out   std_logic; 
          CLKOUT0_OUT  : out   std_logic; 
          CLKOUT1_OUT  : out   std_logic; 
          CLKOUT2_OUT  : out   std_logic; 
          CLKOUT3_OUT  : out   std_logic; 
          LOCKED_OUT   : out   std_logic);
end sysclk_pll;

architecture BEHAVIORAL of sysclk_pll is
   signal CLKFBIN_IN   : std_logic;
   signal CLKFBOUT_BUF : std_logic;
   signal CLKOUT0_BUF  : std_logic;
   signal CLKOUT1_BUF  : std_logic;
   signal CLKOUT2_BUF  : std_logic;
   signal CLKOUT3_BUF  : std_logic;
   signal GND_BIT      : std_logic;
   signal GND_BUS_5    : std_logic_vector (4 downto 0);
   signal GND_BUS_16   : std_logic_vector (15 downto 0);
   signal VCC_BIT      : std_logic;
begin
   GND_BIT <= '0';
   GND_BUS_5(4 downto 0) <= "00000";
   GND_BUS_16(15 downto 0) <= "0000000000000000";
   VCC_BIT <= '1';
   CLKFBOUT_OUT <= CLKFBIN_IN;
   CLKFBOUT_BUFG_INST : BUFG
      port map (I=>CLKFBOUT_BUF,
                O=>CLKFBIN_IN);
   
   CLKOUT0_BUFG_INST : BUFG
      port map (I=>CLKOUT0_BUF,
                O=>CLKOUT0_OUT);
   
   CLKOUT1_BUFG_INST : BUFG
      port map (I=>CLKOUT1_BUF,
                O=>CLKOUT1_OUT);
   
   CLKOUT2_BUFG_INST : BUFG
      port map (I=>CLKOUT2_BUF,
                O=>CLKOUT2_OUT);
   
   CLKOUT3_BUFG_INST : BUFG
      port map (I=>CLKOUT3_BUF,
                O=>CLKOUT3_OUT);
   
   PLL_ADV_INST : PLL_ADV
   generic map( BANDWIDTH => "OPTIMIZED",
            CLKIN1_PERIOD => 10.000,
            CLKIN2_PERIOD => 10.000,
            CLKOUT0_DIVIDE => 4,
            CLKOUT1_DIVIDE => 10,
            CLKOUT2_DIVIDE => 2,
            CLKOUT3_DIVIDE => 100,
            CLKOUT0_PHASE => 0.000,
            CLKOUT1_PHASE => 0.000,
            CLKOUT2_PHASE => 0.000,
            CLKOUT3_PHASE => 0.000,
            CLKOUT0_DUTY_CYCLE => 0.500,
            CLKOUT1_DUTY_CYCLE => 0.500,
            CLKOUT2_DUTY_CYCLE => 0.500,
            CLKOUT3_DUTY_CYCLE => 0.500,
            COMPENSATION => "SYSTEM_SYNCHRONOUS",
            DIVCLK_DIVIDE => 1,
            CLKFBOUT_MULT => 4,
            CLKFBOUT_PHASE => 0.0,
            REF_JITTER => 0.000000)
      port map (CLKFBIN=>CLKFBIN_IN,
                CLKINSEL=>VCC_BIT,
                CLKIN1=>CLKIN1_IN,
                CLKIN2=>GND_BIT,
                DADDR(4 downto 0)=>GND_BUS_5(4 downto 0),
                DCLK=>GND_BIT,
                DEN=>GND_BIT,
                DI(15 downto 0)=>GND_BUS_16(15 downto 0),
                DWE=>GND_BIT,
                REL=>GND_BIT,
                RST=>RST_IN,
                CLKFBDCM=>open,
                CLKFBOUT=>CLKFBOUT_BUF,
                CLKOUTDCM0=>open,
                CLKOUTDCM1=>open,
                CLKOUTDCM2=>open,
                CLKOUTDCM3=>open,
                CLKOUTDCM4=>open,
                CLKOUTDCM5=>open,
                CLKOUT0=>CLKOUT0_BUF,
                CLKOUT1=>CLKOUT1_BUF,
                CLKOUT2=>CLKOUT2_BUF,
                CLKOUT3=>CLKOUT3_BUF,
                CLKOUT4=>open,
                CLKOUT5=>open,
                DO=>open,
                DRDY=>open,
                LOCKED=>LOCKED_OUT);
   
end BEHAVIORAL;

