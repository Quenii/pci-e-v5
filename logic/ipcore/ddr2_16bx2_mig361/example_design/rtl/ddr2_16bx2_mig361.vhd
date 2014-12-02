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
--  /   /         Filename: ddr2_16bx2_mig361.vhd
-- /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:03 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR2
--Purpose:
--   Top-level  module. Simple model for what the user might use
--   typically, the user will only instantiate MEM_INTERFACE_TOP in their
--   code, and generate all the other infrastructure logic separately. 
--   This module serves both as an example, and allows the user
--   to synthesize a self-contained design, which they can use to test their
--   hardware.
--   In addition to the memory controller, the module instantiates:
--     1. Reset logic based on user clocks
--     2. IDELAY control block
--     3. Synthesizable testbench - used to model user's backend logic
--Reference:
--Revision History:
--   Rev 1.1 - Parameter USE_DM_PORT added. PK. 6/25/08
--   Rev 1.2 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
--   Rev 1.3 - Parameter IODELAY_GRP added. PK. 11/27/08
--*****************************************************************************

library ieee;

use ieee.std_logic_1164.all;

use work.ddr2_chipscope.all;

entity ddr2_16bx2_mig361 is
  generic(
   C0_DDR2_BANK_WIDTH       : integer := 3; 
                              -- # of memory bank addr bits.
   C0_DDR2_CKE_WIDTH        : integer := 1; 
                              -- # of memory clock enable outputs.
   C0_DDR2_CLK_WIDTH        : integer := 1; 
                              -- # of clock outputs.
   C0_DDR2_COL_WIDTH        : integer := 10; 
                              -- # of memory column bits.
   C0_DDR2_CS_NUM           : integer := 1; 
                              -- # of separate memory chip selects.
   C0_DDR2_CS_WIDTH         : integer := 1; 
                              -- # of total memory chip selects.
   C0_DDR2_CS_BITS          : integer := 0; 
                              -- set to log2(CS_NUM) (rounded up).
   C0_DDR2_DM_WIDTH         : integer := 2; 
                              -- # of data mask bits.
   C0_DDR2_DQ_WIDTH         : integer := 16; 
                              -- # of data width.
   C0_DDR2_DQ_PER_DQS       : integer := 8; 
                              -- # of DQ data bits per strobe.
   C0_DDR2_DQS_WIDTH        : integer := 2; 
                              -- # of DQS strobes.
   C0_DDR2_DQ_BITS          : integer := 4; 
                              -- set to log2(DQS_WIDTH*DQ_PER_DQS).
   C0_DDR2_DQS_BITS         : integer := 1; 
                              -- set to log2(DQS_WIDTH).
   C0_DDR2_ODT_WIDTH        : integer := 1; 
                              -- # of memory on-die term enables.
   C0_DDR2_ROW_WIDTH        : integer := 14; 
                              -- # of memory row and # of addr bits.
   C0_DDR2_ADDITIVE_LAT     : integer := 0; 
                              -- additive write latency.
   C0_DDR2_BURST_LEN        : integer := 4; 
                              -- burst length (in double words).
   C0_DDR2_BURST_TYPE       : integer := 0; 
                              -- burst type (=0 seq; =1 interleaved).
   C0_DDR2_CAS_LAT          : integer := 3; 
                              -- CAS latency.
   C0_DDR2_ECC_ENABLE       : integer := 0; 
                              -- enable ECC (=1 enable).
   C0_DDR2_APPDATA_WIDTH    : integer := 32; 
                              -- # of usr read/write data bus bits.
   C0_DDR2_MULTI_BANK_EN    : integer := 1; 
                              -- Keeps multiple banks open. (= 1 enable).
   C0_DDR2_TWO_T_TIME_EN    : integer := 0; 
                              -- 2t timing for unbuffered dimms.
   C0_DDR2_ODT_TYPE         : integer := 1; 
                              -- ODT (=0(none),=1(75),=2(150),=3(50)).
   C0_DDR2_REDUCE_DRV       : integer := 0; 
                              -- reduced strength mem I/O (=1 yes).
   C0_DDR2_REG_ENABLE       : integer := 0; 
                              -- registered addr/ctrl (=1 yes).
   C0_DDR2_TREFI_NS         : integer := 7800; 
                              -- auto refresh interval (ns).
   C0_DDR2_TRAS             : integer := 40000; 
                              -- active->precharge delay.
   C0_DDR2_TRCD             : integer := 15000; 
                              -- active->read/write delay.
   C0_DDR2_TRFC             : integer := 197500; 
                              -- refresh->refresh, refresh->active delay.
   C0_DDR2_TRP              : integer := 15000; 
                              -- precharge->command delay.
   C0_DDR2_TRTP             : integer := 7500; 
                              -- read->precharge delay.
   C0_DDR2_TWR              : integer := 15000; 
                              -- used to determine write->precharge.
   C0_DDR2_TWTR             : integer := 7500; 
                              -- write->read delay.
   C0_DDR2_HIGH_PERFORMANCE_MODE  : boolean := TRUE; 
                              -- # = TRUE, the IODELAY performance mode is set
                              -- to high.
                              -- # = FALSE, the IODELAY performance mode is set
                              -- to low.
   C0_DDR2_SIM_ONLY         : integer := 0; 
                              -- = 1 to skip SDRAM power up delay.
   C0_DDR2_DEBUG_EN         : integer := 1; 
                              -- Enable debug signals/controls.
                              -- When this parameter is changed from 0 to 1,
                              -- make sure to uncomment the coregen commands
                              -- in ise_flow.bat or create_ise.bat files in
                              -- par folder.
   F0_DDR2_CLK_PERIOD       : integer := 5000; 
                              -- Core/Memory clock period (in ps).
   F0_DDR2_DLL_FREQ_MODE    : string := "HIGH"; 
                              -- DCM Frequency range.
   CLK_TYPE                 : string := "SINGLE_ENDED"; 
                              -- # = "DIFFERENTIAL " ->; Differential input clocks ,
                              -- # = "SINGLE_ENDED" -> Single ended input clocks.
   F0_DDR2_NOCLK200         : boolean := FALSE; 
                              -- clk200 enable and disable
   RST_ACT_LOW              : integer := 1; 
                              -- =1 for active low reset, =0 for active high.
   C1_DDR2_BANK_WIDTH       : integer := 3; 
                              -- # of memory bank addr bits.
   C1_DDR2_CKE_WIDTH        : integer := 1; 
                              -- # of memory clock enable outputs.
   C1_DDR2_CLK_WIDTH        : integer := 1; 
                              -- # of clock outputs.
   C1_DDR2_COL_WIDTH        : integer := 10; 
                              -- # of memory column bits.
   C1_DDR2_CS_NUM           : integer := 1; 
                              -- # of separate memory chip selects.
   C1_DDR2_CS_WIDTH         : integer := 1; 
                              -- # of total memory chip selects.
   C1_DDR2_CS_BITS          : integer := 0; 
                              -- set to log2(CS_NUM) (rounded up).
   C1_DDR2_DM_WIDTH         : integer := 2; 
                              -- # of data mask bits.
   C1_DDR2_DQ_WIDTH         : integer := 16; 
                              -- # of data width.
   C1_DDR2_DQ_PER_DQS       : integer := 8; 
                              -- # of DQ data bits per strobe.
   C1_DDR2_DQS_WIDTH        : integer := 2; 
                              -- # of DQS strobes.
   C1_DDR2_DQ_BITS          : integer := 4; 
                              -- set to log2(DQS_WIDTH*DQ_PER_DQS).
   C1_DDR2_DQS_BITS         : integer := 1; 
                              -- set to log2(DQS_WIDTH).
   C1_DDR2_ODT_WIDTH        : integer := 1; 
                              -- # of memory on-die term enables.
   C1_DDR2_ROW_WIDTH        : integer := 14; 
                              -- # of memory row and # of addr bits.
   C1_DDR2_ADDITIVE_LAT     : integer := 0; 
                              -- additive write latency.
   C1_DDR2_BURST_LEN        : integer := 4; 
                              -- burst length (in double words).
   C1_DDR2_BURST_TYPE       : integer := 0; 
                              -- burst type (=0 seq; =1 interleaved).
   C1_DDR2_CAS_LAT          : integer := 3; 
                              -- CAS latency.
   C1_DDR2_ECC_ENABLE       : integer := 0; 
                              -- enable ECC (=1 enable).
   C1_DDR2_APPDATA_WIDTH    : integer := 32; 
                              -- # of usr read/write data bus bits.
   C1_DDR2_MULTI_BANK_EN    : integer := 1; 
                              -- Keeps multiple banks open. (= 1 enable).
   C1_DDR2_TWO_T_TIME_EN    : integer := 0; 
                              -- 2t timing for unbuffered dimms.
   C1_DDR2_ODT_TYPE         : integer := 1; 
                              -- ODT (=0(none),=1(75),=2(150),=3(50)).
   C1_DDR2_REDUCE_DRV       : integer := 0; 
                              -- reduced strength mem I/O (=1 yes).
   C1_DDR2_REG_ENABLE       : integer := 0; 
                              -- registered addr/ctrl (=1 yes).
   C1_DDR2_TREFI_NS         : integer := 7800; 
                              -- auto refresh interval (ns).
   C1_DDR2_TRAS             : integer := 40000; 
                              -- active->precharge delay.
   C1_DDR2_TRCD             : integer := 15000; 
                              -- active->read/write delay.
   C1_DDR2_TRFC             : integer := 197500; 
                              -- refresh->refresh, refresh->active delay.
   C1_DDR2_TRP              : integer := 15000; 
                              -- precharge->command delay.
   C1_DDR2_TRTP             : integer := 7500; 
                              -- read->precharge delay.
   C1_DDR2_TWR              : integer := 15000; 
                              -- used to determine write->precharge.
   C1_DDR2_TWTR             : integer := 7500; 
                              -- write->read delay.
   C1_DDR2_HIGH_PERFORMANCE_MODE  : boolean := TRUE; 
                              -- # = TRUE, the IODELAY performance mode is set
                              -- to high.
                              -- # = FALSE, the IODELAY performance mode is set
                              -- to low.
   C1_DDR2_SIM_ONLY         : integer := 0; 
                              -- = 1 to skip SDRAM power up delay.
   C1_DDR2_DEBUG_EN         : integer := 0  
                              -- Enable debug signals/controls.
                              -- When this parameter is changed from 0 to 1,
                              -- make sure to uncomment the coregen commands
                              -- in ise_flow.bat or create_ise.bat files in
                              -- par folder.
   );
  port(
   c0_ddr2_dq            : inout  std_logic_vector((C0_DDR2_DQ_WIDTH-1) downto 0);
   c0_ddr2_a             : out   std_logic_vector((C0_DDR2_ROW_WIDTH-1) downto 0);
   c0_ddr2_ba            : out   std_logic_vector((C0_DDR2_BANK_WIDTH-1) downto 0);
   c0_ddr2_ras_n         : out   std_logic;
   c0_ddr2_cas_n         : out   std_logic;
   c0_ddr2_we_n          : out   std_logic;
   c0_ddr2_cs_n          : out   std_logic_vector((C0_DDR2_CS_WIDTH-1) downto 0);
   c0_ddr2_odt           : out   std_logic_vector((C0_DDR2_ODT_WIDTH-1) downto 0);
   c0_ddr2_cke           : out   std_logic_vector((C0_DDR2_CKE_WIDTH-1) downto 0);
   c0_ddr2_dm            : out   std_logic_vector((C0_DDR2_DM_WIDTH-1) downto 0);
   ddr2_sys_clk_f0       : in    std_logic;
   idly_clk_200          : in    std_logic;
   sys_rst_n             : in    std_logic;
   c0_phy_init_done      : out   std_logic;
   c0_error              : out   std_logic;
   c0_ddr2_dqs           : inout  std_logic_vector((C0_DDR2_DQS_WIDTH-1) downto 0);
   c0_ddr2_dqs_n         : inout  std_logic_vector((C0_DDR2_DQS_WIDTH-1) downto 0);
   c0_ddr2_ck            : out   std_logic_vector((C0_DDR2_CLK_WIDTH-1) downto 0);
   c0_ddr2_ck_n          : out   std_logic_vector((C0_DDR2_CLK_WIDTH-1) downto 0);
   c1_ddr2_dq            : inout  std_logic_vector((C1_DDR2_DQ_WIDTH-1) downto 0);
   c1_ddr2_a             : out   std_logic_vector((C1_DDR2_ROW_WIDTH-1) downto 0);
   c1_ddr2_ba            : out   std_logic_vector((C1_DDR2_BANK_WIDTH-1) downto 0);
   c1_ddr2_ras_n         : out   std_logic;
   c1_ddr2_cas_n         : out   std_logic;
   c1_ddr2_we_n          : out   std_logic;
   c1_ddr2_cs_n          : out   std_logic_vector((C1_DDR2_CS_WIDTH-1) downto 0);
   c1_ddr2_odt           : out   std_logic_vector((C1_DDR2_ODT_WIDTH-1) downto 0);
   c1_ddr2_cke           : out   std_logic_vector((C1_DDR2_CKE_WIDTH-1) downto 0);
   c1_ddr2_dm            : out   std_logic_vector((C1_DDR2_DM_WIDTH-1) downto 0);
   c1_phy_init_done      : out   std_logic;
   c1_error              : out   std_logic;
   c1_ddr2_dqs           : inout  std_logic_vector((C1_DDR2_DQS_WIDTH-1) downto 0);
   c1_ddr2_dqs_n         : inout  std_logic_vector((C1_DDR2_DQS_WIDTH-1) downto 0);
   c1_ddr2_ck            : out   std_logic_vector((C1_DDR2_CLK_WIDTH-1) downto 0);
   c1_ddr2_ck_n          : out   std_logic_vector((C1_DDR2_CLK_WIDTH-1) downto 0)
   );

