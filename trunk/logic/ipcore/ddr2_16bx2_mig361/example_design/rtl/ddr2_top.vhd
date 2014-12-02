--*****************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2006, 2007, 2008 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: 3.6.1
--  \   \         Application: MIG
--  /   /         Filename: ddr2_top.vhd
-- /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:03 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR2
--Purpose:
--   System level module. This level contains just the memory controller.
--   This level will be intiantated when the user wants to remove the
--   synthesizable test bench, IDELAY control block and the clock
--   generation modules.
--Reference:
--Revision History:
--   Rev 1.1 - Parameter USE_DM_PORT added. PK. 6/25/08
--   Rev 1.2 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
--   Rev 1.3 - Parameter IODELAY_GRP added. PK. 11/27/08
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity ddr2_top is
  generic (
    -- Following parameters are for 72-bit RDIMM design (for ML561 Reference
    -- board design). Actual values may be different. Actual parameters values
    -- are passed from design top module ddr2_16bx2_mig361 module. Please refer to
    -- the ddr2_16bx2_mig361 module for actual values.
    BANK_WIDTH            : integer := 2;      -- # of memory bank addr bits
    CKE_WIDTH             : integer := 1;      -- # of memory clock enable outputs
    CLK_WIDTH             : integer := 1;      -- # of clock outputs
    COL_WIDTH             : integer := 10;     -- # of memory column bits
    CS_NUM                : integer := 1;      -- # of separate memory chip selects
    CS_BITS               : integer := 0;      -- set to log2(CS_NUM) (rounded up)
    CS_WIDTH              : integer := 1;      -- # of total memory chip selects
    USE_DM_PORT           : integer := 1;      -- enable Data Mask (=1 enable)
    DM_WIDTH              : integer := 9;      -- # of data mask bits
    DQ_WIDTH              : integer := 72;     -- # of data width
    DQ_BITS               : integer := 7;      -- set to log2(DQS_WIDTH*DQ_PER_DQS)
    DQ_PER_DQS            : integer := 8;      -- # of DQ data bits per strobe
    DQS_WIDTH             : integer := 9;      -- # of DQS strobes
    DQS_BITS              : integer := 4;      -- set to log2(DQS_WIDTH)
    HIGH_PERFORMANCE_MODE : boolean := TRUE;   -- IODELAY Performance Mode
    IODELAY_GRP           : string  := "IODELAY_MIG";   -- IODELAY Group Name
    ODT_WIDTH             : integer := 1;      -- # of memory on-die term enables
    ROW_WIDTH             : integer := 14;     -- # of memory row & # of addr bits
    APPDATA_WIDTH         : integer := 144;    -- # of read/write data bus bits
    ADDITIVE_LAT          : integer := 0;      -- additive write latency
    BURST_LEN             : integer := 4;      -- burst length (in double words)
    BURST_TYPE            : integer := 0;      -- burst type (=0 seq; =1 interlved)
    CAS_LAT               : integer := 5;      -- CAS latency
    ECC_ENABLE            : integer := 0;      -- enable ECC (=1 enable)
    ODT_TYPE              : integer := 1;      -- ODT (=0(none),=1(75),=2(150),=3(50))
    MULTI_BANK_EN         : integer := 1;      -- enable bank management
    TWO_T_TIME_EN         : integer := 0;       -- 2t timing for unbuffered dimms
    REDUCE_DRV            : integer := 0;      -- reduced strength mem I/O (=1 yes)
    REG_ENABLE            : integer := 1;      -- registered addr/ctrl (=1 yes)
    TREFI_NS              : integer := 7800;   -- auto refresh interval (ns)
    TRAS                  : integer := 40000;  -- active->precharge delay
    TRCD                  : integer := 15000;  -- active->read/write delay
    TRFC                  : integer := 105000;  -- ref->ref, ref->active delay
    TRP                   : integer := 15000;  -- precharge->command delay
    TRTP                  : integer := 7500;   -- read->precharge delay
    TWR                   : integer := 15000;  -- used to determine wr->prech
    TWTR                  : integer := 10000;  -- write->read delay
    CLK_PERIOD            : integer := 3000;   -- Core/Mem clk period (in ps)
    SIM_ONLY              : integer := 0;      -- = 1 to skip power up delay
    DEBUG_EN              : integer := 0;      -- Enable debug signals/controls
    FPGA_SPEED_GRADE      : integer    := 2    -- FPGA Speed Grade
    );
  port (
    clk0                   : in    std_logic;
    clk90                  : in    std_logic;
    clkdiv0                : in    std_logic;
    rst0                   : in    std_logic;
    rst90                  : in    std_logic;
    rstdiv0                : in    std_logic;
    app_af_cmd             : in    std_logic_vector(2 downto 0);
    app_af_addr            : in    std_logic_vector(30 downto 0);
    app_af_wren            : in    std_logic;
    app_wdf_wren           : in    std_logic;
    app_wdf_data           : in    std_logic_vector(APPDATA_WIDTH-1 downto 0);
    app_wdf_mask_data      : in    std_logic_vector((APPDATA_WIDTH/8)-1
                                                    downto 0);
    app_af_afull           : out   std_logic;
    app_wdf_afull          : out   std_logic;
    rd_data_valid          : out   std_logic;
    rd_data_fifo_out       : out   std_logic_vector(APPDATA_WIDTH-1 downto 0);
    rd_ecc_error           : out   std_logic_vector(1 downto 0);
    phy_init_done          : out   std_logic;
    ddr2_ck                : out   std_logic_vector(CLK_WIDTH-1 downto 0);
    ddr2_ck_n              : out   std_logic_vector(CLK_WIDTH-1 downto 0);
    ddr2_a                 : out   std_logic_vector(ROW_WIDTH-1 downto 0);
    ddr2_ba                : out   std_logic_vector(BANK_WIDTH-1 downto 0);
    ddr2_ras_n             : out   std_logic;
    ddr2_cas_n             : out   std_logic;
    ddr2_we_n              : out   std_logic;
    ddr2_cs_n              : out   std_logic_vector(CS_WIDTH-1 downto 0);
    ddr2_cke               : out   std_logic_vector(CKE_WIDTH-1 downto 0);
    ddr2_odt               : out   std_logic_vector(ODT_WIDTH-1 downto 0);
    ddr2_dm                : out   std_logic_vector(DM_WIDTH-1 downto 0);
    ddr2_dqs               : inout std_logic_vector(DQS_WIDTH-1 downto 0);
    ddr2_dqs_n             : inout std_logic_vector(DQS_WIDTH-1 downto 0);
    ddr2_dq                : inout std_logic_vector(DQ_WIDTH-1 downto 0);
    -- Debug signals (optional use)
    dbg_idel_up_all        : in    std_logic;
    dbg_idel_down_all      : in    std_logic;
    dbg_idel_up_dq         : in    std_logic;
    dbg_idel_down_dq       : in    std_logic;
    dbg_idel_up_dqs        : in    std_logic;
    dbg_idel_down_dqs      : in    std_logic;
    dbg_idel_up_gate       : in    std_logic;
    dbg_idel_down_gate     : in    std_logic;
    dbg_sel_idel_dq        : in    std_logic_vector(DQ_BITS-1 downto 0);
    dbg_sel_all_idel_dq    : in    std_logic;
    dbg_sel_idel_dqs       : in    std_logic_vector(DQS_BITS downto 0);
    dbg_sel_all_idel_dqs   : in    std_logic;
    dbg_sel_idel_gate      : in    std_logic_vector(DQS_BITS downto 0);
    dbg_sel_all_idel_gate  : in    std_logic;
    dbg_calib_done         : out   std_logic_vector(3 downto 0);
    dbg_calib_err          : out   std_logic_vector(3 downto 0);
    dbg_calib_dq_tap_cnt   : out   std_logic_vector((6*DQ_WIDTH)-1 downto 0);
    dbg_calib_dqs_tap_cnt  : out   std_logic_vector((6*DQS_WIDTH)-1 downto 0);
    dbg_calib_gate_tap_cnt : out   std_logic_vector((6*DQS_WIDTH)-1 downto 0);
    dbg_calib_rd_data_sel  : out   std_logic_vector(DQS_WIDTH-1 downto 0);
    dbg_calib_rden_dly     : out   std_logic_vector((5*DQS_WIDTH)-1 downto 0);
    dbg_calib_gate_dly     : out   std_logic_vector((5*DQS_WIDTH)-1 downto 0)
    );
