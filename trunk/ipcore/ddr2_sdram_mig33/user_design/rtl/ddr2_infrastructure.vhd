-- (c) Copyright 2006-2009 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and 
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: 3.3
--  \   \         Application: MIG
--  /   /         Filename: ddr2_infrastructure.vhd
-- /___/   /\     Date Last Modified: $Date: 2009/08/17 16:10:21 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR2
--Purpose:
--   Clock generation/distribution and reset synchronization
--Reference:
--Revision History:
--   Rev 1.1 - Parameter CLK_TYPE added and logic for  DIFFERENTIAL and
--             SINGLE_ENDED added. PK. 6/20/08
--   Rev 1.2 - Constant CLK_GENERATOR added and logic for clocks generation
--             using PLL or DCM added as generic code. PK. 10/14/08
--   Rev 1.3 - Added parameter NOCLK200 with default value '0'. Used for
--             controlling the instantiation of IBUFG for clk200. jul/03/09
--*****************************************************************************


library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity ddr2_infrastructure is
  generic (
    -- Following parameters are for 72-bit RDIMM design (for ML561 Reference
    -- board design). Actual values may be different. Actual parameters values
    -- are passed from design top module ddr2_sdram_mig33 module. Please refer to
    -- the ddr2_sdram_mig33 module for actual values.
    CLK_PERIOD    : integer := 3000;
    CLK_TYPE      : string  := "DIFFERENTIAL";
    DLL_FREQ_MODE : string  := "HIGH";
    NOCLK200      : boolean := false;
    RST_ACT_LOW   : integer := 1
    );
  port (
    sys_clk_p       : in std_logic;
    sys_clk_n       : in std_logic;
    sys_clk         : in std_logic;
    clk200_p        : in std_logic;
    clk200_n        : in std_logic;
    idly_clk_200    : in std_logic;
    clk0            : out std_logic;
    clk90           : out std_logic;
    clk200          : out std_logic;
    clkdiv0         : out std_logic;

    sys_rst_n       : in  std_logic;
    idelay_ctrl_rdy : in  std_logic;
    rst0            : out std_logic;
    rst90           : out std_logic;
    rst200          : out std_logic;
    rstdiv0         : out std_logic
    );
end entity ddr2_infrastructure;

architecture syn of ddr2_infrastructure is

  -- # of clock cycles to delay deassertion of reset. Needs to be a fairly
  -- high number not so much for metastability protection, but to give time
  -- for reset (i.e. stable clock cycles) to propagate through all state
  -- machines and to all control signals (i.e. not all control signals have
  -- resets, instead they rely on base state logic being reset, and the effect
  -- of that reset propagating through the logic). Need this because we may not
  -- be getting stable clock cycles while reset asserted (i.e. since reset
  -- depends on PLL/DCM lock status)
  constant RST_SYNC_NUM  : integer := 25;

  constant CLK_PERIOD_NS : real := (real(CLK_PERIOD)) / 1000.0;
  constant CLK_PERIOD_INT : integer := CLK_PERIOD/1000;

  -- By default this Parameter (CLK_GENERATOR) value is "PLL". If this
  -- Parameter is set to "PLL", PLL is used to generate the design clocks.
  -- If this Parameter is set to "DCM",
  -- DCM is used to generate the design clocks.
  constant CLK_GENERATOR : string := "PLL";

  signal clk0_bufg        : std_logic;
  signal clk0_bufg_in     : std_logic;
  signal clk90_bufg       : std_logic;
  signal clk90_bufg_in    : std_logic;
  signal clk200_bufg      : std_logic;
  signal clkdiv0_bufg     : std_logic;
  signal clkdiv0_bufg_in  : std_logic;
  signal clk200_ibufg     : std_logic;
  signal clkfbout_clkfbin : std_logic;
  signal locked           : std_logic;
  signal rst0_sync_r      : std_logic_vector(RST_SYNC_NUM-1 downto 0);
  signal rst200_sync_r    : std_logic_vector(RST_SYNC_NUM-1 downto 0);
  signal rst90_sync_r     : std_logic_vector(RST_SYNC_NUM-1 downto 0);
  signal rstdiv0_sync_r   : std_logic_vector((RST_SYNC_NUM/2)-1 downto 0);
  signal rst_tmp          : std_logic;
  signal sys_clk_ibufg    : std_logic;
  signal sys_rst          : std_logic;

  attribute max_fanout : string;
  attribute syn_maxfan : integer;
  attribute max_fanout of rst0_sync_r    : signal is "10";
  attribute syn_maxfan of rst0_sync_r    : signal is 10;
  attribute max_fanout of rst200_sync_r  : signal is "10";
  attribute syn_maxfan of rst200_sync_r  : signal is 10;
  attribute max_fanout of rst90_sync_r   : signal is "10";
  attribute syn_maxfan of rst90_sync_r   : signal is 10;
  attribute max_fanout of rstdiv0_sync_r : signal is "10";
  attribute syn_maxfan of rstdiv0_sync_r : signal is 10;

