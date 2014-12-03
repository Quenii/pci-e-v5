-------------------------------------------------------------------------------
-- Title      : clk_rst_pro
-- Project    : 
-------------------------------------------------------------------------------
-- File       : clk_rst_pro.vhd
-- Author     :   <Administrator@GUOYONGDONG>
-- Company    : 
-- Created    : 2012-05-31
-- Last update: 2014-12-03
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-05-31  1.0      Administrator   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.Vcomponents.all;

entity clk_rst_pro is
  port(
    rst_i         : in  std_logic;
    PCIE_REFCLKP  : in  std_logic;
    PCIE_REFCLKN  : in  std_logic;
    clk33m_i      : in  std_logic;      -- 33MHz
    clk_p_i       : in  std_logic;      -- 100MHz
    clk_n_i       : in  std_logic;
    sys_clk_o     : out std_logic;      -- 40MHz
    clk_200m_o    : out std_logic;      -- 200MHz
    i2c_clk_o     : out std_logic;      -- 1MHz
    pcie_refclk_o : out std_logic;
    sys_rst_o     : out std_logic
    );
end clk_rst_pro;

architecture archi of clk_rst_pro is
  component sysclk_pll
    port (
      CLKIN1_IN    : in  std_logic;
      RST_IN       : in  std_logic;
      CLKFBOUT_OUT : out std_logic;
      CLKOUT0_OUT  : out std_logic;
      CLKOUT1_OUT  : out std_logic;
      CLKOUT2_OUT  : out std_logic;
      CLKOUT3_OUT  : out std_logic;
      LOCKED_OUT   : out std_logic);
  end component;

  signal sys_clk   : std_logic;
  signal clk_200m  : std_logic;
  signal i2c_clk   : std_logic;
  signal sys_rst   : std_logic;
  signal pllclk_in : std_logic;
  signal c0        : std_logic;
  signal c3        : std_logic;
  signal locked    : std_logic;
  signal lock_rst  : std_logic;

  constant rst_cnt_max : integer := 40000*5;  -- 40000/40MHz = 1ms
  signal   rst_cnt     : integer range rst_cnt_max downto 0;

  constant i2c_cnt_max : integer := 1;
  signal   i2c_cnt     : integer range 0 to i2c_cnt_max;

  
begin  -- archi

  
  sys_clk_o  <= sys_clk;
  clk_200m_o <= clk_200m;
  i2c_clk_o  <= i2c_clk;
  sys_rst_o  <= sys_rst;
  sys_rst    <= rst_i;                  -- or lock_rst;

  pcie_refclk_ibuf : IBUFDS
    port map (
      o  => pcie_refclk_o,
      i  => PCIE_REFCLKP,
      ib => PCIE_REFCLKN
      );

  IBUFGDS_inst : IBUFGDS
    generic map (
      DIFF_TERM  => true,
      IOSTANDARD => "DEFAULT")
    port map (
      I  => clk_p_i,
      IB => clk_n_i,
      O  => pllclk_in
      );

  
  sysclk_pll_inst : sysclk_pll
    port map (
      CLKIN1_IN    => pllclk_in,
      RST_IN       => '0',
      CLKFBOUT_OUT => open,
      CLKOUT0_OUT  => c0,               -- 100MHz
      CLKOUT1_OUT  => sys_clk,          -- 40MHz
      CLKOUT2_OUT  => clk_200m,         -- 200MHz
      CLKOUT3_OUT  => c3,               -- 4MHz
      LOCKED_OUT   => locked
      );


  process (sys_clk, locked)
  begin  -- process
    if locked = '0' then                -- asynchronous reset (active low)
      rst_cnt  <= 0;
      lock_rst <= '1';
    elsif sys_clk'event and sys_clk = '1' then  -- rising clock edge
      if rst_cnt /= rst_cnt_max then
        rst_cnt  <= rst_cnt + 1;
        lock_rst <= lock_rst;
      else
        rst_cnt  <= rst_cnt;
        lock_rst <= '0';
      end if;
    end if;
  end process;


  process (c3, sys_rst)
  begin  -- process
    if sys_rst = '1' then               -- asynchronous reset (active low)
      i2c_cnt <= 0;
      i2c_clk <= '0';
    elsif c3'event and c3 = '1' then    -- rising clock edge
      if i2c_cnt = i2c_cnt_max then
        i2c_cnt <= 0;
        i2c_clk <= not i2c_clk;
      else
        i2c_cnt <= i2c_cnt + 1;
        i2c_clk <= i2c_clk;
      end if;
    end if;
  end process;


end archi;