end entity ddr2_16bx2_mig361;

architecture arc_mem_interface_top of ddr2_16bx2_mig361 is

  --***************************************************************************
  -- IODELAY Group Name: Replication and placement of IDELAYCTRLs will be
  -- handled automatically by software tools if IDELAYCTRLs have same refclk,
  -- reset and rdy nets. Designs with a unique RESET will commonly create a
  -- unique RDY. Constraint IODELAY_GROUP is associated to a set of IODELAYs
  -- with an IDELAYCTRL. The parameter IODELAY_GRP value can be any string.
  --***************************************************************************
  constant IODELAY_GRP : string := "IODELAY_MIG";

  constant c1_dq_zeros : std_logic_vector((C1_DDR2_DQ_BITS-1) downto 0) := (others => '0');
  constant c1_dqs_zeros : std_logic_vector(C1_DDR2_DQS_BITS downto 0) := (others => '0');

  component ddr2_idelay_ctrl
    generic (
      IODELAY_GRP       : string
      );
    port (
      rst200               : in    std_logic;
      clk200               : in    std_logic;
      idelay_ctrl_rdy      : out   std_logic
      );
  end component;

component ddr2_infrastructure
    generic (
      CLK_PERIOD    : integer;
      DLL_FREQ_MODE   : string;
      CLK_TYPE              : string;
      NOCLK200      : boolean;
      RST_ACT_LOW           : integer

      );
    port (
      sys_clk_p            : in    std_logic;
      sys_clk_n            : in    std_logic;
      sys_clk              : in    std_logic;
      clk200_p             : in    std_logic;
      clk200_n             : in    std_logic;
      idly_clk_200         : in    std_logic;
      sys_rst_n            : in    std_logic;
      rst0                 : out   std_logic;
      rst90                : out   std_logic;
      rstdiv0              : out   std_logic;
      rst200               : out   std_logic;
      clk0                 : out   std_logic;
      clk90                : out   std_logic;
      clkdiv0              : out   std_logic;
      clk200               : out   std_logic;
      idelay_ctrl_rdy      : in    std_logic

      );
  end component;