end entity ddr2_top;

architecture syn of ddr2_top is

  component ddr2_mem_if_top
    generic (
      BANK_WIDTH            : integer;
      CKE_WIDTH             : integer;
      CLK_WIDTH             : integer;
      COL_WIDTH             : integer;
      CS_BITS               : integer;
      CS_NUM                : integer;
      CS_WIDTH              : integer;
      USE_DM_PORT           : integer;
      DM_WIDTH              : integer;
      DQ_WIDTH              : integer;
      DQ_BITS               : integer;
      DQ_PER_DQS            : integer;
      DQS_BITS              : integer;
      DQS_WIDTH             : integer;
      HIGH_PERFORMANCE_MODE : boolean;
      IODELAY_GRP           : string;
      ODT_WIDTH             : integer;
      ROW_WIDTH             : integer;
      APPDATA_WIDTH         : integer;
      ADDITIVE_LAT          : integer;
      BURST_LEN             : integer;
      BURST_TYPE            : integer;
      CAS_LAT               : integer;
      ECC_ENABLE            : integer;
      MULTI_BANK_EN         : integer;
      TWO_T_TIME_EN         : integer;
      ODT_TYPE              : integer;
      DDR_TYPE              : integer;
      REDUCE_DRV            : integer;
      REG_ENABLE            : integer;
      TREFI_NS              : integer;
      TRAS                  : integer;
      TRCD                  : integer;
      TRFC                  : integer;
      TRP                   : integer;
      TRTP                  : integer;
      TWR                   : integer;
      TWTR                  : integer;
      CLK_PERIOD            : integer;
      SIM_ONLY              : integer;
      DEBUG_EN              : integer;
      FPGA_SPEED_GRADE      : integer);
    port (
      clk0                   : in    std_logic;
      clk90                  : in    std_logic;
      clkdiv0                : in    std_logic;
      rst0                   : in    std_logic;
      rst90                  : in    std_logic;
      rstdiv0                : in    std_logic;
      app_af_cmd             : in    std_logic_vector(2 downto 0);
      app_af_addr            : in    std_logic_vector(30 downto 0);
      app_af_wren            : in    std_logic;
      app_wdf_wren           : in    std_logic;
      app_wdf_data           : in    std_logic_vector(APPDATA_WIDTH-1
                                                      downto 0);
      app_wdf_mask_data      : in    std_logic_vector((APPDATA_WIDTH/8)-1
                                                      downto 0);
      rd_ecc_error           : out   std_logic_vector(1 downto 0);
      app_af_afull           : out   std_logic;
      app_wdf_afull          : out   std_logic;
      rd_data_valid          : out   std_logic;
      rd_data_fifo_out       : out   std_logic_vector(APPDATA_WIDTH-1
                                                      downto 0);
      phy_init_done          : out   std_logic;
      ddr_ck                 : out   std_logic_vector(CLK_WIDTH-1 downto 0);
      ddr_ck_n               : out   std_logic_vector(CLK_WIDTH-1 downto 0);
      ddr_addr               : out   std_logic_vector(ROW_WIDTH-1 downto 0);
      ddr_ba                 : out   std_logic_vector(BANK_WIDTH-1 downto 0);
      ddr_ras_n              : out   std_logic;
      ddr_cas_n              : out   std_logic;
      ddr_we_n               : out   std_logic;
      ddr_cs_n               : out   std_logic_vector(CS_WIDTH-1 downto 0);
      ddr_cke                : out   std_logic_vector(CKE_WIDTH-1 downto 0);
      ddr_odt                : out   std_logic_vector(ODT_WIDTH-1 downto 0);
      ddr_dm                 : out   std_logic_vector(DM_WIDTH-1 downto 0);
      ddr_dqs                : inout std_logic_vector(DQS_WIDTH-1 downto 0);
      ddr_dqs_n              : inout std_logic_vector(DQS_WIDTH-1 downto 0);
      ddr_dq                 : inout std_logic_vector(DQ_WIDTH-1 downto 0);
      dbg_idel_up_all        : in    std_logic;
      dbg_idel_down_all      : in    std_logic;
      dbg_idel_up_dq         : in    std_logic;
      dbg_idel_down_dq       : in    std_logic;
      dbg_idel_up_dqs        : in    std_logic;
      dbg_idel_down_dqs      : in    std_logic;
      dbg_idel_up_gate       : in    std_logic;
      dbg_idel_down_gate     : in    std_logic;
      dbg_sel_idel_dq        : in    std_logic_vector(DQ_BITS-1 downto 0);
      dbg_sel_all_idel_dq    : in    std_logic;
      dbg_sel_idel_dqs       : in    std_logic_vector(DQS_BITS downto 0);
      dbg_sel_all_idel_dqs   : in    std_logic;
      dbg_sel_idel_gate      : in    std_logic_vector(DQS_BITS downto 0);
      dbg_sel_all_idel_gate  : in    std_logic;
      dbg_calib_done         : out   std_logic_vector(3 downto 0);
      dbg_calib_err          : out   std_logic_vector(3 downto 0);
      dbg_calib_dq_tap_cnt   : out   std_logic_vector((6*DQ_WIDTH)-1 downto 0);
      dbg_calib_dqs_tap_cnt  : out   std_logic_vector((6*DQS_WIDTH)-1
                                                      downto 0);
      dbg_calib_gate_tap_cnt : out   std_logic_vector((6*DQS_WIDTH)-1
                                                      downto 0);
      dbg_calib_rd_data_sel  : out   std_logic_vector(DQS_WIDTH-1 downto 0);
      dbg_calib_rden_dly     : out   std_logic_vector((5*DQS_WIDTH)-1
                                                      downto 0);
      dbg_calib_gate_dly     : out   std_logic_vector((5*DQS_WIDTH)-1
                                                      downto 0));
  end component;