begin

  sys_rst <= not(sys_rst_n) when (RST_ACT_LOW /= 0) else sys_rst_n;

  clk0    <= clk0_bufg;
  clk90   <= clk90_bufg;
  clk200  <= clk200_bufg;
  clkdiv0 <= clkdiv0_bufg;

  DIFF_ENDED_CLKS_INST : if(CLK_TYPE = "DIFFERENTIAL") generate
  begin
    --**************************************************************************
    -- Differential input clock input buffers
    --**************************************************************************

    SYS_CLK_INST : IBUFGDS_LVPECL_25
      port map (
        I  => sys_clk_p,
        IB => sys_clk_n,
        O  => sys_clk_ibufg
        );

    IDLY_CLK_INST : IBUFGDS_LVPECL_25
      port map (
        I  => clk200_p,
        IB => clk200_n,
        O  => clk200_ibufg
        );

  end generate;

  SINGLE_ENDED_CLKS_INST : if(CLK_TYPE = "SINGLE_ENDED") generate
  begin
    --**************************************************************************
    -- Single ended input clock input buffers
    --**************************************************************************

    SYS_CLK_INST : IBUFG
      port map (
        I  => sys_clk,
        O  => sys_clk_ibufg
        );
    NOCLK200_CHECK : if ( NOCLK200 = false ) generate
    begin
        IDLY_CLK_INST : IBUFG
          port map (
            I  => idly_clk_200,
            O  => clk200_ibufg
            );
    end generate;

  end generate;

  NOCLK200_CHECK_BUFG: if ( ((NOCLK200 = false) and (CLK_TYPE = "SINGLE_ENDED")) or (CLK_TYPE = "DIFFERENTIAL") ) generate
    CLK_200_BUFG : BUFG
      port map (
        O => clk200_bufg,
        I => clk200_ibufg
        );
  end generate;

  NOCLK200_CHECK_GND: if ( (NOCLK200 = true) and (CLK_TYPE = "SINGLE_ENDED")) generate
     clk200_bufg <= '0';
  end generate;


  --***************************************************************************
  -- Global clock generation and distribution
  --***************************************************************************

  gen_pll_adv: if (CLK_GENERATOR = "PLL") generate
  begin
    u_pll_adv: PLL_ADV
      generic map (
        BANDWIDTH          => "OPTIMIZED",
        CLKIN1_PERIOD      => CLK_PERIOD_NS,
        CLKIN2_PERIOD      => 10.000,
        CLKOUT0_DIVIDE     => CLK_PERIOD_INT,
        CLKOUT1_DIVIDE     => CLK_PERIOD_INT,
        CLKOUT2_DIVIDE     => CLK_PERIOD_INT*2,
        CLKOUT3_DIVIDE     => 1,
        CLKOUT4_DIVIDE     => 1,
        CLKOUT5_DIVIDE     => 1,
        CLKOUT0_PHASE      => 0.000,
        CLKOUT1_PHASE      => 90.000,
        CLKOUT2_PHASE      => 0.000,
        CLKOUT3_PHASE      => 0.000,
        CLKOUT4_PHASE      => 0.000,
        CLKOUT5_PHASE      => 0.000,
        CLKOUT0_DUTY_CYCLE => 0.500,
        CLKOUT1_DUTY_CYCLE => 0.500,
        CLKOUT2_DUTY_CYCLE => 0.500,
        CLKOUT3_DUTY_CYCLE => 0.500,
        CLKOUT4_DUTY_CYCLE => 0.500,
        CLKOUT5_DUTY_CYCLE => 0.500,
        COMPENSATION       => "SYSTEM_SYNCHRONOUS",
        DIVCLK_DIVIDE      => 1,
        CLKFBOUT_MULT      => CLK_PERIOD_INT,
        CLKFBOUT_PHASE     => 0.0,
        REF_JITTER         => 0.005000
        )
      port map (
        CLKFBIN     => clkfbout_clkfbin,
        CLKINSEL    => '1',
        CLKIN1      => sys_clk_ibufg,
        CLKIN2      => '0',
        DADDR       => (others => '0'),
        DCLK        => '0',
        DEN         => '0',
        DI          => (others => '0'),
        DWE         => '0',
        REL         => '0',
        RST         => sys_rst,
        CLKFBDCM    => open,
        CLKFBOUT    => clkfbout_clkfbin,
        CLKOUTDCM0  => open,
        CLKOUTDCM1  => open,
        CLKOUTDCM2  => open,
        CLKOUTDCM3  => open,
        CLKOUTDCM4  => open,
        CLKOUTDCM5  => open,
        CLKOUT0     => clk0_bufg_in,
        CLKOUT1     => clk90_bufg_in,
        CLKOUT2     => clkdiv0_bufg_in,
        CLKOUT3     => open,
        CLKOUT4     => open,
        CLKOUT5     => open,
        DO          => open,
        DRDY        => open,
        LOCKED      => locked
        );
  end generate;

  gen_dcm_base: if (CLK_GENERATOR = "DCM") generate
  begin
    u_dcm_base : DCM_BASE
      generic map (
        CLKIN_PERIOD          => CLK_PERIOD_NS,
        CLKDV_DIVIDE          => 2.0,
        DLL_FREQUENCY_MODE    => DLL_FREQ_MODE,
        DUTY_CYCLE_CORRECTION => true,
        FACTORY_JF            => X"F0F0"
        )
      port map (
        CLK0                  => clk0_bufg_in,
        CLK180                => open,
        CLK270                => open,
        CLK2X                 => open,
        CLK2X180              => open,
        CLK90                 => clk90_bufg_in,
        CLKDV                 => clkdiv0_bufg_in,
        CLKFX                 => open,
        CLKFX180              => open,
        LOCKED                => locked,
        CLKFB                 => clk0_bufg,
        CLKIN                 => sys_clk_ibufg,
        RST                   => sys_rst
        );
  end generate;

  U_BUFG_CLK0 : BUFG
    port map (
      O => clk0_bufg,
      I => clk0_bufg_in
      );

  U_BUFG_CLK90 : BUFG
    port map (
      O => clk90_bufg,
      I => clk90_bufg_in
      );

  U_BUFG_CLKDIV0 : BUFG
    port map (
      O  => clkdiv0_bufg,
      I  => clkdiv0_bufg_in
    );


  --***************************************************************************
  -- Reset synchronization
  -- NOTES:
  --   1. shut down the whole operation if the PLL/DCM hasn't yet locked (and
  --      by inference, this means that external SYS_RST_IN has been asserted -
  --      PLL/DCM deasserts LOCKED as soon as SYS_RST_IN asserted)
  --   2. In the case of all resets except rst200, also assert reset if the
  --      IDELAY master controller is not yet ready
  --   3. asynchronously assert reset. This was we can assert reset even if
  --      there is no clock (needed for things like 3-stating output buffers).
  --      reset deassertion is synchronous.
  --***************************************************************************

  rst_tmp <= sys_rst or not(locked) or not(idelay_ctrl_rdy);

  process (clk0_bufg, rst_tmp)
  begin
    if (rst_tmp = '1') then
      rst0_sync_r <= (others => '1');
    elsif (rising_edge(clk0_bufg)) then
      -- logical left shift by one (pads with 0)
      rst0_sync_r <= rst0_sync_r(RST_SYNC_NUM-2 downto 0) & '0';
    end if;
  end process;

  process (clkdiv0_bufg, rst_tmp)
  begin
    if (rst_tmp = '1') then
      rstdiv0_sync_r <= (others => '1');
    elsif (rising_edge(clkdiv0_bufg)) then
      -- logical left shift by one (pads with 0)
      rstdiv0_sync_r <= rstdiv0_sync_r((RST_SYNC_NUM/2)-2 downto 0) & '0';
    end if;
  end process;

  process (clk90_bufg, rst_tmp)
  begin
    if (rst_tmp = '1') then
      rst90_sync_r <= (others => '1');
    elsif (rising_edge(clk90_bufg)) then
      rst90_sync_r <= rst90_sync_r(RST_SYNC_NUM-2 downto 0) & '0';
    end if;
  end process;

  -- make sure CLK200 doesn't depend on IDELAY_CTRL_RDY, else chicken n' egg
  process (clk200_bufg, locked)
  begin
    if ((not(locked)) = '1') then
      rst200_sync_r <= (others => '1');
    elsif (rising_edge(clk200_bufg)) then
      rst200_sync_r <= rst200_sync_r(RST_SYNC_NUM-2 downto 0) & '0';
    end if;
  end process;

  rst0    <= rst0_sync_r(RST_SYNC_NUM-1);
  rst90   <= rst90_sync_r(RST_SYNC_NUM-1);
  rst200  <= rst200_sync_r(RST_SYNC_NUM-1);
  rstdiv0 <= rstdiv0_sync_r((RST_SYNC_NUM/2)-1);

end architecture syn;