component ddr2_top
    generic (
      BANK_WIDTH    : integer;
      CKE_WIDTH     : integer;
      CLK_WIDTH     : integer;
      COL_WIDTH     : integer;
      CS_NUM        : integer;
      CS_WIDTH      : integer;
      CS_BITS       : integer;
      DM_WIDTH      : integer;
      DQ_WIDTH      : integer;
      DQ_PER_DQS    : integer;
      DQS_WIDTH     : integer;
      DQ_BITS       : integer;
      DQS_BITS      : integer;
      ODT_WIDTH     : integer;
      ROW_WIDTH     : integer;
      ADDITIVE_LAT   : integer;
      BURST_LEN     : integer;
      BURST_TYPE    : integer;
      CAS_LAT       : integer;
      ECC_ENABLE    : integer;
      APPDATA_WIDTH   : integer;
      MULTI_BANK_EN   : integer;
      TWO_T_TIME_EN   : integer;
      ODT_TYPE      : integer;
      REDUCE_DRV    : integer;
      REG_ENABLE    : integer;
      TREFI_NS      : integer;
      TRAS          : integer;
      TRCD          : integer;
      TRFC          : integer;
      TRP           : integer;
      TRTP          : integer;
      TWR           : integer;
      TWTR          : integer;
      HIGH_PERFORMANCE_MODE   : boolean;
      IODELAY_GRP           : string;
      SIM_ONLY      : integer;
      DEBUG_EN      : integer;
      FPGA_SPEED_GRADE   : integer;
      USE_DM_PORT   : integer;
      CLK_PERIOD    : integer
      );
    port (
      ddr2_dq              : inout  std_logic_vector((DQ_WIDTH-1) downto 0);
      ddr2_a               : out   std_logic_vector((ROW_WIDTH-1) downto 0);
      ddr2_ba              : out   std_logic_vector((BANK_WIDTH-1) downto 0);
      ddr2_ras_n           : out   std_logic;
      ddr2_cas_n           : out   std_logic;
      ddr2_we_n            : out   std_logic;
      ddr2_cs_n            : out   std_logic_vector((CS_WIDTH-1) downto 0);
      ddr2_odt             : out   std_logic_vector((ODT_WIDTH-1) downto 0);
      ddr2_cke             : out   std_logic_vector((CKE_WIDTH-1) downto 0);
      ddr2_dm              : out   std_logic_vector((DM_WIDTH-1) downto 0);
      phy_init_done        : out   std_logic;
      rst0                 : in    std_logic;
      rst90                : in    std_logic;
      rstdiv0              : in    std_logic;
      clk0                 : in    std_logic;
      clk90                : in    std_logic;
      clkdiv0              : in    std_logic;
      app_wdf_afull        : out   std_logic;
      app_af_afull         : out   std_logic;
      rd_data_valid        : out   std_logic;
      app_wdf_wren         : in    std_logic;
      app_af_wren          : in    std_logic;
      app_af_addr          : in    std_logic_vector(30 downto 0);
      app_af_cmd           : in    std_logic_vector(2 downto 0);
      rd_data_fifo_out     : out   std_logic_vector((APPDATA_WIDTH-1) downto 0);
      app_wdf_data         : in    std_logic_vector((APPDATA_WIDTH-1) downto 0);
      app_wdf_mask_data    : in    std_logic_vector((APPDATA_WIDTH/8-1) downto 0);
      ddr2_dqs             : inout  std_logic_vector((DQS_WIDTH-1) downto 0);
      ddr2_dqs_n           : inout  std_logic_vector((DQS_WIDTH-1) downto 0);
      ddr2_ck              : out   std_logic_vector((CLK_WIDTH-1) downto 0);
      rd_ecc_error         : out   std_logic_vector(1 downto 0);
      ddr2_ck_n            : out   std_logic_vector((CLK_WIDTH-1) downto 0);
      dbg_calib_done          : out  std_logic_vector(3 downto 0);
      dbg_calib_err           : out  std_logic_vector(3 downto 0);
      dbg_calib_dq_tap_cnt    : out  std_logic_vector(((6*DQ_WIDTH)-1) downto 0);
      dbg_calib_dqs_tap_cnt   : out  std_logic_vector(((6*DQS_WIDTH)-1) downto 0);
      dbg_calib_gate_tap_cnt   : out  std_logic_vector(((6*DQS_WIDTH)-1) downto 0);
      dbg_calib_rd_data_sel   : out  std_logic_vector((DQS_WIDTH-1) downto 0);
      dbg_calib_rden_dly      : out  std_logic_vector(((5*DQS_WIDTH)-1) downto 0);
      dbg_calib_gate_dly      : out  std_logic_vector(((5*DQS_WIDTH)-1) downto 0);
      dbg_idel_up_all         : in  std_logic;
      dbg_idel_down_all       : in  std_logic;
      dbg_idel_up_dq          : in  std_logic;
      dbg_idel_down_dq        : in  std_logic;
      dbg_idel_up_dqs         : in  std_logic;
      dbg_idel_down_dqs       : in  std_logic;
      dbg_idel_up_gate        : in  std_logic;
      dbg_idel_down_gate      : in  std_logic;
      dbg_sel_idel_dq         : in  std_logic_vector((DQ_BITS-1) downto 0);
      dbg_sel_all_idel_dq     : in  std_logic;
      dbg_sel_idel_dqs        : in  std_logic_vector(DQS_BITS downto 0);
      dbg_sel_all_idel_dqs    : in  std_logic;
      dbg_sel_idel_gate       : in  std_logic_vector(DQS_BITS downto 0);
      dbg_sel_all_idel_gate   : in  std_logic

      );
  end component;