begin

  -- memory initialization/control logic
  u_mem_if_top : ddr2_mem_if_top
    generic map (
      BANK_WIDTH            => BANK_WIDTH,
      CKE_WIDTH             => CKE_WIDTH,
      CLK_WIDTH             => CLK_WIDTH,
      COL_WIDTH             => COL_WIDTH,
      CS_BITS               => CS_BITS,
      CS_NUM                => CS_NUM,
      CS_WIDTH              => CS_WIDTH,
      USE_DM_PORT           => USE_DM_PORT,
      DM_WIDTH              => DM_WIDTH,
      DQ_WIDTH              => DQ_WIDTH,
      DQ_BITS               => DQ_BITS,
      DQ_PER_DQS            => DQ_PER_DQS,
      DQS_BITS              => DQS_BITS,
      DQS_WIDTH             => DQS_WIDTH,
      HIGH_PERFORMANCE_MODE => HIGH_PERFORMANCE_MODE,
      IODELAY_GRP           => IODELAY_GRP,
      ODT_WIDTH             => ODT_WIDTH,
      ROW_WIDTH             => ROW_WIDTH,
      APPDATA_WIDTH         => APPDATA_WIDTH,
      ADDITIVE_LAT          => ADDITIVE_LAT,
      BURST_LEN             => BURST_LEN,
      BURST_TYPE            => BURST_TYPE,
      CAS_LAT               => CAS_LAT,
      ECC_ENABLE            => ECC_ENABLE,
      MULTI_BANK_EN         => MULTI_BANK_EN,
      TWO_T_TIME_EN         => TWO_T_TIME_EN,
      ODT_TYPE              => ODT_TYPE,
      DDR_TYPE              => 1,
      REDUCE_DRV            => REDUCE_DRV,
      REG_ENABLE            => REG_ENABLE,
      TREFI_NS              => TREFI_NS,
      TRAS                  => TRAS,
      TRCD                  => TRCD,
      TRFC                  => TRFC,
      TRP                   => TRP,
      TRTP                  => TRTP,
      TWR                   => TWR,
      TWTR                  => TWTR,
      CLK_PERIOD            => CLK_PERIOD,
      SIM_ONLY              => SIM_ONLY,
      DEBUG_EN              => DEBUG_EN,
      FPGA_SPEED_GRADE      => FPGA_SPEED_GRADE
      )
    port map (
      clk0                    => clk0,
      clk90                   => clk90,
      clkdiv0                 => clkdiv0,
      rst0                    => rst0,
      rst90                   => rst90,
      rstdiv0                 => rstdiv0,
      app_af_cmd              => app_af_cmd,
      app_af_addr             => app_af_addr,
      app_af_wren             => app_af_wren,
      app_wdf_wren            => app_wdf_wren,
      app_wdf_data            => app_wdf_data,
      app_wdf_mask_data       => app_wdf_mask_data,
      app_af_afull            => app_af_afull,
      app_wdf_afull           => app_wdf_afull,
      rd_data_valid           => rd_data_valid,
      rd_data_fifo_out        => rd_data_fifo_out,
      rd_ecc_error            => rd_ecc_error,
      phy_init_done           => phy_init_done,
      ddr_ck                  => ddr2_ck,
      ddr_ck_n                => ddr2_ck_n,
      ddr_addr                => ddr2_a,
      ddr_ba                  => ddr2_ba,
      ddr_ras_n               => ddr2_ras_n,
      ddr_cas_n               => ddr2_cas_n,
      ddr_we_n                => ddr2_we_n,
      ddr_cs_n                => ddr2_cs_n,
      ddr_cke                 => ddr2_cke,
      ddr_odt                 => ddr2_odt,
      ddr_dm                  => ddr2_dm,
      ddr_dqs                 => ddr2_dqs,
      ddr_dqs_n               => ddr2_dqs_n,
      ddr_dq                  => ddr2_dq,
      dbg_idel_up_all         => dbg_idel_up_all,
      dbg_idel_down_all       => dbg_idel_down_all,
      dbg_idel_up_dq          => dbg_idel_up_dq,
      dbg_idel_down_dq        => dbg_idel_down_dq,
      dbg_idel_up_dqs         => dbg_idel_up_dqs,
      dbg_idel_down_dqs       => dbg_idel_down_dqs,
      dbg_idel_up_gate        => dbg_idel_up_gate,
      dbg_idel_down_gate      => dbg_idel_down_gate,
      dbg_sel_idel_dq         => dbg_sel_idel_dq,
      dbg_sel_all_idel_dq     => dbg_sel_all_idel_dq,
      dbg_sel_idel_dqs        => dbg_sel_idel_dqs,
      dbg_sel_all_idel_dqs    => dbg_sel_all_idel_dqs,
      dbg_sel_idel_gate       => dbg_sel_idel_gate,
      dbg_sel_all_idel_gate   => dbg_sel_all_idel_gate,
      dbg_calib_done          => dbg_calib_done,
      dbg_calib_err           => dbg_calib_err,
      dbg_calib_dq_tap_cnt    => dbg_calib_dq_tap_cnt,
      dbg_calib_dqs_tap_cnt   => dbg_calib_dqs_tap_cnt,
      dbg_calib_gate_tap_cnt  => dbg_calib_gate_tap_cnt,
      dbg_calib_rd_data_sel   => dbg_calib_rd_data_sel,
      dbg_calib_rden_dly      => dbg_calib_rden_dly,
      dbg_calib_gate_dly      => dbg_calib_gate_dly
      );

end architecture syn;