component  ddr2_tb_top
    generic (
      BANK_WIDTH    : integer;
      COL_WIDTH     : integer;
      DM_WIDTH      : integer;
      DQ_WIDTH      : integer;
      ROW_WIDTH     : integer;
      BURST_LEN     : integer;
      ECC_ENABLE    : integer;
      APPDATA_WIDTH   : integer
      );
    port (
      phy_init_done        : in    std_logic;
      error                : out   std_logic;
      error_cmp            : out   std_logic;
      rst0                 : in    std_logic;
      clk0                 : in    std_logic;
      app_wdf_afull        : in    std_logic;
      app_af_afull         : in    std_logic;
      rd_data_valid        : in    std_logic;
      app_wdf_wren         : out   std_logic;
      app_af_wren          : out   std_logic;
      app_af_addr          : out   std_logic_vector(30 downto 0);
      app_af_cmd           : out   std_logic_vector(2 downto 0);
      rd_data_fifo_out     : in    std_logic_vector((APPDATA_WIDTH-1) downto 0);
      app_wdf_data         : out   std_logic_vector((APPDATA_WIDTH-1) downto 0);
      app_wdf_mask_data    : out   std_logic_vector((APPDATA_WIDTH/8-1) downto 0)
      );
  end component;


  signal  ddr2_sys_clk_f0_p      : std_logic;
  signal  ddr2_sys_clk_f0_n      : std_logic;
  signal  clk200_p               : std_logic;
  signal  clk200_n               : std_logic;
  signal  c0_error_cmp           : std_logic;
  signal  f0_rst0                : std_logic;
  signal  f0_rst90               : std_logic;
  signal  f0_rstdiv0             : std_logic;
  signal  rst200                 : std_logic;
  signal  f0_ddr2_clk0           : std_logic;
  signal  f0_ddr2_clk90          : std_logic;
  signal  f0_ddr2_clkdiv0        : std_logic;
  signal  clk200                 : std_logic;
  signal  idelay_ctrl_rdy        : std_logic;
  signal  c0_app_wdf_afull       : std_logic;
  signal  c0_app_af_afull        : std_logic;
  signal  c0_rd_data_valid       : std_logic;
  signal  c0_app_wdf_wren        : std_logic;
  signal  c0_app_af_wren         : std_logic;
  signal  c0_app_af_addr         : std_logic_vector(30 downto 0);
  signal  c0_app_af_cmd          : std_logic_vector(2 downto 0);
  signal  c0_rd_data_fifo_out    : std_logic_vector((C0_DDR2_APPDATA_WIDTH)-1 downto 0);
  signal  c0_app_wdf_data        : std_logic_vector((C0_DDR2_APPDATA_WIDTH)-1 downto 0);
  signal  c0_app_wdf_mask_data   : std_logic_vector((C0_DDR2_APPDATA_WIDTH/8)-1 downto 0);
  signal  c0_i_phy_init_done      : std_logic;


  --Debug signals


  signal  c0_dbg_calib_done             : std_logic_vector(3 downto 0);
  signal  c0_dbg_calib_err              : std_logic_vector(3 downto 0);
  signal  c0_dbg_calib_dq_tap_cnt       : std_logic_vector(((6*C0_DDR2_DQ_WIDTH)-1) downto 0);
  signal  c0_dbg_calib_dqs_tap_cnt      : std_logic_vector(((6*C0_DDR2_DQS_WIDTH)-1) downto 0);
  signal  c0_dbg_calib_gate_tap_cnt     : std_logic_vector(((6*C0_DDR2_DQS_WIDTH)-1) downto 0);
  signal  c0_dbg_calib_rd_data_sel      : std_logic_vector((C0_DDR2_DQS_WIDTH-1) downto 0);
  signal  c0_dbg_calib_rden_dly         : std_logic_vector(((5*C0_DDR2_DQS_WIDTH)-1) downto 0);
  signal  c0_dbg_calib_gate_dly         : std_logic_vector(((5*C0_DDR2_DQS_WIDTH)-1) downto 0);
  signal  c0_dbg_idel_up_all            : std_logic;
  signal  c0_dbg_idel_down_all          : std_logic;
  signal  c0_dbg_idel_up_dq             : std_logic;
  signal  c0_dbg_idel_down_dq           : std_logic;
  signal  c0_dbg_idel_up_dqs            : std_logic;
  signal  c0_dbg_idel_down_dqs          : std_logic;
  signal  c0_dbg_idel_up_gate           : std_logic;
  signal  c0_dbg_idel_down_gate         : std_logic;
  signal  c0_dbg_sel_idel_dq            : std_logic_vector((C0_DDR2_DQ_BITS-1) downto 0);
  signal  c0_dbg_sel_all_idel_dq        : std_logic;
  signal  c0_dbg_sel_idel_dqs           : std_logic_vector(C0_DDR2_DQS_BITS downto 0);
  signal  c0_dbg_sel_all_idel_dqs       : std_logic;
  signal  c0_dbg_sel_idel_gate          : std_logic_vector(C0_DDR2_DQS_BITS downto 0);
  signal  c0_dbg_sel_all_idel_gate      : std_logic;

  signal  c1_error_cmp           : std_logic;
  signal  c1_app_wdf_afull       : std_logic;
  signal  c1_app_af_afull        : std_logic;
  signal  c1_rd_data_valid       : std_logic;
  signal  c1_app_wdf_wren        : std_logic;
  signal  c1_app_af_wren         : std_logic;
  signal  c1_app_af_addr         : std_logic_vector(30 downto 0);
  signal  c1_app_af_cmd          : std_logic_vector(2 downto 0);
  signal  c1_rd_data_fifo_out    : std_logic_vector((C1_DDR2_APPDATA_WIDTH)-1 downto 0);
  signal  c1_app_wdf_data        : std_logic_vector((C1_DDR2_APPDATA_WIDTH)-1 downto 0);
  signal  c1_app_wdf_mask_data   : std_logic_vector((C1_DDR2_APPDATA_WIDTH/8)-1 downto 0);
  signal  c1_i_phy_init_done      : std_logic;



 -- Debug signals (optional use)

  --***********************************
  -- PHY Debug Port demo
  --***********************************
  signal cs_control0            : std_logic_vector(35 downto 0);
  signal cs_control1            : std_logic_vector(35 downto 0);
  signal cs_control2            : std_logic_vector(35 downto 0);
  signal cs_control3            : std_logic_vector(35 downto 0);
  signal vio0_in                : std_logic_vector(191 downto 0);
  signal vio1_in                : std_logic_vector(95 downto 0);
  signal vio2_in                : std_logic_vector(99 downto 0);
  signal vio3_out               : std_logic_vector(31 downto 0);




  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of arc_mem_interface_top : architecture IS
    "mig_v3_61_ddr2_v5, Coregen 12.4";

  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of arc_mem_interface_top : architecture IS "ddr2_v5,mig_v3_61,{component_name=ddr2_16bx2_mig361, C0_BANK_WIDTH=3, C0_CKE_WIDTH=1, C0_CLK_WIDTH=1, C0_COL_WIDTH=10, C0_CS_NUM=1, C0_CS_WIDTH=1, C0_DM_WIDTH=2, C0_DQ_WIDTH=16, C0_DQ_PER_DQS=8, C0_DQS_WIDTH=2, C0_ODT_WIDTH=1, C0_ROW_WIDTH=14, C0_ADDITIVE_LAT=0, C0_BURST_LEN=4, C0_BURST_TYPE=0, C0_CAS_LAT=3, C0_ECC_ENABLE=0, C0_MULTI_BANK_EN=1, C0_TWO_T_TIME_EN=0, C0_ODT_TYPE=1, C0_REDUCE_DRV=0, C0_REG_ENABLE=0, C0_TREFI_NS=7800, C0_TRAS=40000, C0_TRCD=15000, C0_TRFC=197500, C0_TRP=15000, C0_TRTP=7500, C0_TWR=15000, C0_TWTR=7500, F0_CLK_PERIOD=5000, RST_ACT_LOW=1, C0_INTERFACE_TYPE=DDR2_SDRAM,C1_BANK_WIDTH=3, C1_CKE_WIDTH=1, C1_CLK_WIDTH=1, C1_COL_WIDTH=10, C1_CS_NUM=1, C1_CS_WIDTH=1, C1_DM_WIDTH=2, C1_DQ_WIDTH=16, C1_DQ_PER_DQS=8, C1_DQS_WIDTH=2, C1_ODT_WIDTH=1, C1_ROW_WIDTH=14, C1_ADDITIVE_LAT=0, C1_BURST_LEN=4, C1_BURST_TYPE=0, C1_CAS_LAT=3, C1_ECC_ENABLE=0, C1_MULTI_BANK_EN=1, C1_TWO_T_TIME_EN=0, C1_ODT_TYPE=1, C1_REDUCE_DRV=0, C1_REG_ENABLE=0, C1_TREFI_NS=7800, C1_TRAS=40000, C1_TRCD=15000, C1_TRFC=197500, C1_TRP=15000, C1_TRTP=7500, C1_TWR=15000, C1_TWTR=7500, F0_CLK_PERIOD=5000, RST_ACT_LOW=1, C1_INTERFACE_TYPE=DDR2_SDRAM, LANGUAGE=VHDL, SYNTHESIS_TOOL=ISE, NO_OF_CONTROLLERS=2}";

begin

  --***************************************************************************
  c0_phy_init_done   <= c0_i_phy_init_done;
  c1_phy_init_done   <= c1_i_phy_init_done;
  ddr2_sys_clk_f0_p <= '1';
  ddr2_sys_clk_f0_n <= '0';
  clk200_p <= '1';
  clk200_n <= '0';

  u_ddr2_idelay_ctrl : ddr2_idelay_ctrl
    generic map (
      IODELAY_GRP        => IODELAY_GRP
   )
    port map (
      rst200                => rst200,
      clk200                => clk200,
      idelay_ctrl_rdy       => idelay_ctrl_rdy
   );

u_ddr2_infrastructure_f0 :ddr2_infrastructure
    generic map (
      CLK_PERIOD            => F0_DDR2_CLK_PERIOD,
      DLL_FREQ_MODE         => F0_DDR2_DLL_FREQ_MODE,
      CLK_TYPE              => CLK_TYPE,
      NOCLK200              => F0_DDR2_NOCLK200,
      RST_ACT_LOW           => RST_ACT_LOW
   )
    port map (
      sys_clk_p             => ddr2_sys_clk_f0_p,
      sys_clk_n             => ddr2_sys_clk_f0_n,
      sys_clk               => ddr2_sys_clk_f0,
      clk200_p              => clk200_p,
      clk200_n              => clk200_n,
      idly_clk_200          => idly_clk_200,
      sys_rst_n             => sys_rst_n,
      rst0                  => f0_rst0,
      rst90                 => f0_rst90,
      rstdiv0               => f0_rstdiv0,
      rst200                => rst200,
      clk0                  => f0_ddr2_clk0,
      clk90                 => f0_ddr2_clk90,
      clkdiv0               => f0_ddr2_clkdiv0,
      clk200                => clk200,
      idelay_ctrl_rdy       => idelay_ctrl_rdy
   );

  u_ddr2_top_0 : ddr2_top
    generic map (
      BANK_WIDTH            => C0_DDR2_BANK_WIDTH,
      CKE_WIDTH             => C0_DDR2_CKE_WIDTH,
      CLK_WIDTH             => C0_DDR2_CLK_WIDTH,
      COL_WIDTH             => C0_DDR2_COL_WIDTH,
      CS_NUM                => C0_DDR2_CS_NUM,
      CS_WIDTH              => C0_DDR2_CS_WIDTH,
      CS_BITS               => C0_DDR2_CS_BITS,
      DM_WIDTH              => C0_DDR2_DM_WIDTH,
      DQ_WIDTH              => C0_DDR2_DQ_WIDTH,
      DQ_PER_DQS            => C0_DDR2_DQ_PER_DQS,
      DQS_WIDTH             => C0_DDR2_DQS_WIDTH,
      DQ_BITS               => C0_DDR2_DQ_BITS,
      DQS_BITS              => C0_DDR2_DQS_BITS,
      ODT_WIDTH             => C0_DDR2_ODT_WIDTH,
      ROW_WIDTH             => C0_DDR2_ROW_WIDTH,
      ADDITIVE_LAT          => C0_DDR2_ADDITIVE_LAT,
      BURST_LEN             => C0_DDR2_BURST_LEN,
      BURST_TYPE            => C0_DDR2_BURST_TYPE,
      CAS_LAT               => C0_DDR2_CAS_LAT,
      ECC_ENABLE            => C0_DDR2_ECC_ENABLE,
      APPDATA_WIDTH         => C0_DDR2_APPDATA_WIDTH,
      MULTI_BANK_EN         => C0_DDR2_MULTI_BANK_EN,
      TWO_T_TIME_EN         => C0_DDR2_TWO_T_TIME_EN,
      ODT_TYPE              => C0_DDR2_ODT_TYPE,
      REDUCE_DRV            => C0_DDR2_REDUCE_DRV,
      REG_ENABLE            => C0_DDR2_REG_ENABLE,
      TREFI_NS              => C0_DDR2_TREFI_NS,
      TRAS                  => C0_DDR2_TRAS,
      TRCD                  => C0_DDR2_TRCD,
      TRFC                  => C0_DDR2_TRFC,
      TRP                   => C0_DDR2_TRP,
      TRTP                  => C0_DDR2_TRTP,
      TWR                   => C0_DDR2_TWR,
      TWTR                  => C0_DDR2_TWTR,
      HIGH_PERFORMANCE_MODE   => C0_DDR2_HIGH_PERFORMANCE_MODE,
      IODELAY_GRP           => IODELAY_GRP,
      SIM_ONLY              => C0_DDR2_SIM_ONLY,
      DEBUG_EN              => C0_DDR2_DEBUG_EN,
      FPGA_SPEED_GRADE      => 1,
      USE_DM_PORT           => 1,
      CLK_PERIOD            => F0_DDR2_CLK_PERIOD
      )
    port map (
      ddr2_dq               => c0_ddr2_dq,
      ddr2_a                => c0_ddr2_a,
      ddr2_ba               => c0_ddr2_ba,
      ddr2_ras_n            => c0_ddr2_ras_n,
      ddr2_cas_n            => c0_ddr2_cas_n,
      ddr2_we_n             => c0_ddr2_we_n,
      ddr2_cs_n             => c0_ddr2_cs_n,
      ddr2_odt              => c0_ddr2_odt,
      ddr2_cke              => c0_ddr2_cke,
      ddr2_dm               => c0_ddr2_dm,
      phy_init_done         => c0_i_phy_init_done,
      rst0                  => f0_rst0,
      rst90                 => f0_rst90,
      rstdiv0               => f0_rstdiv0,
      clk0                  => f0_ddr2_clk0,
      clk90                 => f0_ddr2_clk90,
      clkdiv0               => f0_ddr2_clkdiv0,
      app_wdf_afull         => c0_app_wdf_afull,
      app_af_afull          => c0_app_af_afull,
      rd_data_valid         => c0_rd_data_valid,
      app_wdf_wren          => c0_app_wdf_wren,
      app_af_wren           => c0_app_af_wren,
      app_af_addr           => c0_app_af_addr,
      app_af_cmd            => c0_app_af_cmd,
      rd_data_fifo_out      => c0_rd_data_fifo_out,
      app_wdf_data          => c0_app_wdf_data,
      app_wdf_mask_data     => c0_app_wdf_mask_data,
      ddr2_dqs              => c0_ddr2_dqs,
      ddr2_dqs_n            => c0_ddr2_dqs_n,
      ddr2_ck               => c0_ddr2_ck,
      rd_ecc_error          => open,
      ddr2_ck_n             => c0_ddr2_ck_n,

      dbg_calib_done          => c0_dbg_calib_done,
      dbg_calib_err           => c0_dbg_calib_err,
      dbg_calib_dq_tap_cnt    => c0_dbg_calib_dq_tap_cnt,
      dbg_calib_dqs_tap_cnt   => c0_dbg_calib_dqs_tap_cnt,
      dbg_calib_gate_tap_cnt   => c0_dbg_calib_gate_tap_cnt,
      dbg_calib_rd_data_sel   => c0_dbg_calib_rd_data_sel,
      dbg_calib_rden_dly      => c0_dbg_calib_rden_dly,
      dbg_calib_gate_dly      => c0_dbg_calib_gate_dly,
      dbg_idel_up_all         => c0_dbg_idel_up_all,
      dbg_idel_down_all       => c0_dbg_idel_down_all,
      dbg_idel_up_dq          => c0_dbg_idel_up_dq,
      dbg_idel_down_dq        => c0_dbg_idel_down_dq,
      dbg_idel_up_dqs         => c0_dbg_idel_up_dqs,
      dbg_idel_down_dqs       => c0_dbg_idel_down_dqs,
      dbg_idel_up_gate        => c0_dbg_idel_up_gate,
      dbg_idel_down_gate      => c0_dbg_idel_down_gate,
      dbg_sel_idel_dq         => c0_dbg_sel_idel_dq,
      dbg_sel_all_idel_dq     => c0_dbg_sel_all_idel_dq,
      dbg_sel_idel_dqs        => c0_dbg_sel_idel_dqs,
      dbg_sel_all_idel_dqs    => c0_dbg_sel_all_idel_dqs,
      dbg_sel_idel_gate       => c0_dbg_sel_idel_gate,
      dbg_sel_all_idel_gate   => c0_dbg_sel_all_idel_gate
      );
  u_ddr2_top_1 : ddr2_top
    generic map (
      BANK_WIDTH            => C1_DDR2_BANK_WIDTH,
      CKE_WIDTH             => C1_DDR2_CKE_WIDTH,
      CLK_WIDTH             => C1_DDR2_CLK_WIDTH,
      COL_WIDTH             => C1_DDR2_COL_WIDTH,
      CS_NUM                => C1_DDR2_CS_NUM,
      CS_WIDTH              => C1_DDR2_CS_WIDTH,
      CS_BITS               => C1_DDR2_CS_BITS,
      DM_WIDTH              => C1_DDR2_DM_WIDTH,
      DQ_WIDTH              => C1_DDR2_DQ_WIDTH,
      DQ_PER_DQS            => C1_DDR2_DQ_PER_DQS,
      DQS_WIDTH             => C1_DDR2_DQS_WIDTH,
      DQ_BITS               => C1_DDR2_DQ_BITS,
      DQS_BITS              => C1_DDR2_DQS_BITS,
      ODT_WIDTH             => C1_DDR2_ODT_WIDTH,
      ROW_WIDTH             => C1_DDR2_ROW_WIDTH,
      ADDITIVE_LAT          => C1_DDR2_ADDITIVE_LAT,
      BURST_LEN             => C1_DDR2_BURST_LEN,
      BURST_TYPE            => C1_DDR2_BURST_TYPE,
      CAS_LAT               => C1_DDR2_CAS_LAT,
      ECC_ENABLE            => C1_DDR2_ECC_ENABLE,
      APPDATA_WIDTH         => C1_DDR2_APPDATA_WIDTH,
      MULTI_BANK_EN         => C1_DDR2_MULTI_BANK_EN,
      TWO_T_TIME_EN         => C1_DDR2_TWO_T_TIME_EN,
      ODT_TYPE              => C1_DDR2_ODT_TYPE,
      REDUCE_DRV            => C1_DDR2_REDUCE_DRV,
      REG_ENABLE            => C1_DDR2_REG_ENABLE,
      TREFI_NS              => C1_DDR2_TREFI_NS,
      TRAS                  => C1_DDR2_TRAS,
      TRCD                  => C1_DDR2_TRCD,
      TRFC                  => C1_DDR2_TRFC,
      TRP                   => C1_DDR2_TRP,
      TRTP                  => C1_DDR2_TRTP,
      TWR                   => C1_DDR2_TWR,
      TWTR                  => C1_DDR2_TWTR,
      HIGH_PERFORMANCE_MODE   => C1_DDR2_HIGH_PERFORMANCE_MODE,
      IODELAY_GRP           => IODELAY_GRP,
      SIM_ONLY              => C1_DDR2_SIM_ONLY,
      DEBUG_EN              => C1_DDR2_DEBUG_EN,
      FPGA_SPEED_GRADE      => 1,
      CLK_PERIOD            => F0_ddr2_CLK_PERIOD,
      USE_DM_PORT           => 1
      )
    port map (
      ddr2_dq               => c1_ddr2_dq,
      ddr2_a                => c1_ddr2_a,
      ddr2_ba               => c1_ddr2_ba,
      ddr2_ras_n            => c1_ddr2_ras_n,
      ddr2_cas_n            => c1_ddr2_cas_n,
      ddr2_we_n             => c1_ddr2_we_n,
      ddr2_cs_n             => c1_ddr2_cs_n,
      ddr2_odt              => c1_ddr2_odt,
      ddr2_cke              => c1_ddr2_cke,
      ddr2_dm               => c1_ddr2_dm,
      phy_init_done         => c1_i_phy_init_done,
      rst0                  => f0_rst0,
      rst90                 => f0_rst90,
      rstdiv0               => f0_rstdiv0,
      clk0                  => f0_ddr2_clk0,
      clk90                 => f0_ddr2_clk90,
      clkdiv0               => f0_ddr2_clkdiv0,
      app_wdf_afull         => c1_app_wdf_afull,
      app_af_afull          => c1_app_af_afull,
      rd_data_valid         => c1_rd_data_valid,
      app_wdf_wren          => c1_app_wdf_wren,
      app_af_wren           => c1_app_af_wren,
      app_af_addr           => c1_app_af_addr,
      app_af_cmd            => c1_app_af_cmd,
      rd_data_fifo_out      => c1_rd_data_fifo_out,
      app_wdf_data          => c1_app_wdf_data,
      app_wdf_mask_data     => c1_app_wdf_mask_data,
      ddr2_dqs              => c1_ddr2_dqs,
      ddr2_dqs_n            => c1_ddr2_dqs_n,
      ddr2_ck               => c1_ddr2_ck,
      rd_ecc_error          => open,
      ddr2_ck_n             => c1_ddr2_ck_n,

      dbg_calib_done          => open,
      dbg_calib_err           => open,
      dbg_calib_dq_tap_cnt    => open,
      dbg_calib_dqs_tap_cnt   => open,
      dbg_calib_gate_tap_cnt   => open,
      dbg_calib_rd_data_sel   => open,
      dbg_calib_rden_dly      => open,
      dbg_calib_gate_dly      => open,
      dbg_idel_up_all         => '0',
      dbg_idel_down_all       => '0',
      dbg_idel_up_dq          => '0',
      dbg_idel_down_dq        => '0',
      dbg_idel_up_dqs         => '0',
      dbg_idel_down_dqs       => '0',
      dbg_idel_up_gate        => '0',
      dbg_idel_down_gate      => '0',
      dbg_sel_idel_dq         => c1_dq_zeros,
      dbg_sel_all_idel_dq     => '0',
      dbg_sel_idel_dqs        => c1_dqs_zeros,
      dbg_sel_all_idel_dqs    => '0',
      dbg_sel_idel_gate       => c1_dqs_zeros,
      dbg_sel_all_idel_gate   => '0'
      );

  u_ddr2_tb_top_0 : ddr2_tb_top
    generic map (
      BANK_WIDTH            => C0_DDR2_BANK_WIDTH,
      COL_WIDTH             => C0_DDR2_COL_WIDTH,
      DM_WIDTH              => C0_DDR2_DM_WIDTH,
      DQ_WIDTH              => C0_DDR2_DQ_WIDTH,
      ROW_WIDTH             => C0_DDR2_ROW_WIDTH,
      BURST_LEN             => C0_DDR2_BURST_LEN,
      ECC_ENABLE            => C0_DDR2_ECC_ENABLE,
      APPDATA_WIDTH         => C0_DDR2_APPDATA_WIDTH
      )
    port map (
      phy_init_done         => c0_i_phy_init_done,
      error                 => c0_error,
      error_cmp             => c0_error_cmp,
      rst0                  => f0_rst0,
      clk0                  => f0_ddr2_clk0,
      app_wdf_afull         => c0_app_wdf_afull,
      app_af_afull          => c0_app_af_afull,
      rd_data_valid         => c0_rd_data_valid,
      app_wdf_wren          => c0_app_wdf_wren,
      app_af_wren           => c0_app_af_wren,
      app_af_addr           => c0_app_af_addr,
      app_af_cmd            => c0_app_af_cmd,
      rd_data_fifo_out      => c0_rd_data_fifo_out,
      app_wdf_data          => c0_app_wdf_data,
      app_wdf_mask_data     => c0_app_wdf_mask_data
      );
  u_ddr2_tb_top_1 : ddr2_tb_top
    generic map (
      BANK_WIDTH            => C1_DDR2_BANK_WIDTH,
      COL_WIDTH             => C1_DDR2_COL_WIDTH,
      DM_WIDTH              => C1_DDR2_DM_WIDTH,
      DQ_WIDTH              => C1_DDR2_DQ_WIDTH,
      ROW_WIDTH             => C1_DDR2_ROW_WIDTH,
      BURST_LEN             => C1_DDR2_BURST_LEN,
      ECC_ENABLE            => C1_DDR2_ECC_ENABLE,
      APPDATA_WIDTH         => C1_DDR2_APPDATA_WIDTH
      )
    port map (
      phy_init_done         => c1_i_phy_init_done,
      error                 => c1_error,
      error_cmp             => c1_error_cmp,
      rst0                  => f0_rst0,
      clk0                  => f0_ddr2_clk0,
      app_wdf_afull         => c1_app_wdf_afull,
      app_af_afull          => c1_app_af_afull,
      rd_data_valid         => c1_rd_data_valid,
      app_wdf_wren          => c1_app_wdf_wren,
      app_af_wren           => c1_app_af_wren,
      app_af_addr           => c1_app_af_addr,
      app_af_cmd            => c1_app_af_cmd,
      rd_data_fifo_out      => c1_rd_data_fifo_out,
      app_wdf_data          => c1_app_wdf_data,
      app_wdf_mask_data     => c1_app_wdf_mask_data
      );

  --*****************************************************************
  -- Hooks to prevent sim/syn compilation errors (mainly for VHDL - but
  -- keep it also in Verilog version of code) w/ floating inputs if
  -- DEBUG_EN = 0.
  --*****************************************************************

  gen_dbg_tie_off: if (C0_DDR2_DEBUG_EN = 0) generate
    c0_dbg_idel_up_all       <= '0';
    c0_dbg_idel_down_all     <= '0';
    c0_dbg_idel_up_dq        <= '0';
    c0_dbg_idel_down_dq      <= '0';
    c0_dbg_idel_up_dqs       <= '0';
    c0_dbg_idel_down_dqs     <= '0';
    c0_dbg_idel_up_gate      <= '0';
    c0_dbg_idel_down_gate    <= '0';
    c0_dbg_sel_idel_dq       <= (others => '0');
    c0_dbg_sel_all_idel_dq   <= '0';
    c0_dbg_sel_idel_dqs      <= (others => '0');
    c0_dbg_sel_all_idel_dqs  <= '0';
    c0_dbg_sel_idel_gate     <= (others => '0');
    c0_dbg_sel_all_idel_gate <= '0';

  end generate;

  gen_dbg_tie_on: if (C0_DDR2_DEBUG_EN = 1) generate
   
      --*****************************************************************
      -- Bit assignments:
      -- NOTE: Not all VIO, ILA inputs/outputs may be used - these will
      --       be dependent on the user's particular bit width
      --*****************************************************************

      gen_dq_le_32: if (C0_DDR2_DQ_WIDTH <= 32) generate
        vio0_in((6*C0_DDR2_DQ_WIDTH)-1 downto 0) <= 
	                    c0_dbg_calib_dq_tap_cnt((6*C0_DDR2_DQ_WIDTH)-1 downto 0);
      end generate;

      gen_dq_gt_32: if (C0_DDR2_DQ_WIDTH > 32) generate 
        vio0_in <= c0_dbg_calib_dq_tap_cnt(191 downto 0);
      end generate;

      gen_dqs_le_8: if (C0_DDR2_DQS_WIDTH <= 8) generate
        vio1_in((6*C0_DDR2_DQS_WIDTH)-1 downto 0) <= 
	                    c0_dbg_calib_dqs_tap_cnt((6*C0_DDR2_DQS_WIDTH)-1 downto 0);
        vio1_in((12*C0_DDR2_DQS_WIDTH)-1 downto (6*C0_DDR2_DQS_WIDTH)) <=
	                    c0_dbg_calib_gate_tap_cnt((6*C0_DDR2_DQS_WIDTH)-1 downto 0);
      end generate;
      
      gen_dqs_gt_8: if (C0_DDR2_DQS_WIDTH > 8) generate
        vio1_in(47 downto 0) <= c0_dbg_calib_dqs_tap_cnt(47 downto 0);
        vio1_in(95 downto 48) <= c0_dbg_calib_gate_tap_cnt(47 downto 0);
      end generate;
 
      --dbg_calib_rd_data_sel

      gen_rdsel_le_8: if (C0_DDR2_DQS_WIDTH <= 8) generate
        vio2_in((C0_DDR2_DQS_WIDTH)+7 downto 8) <= 
	                    c0_dbg_calib_rd_data_sel((C0_DDR2_DQS_WIDTH)-1 downto 0);
      end generate;
      gen_rdsel_gt_8: if (C0_DDR2_DQS_WIDTH > 8) generate
        vio2_in(15 downto 8) <= c0_dbg_calib_rd_data_sel(7 downto 0);
      end generate;
 
      --dbg_calib_rden_dly

      gen_calrd_le_8: if (C0_DDR2_DQS_WIDTH <= 8) generate
        vio2_in((5*C0_DDR2_DQS_WIDTH)+19 downto 20) <= 
	                    c0_dbg_calib_rden_dly((5*C0_DDR2_DQS_WIDTH)-1 downto 0);
      end generate; 
     
      gen_calrd_gt_8: if (C0_DDR2_DQS_WIDTH > 8) generate
        vio2_in(59 downto 20) <= c0_dbg_calib_rden_dly(39 downto 0);
      end generate;

      --dbg_calib_gate_dly

      gen_calgt_le_8: if (C0_DDR2_DQS_WIDTH <= 8) generate
        vio2_in((5*C0_DDR2_DQS_WIDTH)+59 downto 60) <= 
	                    c0_dbg_calib_gate_dly((5*C0_DDR2_DQS_WIDTH)-1 downto 0);
      end generate; 

      gen_calgt_gt_8: if (C0_DDR2_DQS_WIDTH > 8) generate
        vio2_in(99 downto 60) <= c0_dbg_calib_gate_dly(39 downto 0);
      end generate;

      --dbg_sel_idel_dq

      gen_selid_le_5: if (C0_DDR2_DQ_BITS <= 5) generate
        c0_dbg_sel_idel_dq(C0_DDR2_DQ_BITS-1 downto 0) <= vio3_out(C0_DDR2_DQ_BITS+7 downto 8);
      end generate;
      
      gen_selid_gt_5: if (C0_DDR2_DQ_BITS > 5) generate
        c0_dbg_sel_idel_dq(4 downto 0) <= vio3_out(12 downto 8);
      end generate;

      --dbg_sel_idel_dqs

      gen_seldqs_le_3: if (C0_DDR2_DQS_BITS <= 3) generate
        c0_dbg_sel_idel_dqs(C0_DDR2_DQS_BITS downto 0) <= 
	                    vio3_out((C0_DDR2_DQS_BITS+16) downto 16);
      end generate;
      
      gen_seldqs_gt_3: if (C0_DDR2_DQS_BITS > 3) generate
        c0_dbg_sel_idel_dqs(3 downto 0) <= vio3_out(19 downto 16);
      end generate;

      --dbg_sel_idel_gate

      gen_gtdqs_le_3: if (C0_DDR2_DQS_BITS <= 3) generate
        c0_dbg_sel_idel_gate(C0_DDR2_DQS_BITS downto 0) <= vio3_out((C0_DDR2_DQS_BITS+21) downto 21);
      end generate;

      gen_gtdqs_gt_3: if (C0_DDR2_DQS_BITS > 3) generate
        c0_dbg_sel_idel_gate(3 downto 0) <= vio3_out(24 downto 21);
     end generate;

      vio2_in(3 downto 0)              <= c0_dbg_calib_done;
      vio2_in(7 downto 4)       <= c0_dbg_calib_err;
      
      c0_dbg_idel_up_all           <= vio3_out(0);
      c0_dbg_idel_down_all         <= vio3_out(1);
      c0_dbg_idel_up_dq            <= vio3_out(2);
      c0_dbg_idel_down_dq          <= vio3_out(3);
      c0_dbg_idel_up_dqs           <= vio3_out(4);
      c0_dbg_idel_down_dqs         <= vio3_out(5);
      c0_dbg_idel_up_gate          <= vio3_out(6);
      c0_dbg_idel_down_gate        <= vio3_out(7);
      c0_dbg_sel_all_idel_dq       <= vio3_out(15);
      c0_dbg_sel_all_idel_dqs      <= vio3_out(20);
      c0_dbg_sel_all_idel_gate     <= vio3_out(25);

    u_icon  : icon4
    port map (
      control0              => cs_control0,
      control1              => cs_control1,
      control2              => cs_control2,
      control3              => cs_control3
      );

      --*****************************************************************
      -- VIO ASYNC input: Display current IDELAY setting for up to 32
      -- DQ taps (32x6) = 192
      --*****************************************************************

    u_vio0 : vio_async_in192
    port map (
      control               => cs_control0,
      async_in              => vio0_in
      );

      --*****************************************************************
      -- VIO ASYNC input: Display current IDELAY setting for up to 8 DQS
      -- and DQS Gate taps (8x6x2) = 96
      --*****************************************************************

    u_vio1 : vio_async_in96 
    port map (
      control               => cs_control1,
      async_in              => vio1_in
      );

      --*****************************************************************
      -- VIO ASYNC input: Display other calibration results
      --*****************************************************************

    u_vio2 : vio_async_in100 
    port map (
      control               => cs_control2,
      async_in              => vio2_in
      );
      
      --*****************************************************************
      -- VIO SYNC output: Dynamically change IDELAY taps
      --*****************************************************************
      
    u_vio3 : vio_sync_out32 
    port map (
      control               => cs_control3,
      clk                   => f0_ddr2_clkdiv0,
      sync_out              => vio3_out
      );

  end generate;


end architecture arc_mem_interface_top;
