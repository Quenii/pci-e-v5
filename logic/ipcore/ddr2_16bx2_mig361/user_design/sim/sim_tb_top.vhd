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
-- Copyright 2007, 2008 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : 2.2
--  \   \        Application        : MIG
--  /   /        Filename           : sim_tb_top.vhd
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:26:02 $
-- \   \  /  \   Date Created       : Mon May 14 2007
--  \___\/\___\
--
-- Device      : Virtex-5
-- Design Name : DDR2
-- Purpose     : This is the simulation testbench which is used to verify the
--               design. The basic clocks and resets to the interface are
--               generated here. This also connects the memory interface to the
--               memory model.
-- Reference:
-- Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity sim_tb_top is

end entity sim_tb_top;

architecture arch of sim_tb_top is

  -- memory controller parameters
constant    C0_DDR2_BANK_WIDTH       : integer := 3; 
                              -- # of memory bank addr bits.
constant    C0_DDR2_CKE_WIDTH        : integer := 1; 
                              -- # of memory clock enable outputs.
constant    C0_DDR2_CLK_WIDTH        : integer := 1; 
                              -- # of clock outputs.
constant    C0_DDR2_COL_WIDTH        : integer := 10; 
                              -- # of memory column bits.
constant    C0_DDR2_CS_NUM           : integer := 1; 
                              -- # of separate memory chip selects.
constant    C0_DDR2_CS_WIDTH         : integer := 1; 
                              -- # of total memory chip selects.
constant    C0_DDR2_CS_BITS          : integer := 0; 
                              -- set to log2(CS_NUM) (rounded up).
constant    C0_DDR2_DM_WIDTH         : integer := 2; 
                              -- # of data mask bits.
constant    C0_DDR2_DQ_WIDTH         : integer := 16; 
                              -- # of data width.
constant    C0_DDR2_DQ_PER_DQS       : integer := 8; 
                              -- # of DQ data bits per strobe.
constant    C0_DDR2_DQS_WIDTH        : integer := 2; 
                              -- # of DQS strobes.
constant    C0_DDR2_DQ_BITS          : integer := 4; 
                              -- set to log2(DQS_WIDTH*DQ_PER_DQS).
constant    C0_DDR2_DQS_BITS         : integer := 1; 
                              -- set to log2(DQS_WIDTH).
constant    C0_DDR2_ODT_WIDTH        : integer := 1; 
                              -- # of memory on-die term enables.
constant    C0_DDR2_ROW_WIDTH        : integer := 14; 
                              -- # of memory row and # of addr bits.
constant    C0_DDR2_ADDITIVE_LAT     : integer := 0; 
                              -- additive write latency.
constant    C0_DDR2_BURST_LEN        : integer := 4; 
                              -- burst length (in double words).
constant    C0_DDR2_BURST_TYPE       : integer := 0; 
                              -- burst type (=0 seq; =1 interleaved).
constant    C0_DDR2_CAS_LAT          : integer := 3; 
                              -- CAS latency.
constant    C0_DDR2_ECC_ENABLE       : integer := 0; 
                              -- enable ECC (=1 enable).
constant    C0_DDR2_APPDATA_WIDTH    : integer := 32; 
                              -- # of usr read/write data bus bits.
constant    C0_DDR2_MULTI_BANK_EN    : integer := 1; 
                              -- Keeps multiple banks open. (= 1 enable).
constant    C0_DDR2_TWO_T_TIME_EN    : integer := 0; 
                              -- 2t timing for unbuffered dimms.
constant    C0_DDR2_ODT_TYPE         : integer := 1; 
                              -- ODT (=0(none),=1(75),=2(150),=3(50)).
constant    C0_DDR2_REDUCE_DRV       : integer := 0; 
                              -- reduced strength mem I/O (=1 yes).
constant    C0_DDR2_REG_ENABLE       : integer := 0; 
                              -- registered addr/ctrl (=1 yes).
constant    C0_DDR2_TREFI_NS         : integer := 7800; 
                              -- auto refresh interval (ns).
constant    C0_DDR2_TRAS             : integer := 40000; 
                              -- active->precharge delay.
constant    C0_DDR2_TRCD             : integer := 15000; 
                              -- active->read/write delay.
constant    C0_DDR2_TRFC             : integer := 197500; 
                              -- refresh->refresh, refresh->active delay.
constant    C0_DDR2_TRP              : integer := 15000; 
                              -- precharge->command delay.
constant    C0_DDR2_TRTP             : integer := 7500; 
                              -- read->precharge delay.
constant    C0_DDR2_TWR              : integer := 15000; 
                              -- used to determine write->precharge.
constant    C0_DDR2_TWTR             : integer := 7500; 
                              -- write->read delay.
constant    C0_DDR2_HIGH_PERFORMANCE_MODE  : boolean := TRUE; 
                              -- # = TRUE, the IODELAY performance mode is set
                              -- to high.
                              -- # = FALSE, the IODELAY performance mode is set
                              -- to low.
constant    C0_DDR2_SIM_ONLY         : integer := 1; 
                              -- = 1 to skip SDRAM power up delay.
constant    C0_DDR2_DEBUG_EN         : integer := 1; 
                              -- Enable debug signals/controls.
                              -- When this parameter is changed from 0 to 1,
                              -- make sure to uncomment the coregen commands
                              -- in ise_flow.bat or create_ise.bat files in
                              -- par folder.
constant    F0_DDR2_CLK_PERIOD       : integer := 5000; 
                              -- Core/Memory clock period (in ps).
constant    F0_DDR2_DLL_FREQ_MODE    : string := "HIGH"; 
                              -- DCM Frequency range.
constant    CLK_TYPE                 : string := "SINGLE_ENDED"; 
                              -- # = "DIFFERENTIAL " ->; Differential input clocks ,
                              -- # = "SINGLE_ENDED" -> Single ended input clocks.
constant    F0_DDR2_NOCLK200         : boolean := FALSE; 
                              -- clk200 enable and disable
constant    RST_ACT_LOW              : integer := 1; 
                              -- =1 for active low reset, =0 for active high.
constant    C1_DDR2_BANK_WIDTH       : integer := 3; 
                              -- # of memory bank addr bits.
constant    C1_DDR2_CKE_WIDTH        : integer := 1; 
                              -- # of memory clock enable outputs.
constant    C1_DDR2_CLK_WIDTH        : integer := 1; 
                              -- # of clock outputs.
constant    C1_DDR2_COL_WIDTH        : integer := 10; 
                              -- # of memory column bits.
constant    C1_DDR2_CS_NUM           : integer := 1; 
                              -- # of separate memory chip selects.
constant    C1_DDR2_CS_WIDTH         : integer := 1; 
                              -- # of total memory chip selects.
constant    C1_DDR2_CS_BITS          : integer := 0; 
                              -- set to log2(CS_NUM) (rounded up).
constant    C1_DDR2_DM_WIDTH         : integer := 2; 
                              -- # of data mask bits.
constant    C1_DDR2_DQ_WIDTH         : integer := 16; 
                              -- # of data width.
constant    C1_DDR2_DQ_PER_DQS       : integer := 8; 
                              -- # of DQ data bits per strobe.
constant    C1_DDR2_DQS_WIDTH        : integer := 2; 
                              -- # of DQS strobes.
constant    C1_DDR2_DQ_BITS          : integer := 4; 
                              -- set to log2(DQS_WIDTH*DQ_PER_DQS).
constant    C1_DDR2_DQS_BITS         : integer := 1; 
                              -- set to log2(DQS_WIDTH).
constant    C1_DDR2_ODT_WIDTH        : integer := 1; 
                              -- # of memory on-die term enables.
constant    C1_DDR2_ROW_WIDTH        : integer := 14; 
                              -- # of memory row and # of addr bits.
constant    C1_DDR2_ADDITIVE_LAT     : integer := 0; 
                              -- additive write latency.
constant    C1_DDR2_BURST_LEN        : integer := 4; 
                              -- burst length (in double words).
constant    C1_DDR2_BURST_TYPE       : integer := 0; 
                              -- burst type (=0 seq; =1 interleaved).
constant    C1_DDR2_CAS_LAT          : integer := 3; 
                              -- CAS latency.
constant    C1_DDR2_ECC_ENABLE       : integer := 0; 
                              -- enable ECC (=1 enable).
constant    C1_DDR2_APPDATA_WIDTH    : integer := 32; 
                              -- # of usr read/write data bus bits.
constant    C1_DDR2_MULTI_BANK_EN    : integer := 1; 
                              -- Keeps multiple banks open. (= 1 enable).
constant    C1_DDR2_TWO_T_TIME_EN    : integer := 0; 
                              -- 2t timing for unbuffered dimms.
constant    C1_DDR2_ODT_TYPE         : integer := 1; 
                              -- ODT (=0(none),=1(75),=2(150),=3(50)).
constant    C1_DDR2_REDUCE_DRV       : integer := 0; 
                              -- reduced strength mem I/O (=1 yes).
constant    C1_DDR2_REG_ENABLE       : integer := 0; 
                              -- registered addr/ctrl (=1 yes).
constant    C1_DDR2_TREFI_NS         : integer := 7800; 
                              -- auto refresh interval (ns).
constant    C1_DDR2_TRAS             : integer := 40000; 
                              -- active->precharge delay.
constant    C1_DDR2_TRCD             : integer := 15000; 
                              -- active->read/write delay.
constant    C1_DDR2_TRFC             : integer := 197500; 
                              -- refresh->refresh, refresh->active delay.
constant    C1_DDR2_TRP              : integer := 15000; 
                              -- precharge->command delay.
constant    C1_DDR2_TRTP             : integer := 7500; 
                              -- read->precharge delay.
constant    C1_DDR2_TWR              : integer := 15000; 
                              -- used to determine write->precharge.
constant    C1_DDR2_TWTR             : integer := 7500; 
                              -- write->read delay.
constant    C1_DDR2_HIGH_PERFORMANCE_MODE  : boolean := TRUE; 
                              -- # = TRUE, the IODELAY performance mode is set
                              -- to high.
                              -- # = FALSE, the IODELAY performance mode is set
                              -- to low.
constant    C1_DDR2_SIM_ONLY         : integer := 1; 
                              -- = 1 to skip SDRAM power up delay.
constant    C1_DDR2_DEBUG_EN         : integer := 0  
                              ;-- Enable debug signals/controls.
                              

  constant C0_DDR2_DEVICE_WIDTH : integer := 16; -- Memory device data width for controller0
  constant C1_DDR2_DEVICE_WIDTH : integer := 16; -- Memory device data width for controller1


  constant F0_DDR2_CLK_PERIOD_NS   : real := 5000.0 / 1000.0;
  constant F0_TCYC_SYS        : real := F0_DDR2_CLK_PERIOD_NS/2.0;
  constant F0_TCYC_SYS_0      : time := F0_DDR2_CLK_PERIOD_NS * 1 ns;
  constant F0_TCYC_SYS_DIV2   : time := F0_TCYC_SYS * 1 ns;

  constant TEMP2           : real := 5.0/2.0;
  constant TCYC_200        : time := TEMP2 * 1 ns;
  constant TPROP_DQS          : time := 0.01 ns;  -- Delay for DQS signal during Write Operation
  constant TPROP_DQS_RD       : time := 0.01 ns;  -- Delay for DQS signal during Read Operation
  constant TPROP_PCB_CTRL     : time := 0.01 ns;  -- Delay for Address and Ctrl signals
  constant TPROP_PCB_DATA     : time := 0.01 ns;  -- Delay for data signal during Write operation
  constant TPROP_PCB_DATA_RD  : time := 0.01 ns;  -- Delay for data signal during Read operation

  
  
  component ddr2_16bx2_mig361 is
    generic (
   C0_DDR2_BANK_WIDTH       : integer;
   C0_DDR2_CKE_WIDTH        : integer;
   C0_DDR2_CLK_WIDTH        : integer;
   C0_DDR2_COL_WIDTH        : integer;
   C0_DDR2_CS_NUM           : integer;
   C0_DDR2_CS_WIDTH         : integer;
   C0_DDR2_CS_BITS          : integer;
   C0_DDR2_DM_WIDTH         : integer;
   C0_DDR2_DQ_WIDTH         : integer;
   C0_DDR2_DQ_PER_DQS       : integer;
   C0_DDR2_DQS_WIDTH        : integer;
   C0_DDR2_DQ_BITS          : integer;
   C0_DDR2_DQS_BITS         : integer;
   C0_DDR2_ODT_WIDTH        : integer;
   C0_DDR2_ROW_WIDTH        : integer;
   C0_DDR2_ADDITIVE_LAT     : integer;
   C0_DDR2_BURST_LEN        : integer;
   C0_DDR2_BURST_TYPE       : integer;
   C0_DDR2_CAS_LAT          : integer;
   C0_DDR2_ECC_ENABLE       : integer;
   C0_DDR2_APPDATA_WIDTH    : integer;
   C0_DDR2_MULTI_BANK_EN    : integer;
   C0_DDR2_TWO_T_TIME_EN    : integer;
   C0_DDR2_ODT_TYPE         : integer;
   C0_DDR2_REDUCE_DRV       : integer;
   C0_DDR2_REG_ENABLE       : integer;
   C0_DDR2_TREFI_NS         : integer;
   C0_DDR2_TRAS             : integer;
   C0_DDR2_TRCD             : integer;
   C0_DDR2_TRFC             : integer;
   C0_DDR2_TRP              : integer;
   C0_DDR2_TRTP             : integer;
   C0_DDR2_TWR              : integer;
   C0_DDR2_TWTR             : integer;
   C0_DDR2_HIGH_PERFORMANCE_MODE  : boolean;
   C0_DDR2_SIM_ONLY         : integer;
   C0_DDR2_DEBUG_EN         : integer;
   F0_DDR2_CLK_PERIOD       : integer;
   F0_DDR2_DLL_FREQ_MODE    : string;
   CLK_TYPE                 : string;
   F0_DDR2_NOCLK200         : boolean;
   RST_ACT_LOW              : integer;
   C1_DDR2_BANK_WIDTH       : integer;
   C1_DDR2_CKE_WIDTH        : integer;
   C1_DDR2_CLK_WIDTH        : integer;
   C1_DDR2_COL_WIDTH        : integer;
   C1_DDR2_CS_NUM           : integer;
   C1_DDR2_CS_WIDTH         : integer;
   C1_DDR2_CS_BITS          : integer;
   C1_DDR2_DM_WIDTH         : integer;
   C1_DDR2_DQ_WIDTH         : integer;
   C1_DDR2_DQ_PER_DQS       : integer;
   C1_DDR2_DQS_WIDTH        : integer;
   C1_DDR2_DQ_BITS          : integer;
   C1_DDR2_DQS_BITS         : integer;
   C1_DDR2_ODT_WIDTH        : integer;
   C1_DDR2_ROW_WIDTH        : integer;
   C1_DDR2_ADDITIVE_LAT     : integer;
   C1_DDR2_BURST_LEN        : integer;
   C1_DDR2_BURST_TYPE       : integer;
   C1_DDR2_CAS_LAT          : integer;
   C1_DDR2_ECC_ENABLE       : integer;
   C1_DDR2_APPDATA_WIDTH    : integer;
   C1_DDR2_MULTI_BANK_EN    : integer;
   C1_DDR2_TWO_T_TIME_EN    : integer;
   C1_DDR2_ODT_TYPE         : integer;
   C1_DDR2_REDUCE_DRV       : integer;
   C1_DDR2_REG_ENABLE       : integer;
   C1_DDR2_TREFI_NS         : integer;
   C1_DDR2_TRAS             : integer;
   C1_DDR2_TRCD             : integer;
   C1_DDR2_TRFC             : integer;
   C1_DDR2_TRP              : integer;
   C1_DDR2_TRTP             : integer;
   C1_DDR2_TWR              : integer;
   C1_DDR2_TWTR             : integer;
   C1_DDR2_HIGH_PERFORMANCE_MODE  : boolean;
   C1_DDR2_SIM_ONLY         : integer;
   C1_DDR2_DEBUG_EN         : integer
      );

    port (
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
   f0_rst0_tb               : out   std_logic;
   f0_ddr2_clk0_tb               : out   std_logic;
   c0_app_wdf_afull      : out   std_logic;
   c0_app_af_afull       : out   std_logic;
   c0_rd_data_valid      : out   std_logic;
   c0_app_wdf_wren       : in    std_logic;
   c0_app_af_wren        : in    std_logic;
   c0_app_af_addr        : in    std_logic_vector(30 downto 0);
   c0_app_af_cmd         : in    std_logic_vector(2 downto 0);
   c0_rd_data_fifo_out   : out   std_logic_vector((C0_DDR2_APPDATA_WIDTH-1) downto 0);
   c0_app_wdf_data       : in    std_logic_vector((C0_DDR2_APPDATA_WIDTH-1) downto 0);
   c0_app_wdf_mask_data   : in    std_logic_vector((C0_DDR2_APPDATA_WIDTH/8-1) downto 0);
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
   c1_app_wdf_afull      : out   std_logic;
   c1_app_af_afull       : out   std_logic;
   c1_rd_data_valid      : out   std_logic;
   c1_app_wdf_wren       : in    std_logic;
   c1_app_af_wren        : in    std_logic;
   c1_app_af_addr        : in    std_logic_vector(30 downto 0);
   c1_app_af_cmd         : in    std_logic_vector(2 downto 0);
   c1_rd_data_fifo_out   : out   std_logic_vector((C1_DDR2_APPDATA_WIDTH-1) downto 0);
   c1_app_wdf_data       : in    std_logic_vector((C1_DDR2_APPDATA_WIDTH-1) downto 0);
   c1_app_wdf_mask_data   : in    std_logic_vector((C1_DDR2_APPDATA_WIDTH/8-1) downto 0);
   c1_ddr2_dqs           : inout  std_logic_vector((C1_DDR2_DQS_WIDTH-1) downto 0);
   c1_ddr2_dqs_n         : inout  std_logic_vector((C1_DDR2_DQS_WIDTH-1) downto 0);
   c1_ddr2_ck            : out   std_logic_vector((C1_DDR2_CLK_WIDTH-1) downto 0);
   c1_ddr2_ck_n          : out   std_logic_vector((C1_DDR2_CLK_WIDTH-1) downto 0)

      );
  end component;

   component ddr2_model_c0 is
     port (
      ck        : in    std_logic;
      ck_n      : in    std_logic;
      cke       : in    std_logic;
      cs_n      : in    std_logic;
      ras_n     : in    std_logic;
      cas_n     : in    std_logic;
      we_n      : in    std_logic;
      dm_rdqs   : inout    std_logic_vector((C0_DDR2_DEVICE_WIDTH/16) downto 0);
      ba        : in    std_logic_vector((C0_DDR2_BANK_WIDTH-1) downto 0);
      addr      : in    std_logic_vector((C0_DDR2_ROW_WIDTH-1) downto 0);
      dq        : inout    std_logic_vector((C0_DDR2_DEVICE_WIDTH-1) downto 0);
      dqs       : inout    std_logic_vector((C0_DDR2_DEVICE_WIDTH/16) downto 0);
      dqs_n     : inout    std_logic_vector((C0_DDR2_DEVICE_WIDTH/16) downto 0);
      rdqs_n    : out    std_logic_vector((C0_DDR2_DEVICE_WIDTH/16) downto 0);
      odt       : in    std_logic

      );
  end component;

   component ddr2_model_c1 is
     port (
      ck        : in    std_logic;
      ck_n      : in    std_logic;
      cke       : in    std_logic;
      cs_n      : in    std_logic;
      ras_n     : in    std_logic;
      cas_n     : in    std_logic;
      we_n      : in    std_logic;
      dm_rdqs   : inout    std_logic_vector((C1_DDR2_DEVICE_WIDTH/16) downto 0);
      ba        : in    std_logic_vector((C1_DDR2_BANK_WIDTH-1) downto 0);
      addr      : in    std_logic_vector((C1_DDR2_ROW_WIDTH-1) downto 0);
      dq        : inout    std_logic_vector((C1_DDR2_DEVICE_WIDTH-1) downto 0);
      dqs       : inout    std_logic_vector((C1_DDR2_DEVICE_WIDTH/16) downto 0);
      dqs_n     : inout    std_logic_vector((C1_DDR2_DEVICE_WIDTH/16) downto 0);
      rdqs_n    : out    std_logic_vector((C1_DDR2_DEVICE_WIDTH/16) downto 0);
      odt       : in    std_logic

      );
  end component;


  component WireDelay
    generic (
      Delay_g : time;
      Delay_rd : time);
    port (
      A : inout Std_Logic;
      B : inout Std_Logic;
     reset : in Std_Logic);
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


  signal ddr2_sys_clk_f0    : std_logic := '0';
  signal ddr2_sys_clk_f0_p  : std_logic;
  signal ddr2_sys_clk_f0_n  : std_logic;
  signal sys_clk200               : std_logic:= '0';
  signal clk200_n                 : std_logic;
  signal clk200_p                 : std_logic;
  signal sys_rst_n                : std_logic := '0';
  signal sys_rst_out              : std_logic;
  signal gnd                      : std_logic_vector(1 downto 0);
  signal phy_init_done            : std_logic;
  signal error                    : std_logic;

   signal c0_ddr2_dq_sdram       : std_logic_vector((C0_DDR2_DQ_WIDTH - 1) downto 0);
   signal c0_ddr2_dq_fpga        : std_logic_vector((C0_DDR2_DQ_WIDTH - 1) downto 0);
   signal c0_ddr2_dqs_sdram      : std_logic_vector((C0_DDR2_DQS_WIDTH - 1) downto 0);
   signal c0_ddr2_dqs_fpga       : std_logic_vector((C0_DDR2_DQS_WIDTH - 1) downto 0);
   signal c0_ddr2_dqs_n_sdram    : std_logic_vector((C0_DDR2_DQS_WIDTH - 1) downto 0);
   signal c0_ddr2_dqs_n_fpga     : std_logic_vector((C0_DDR2_DQS_WIDTH - 1) downto 0);
   signal c0_ddr2_dm_sdram       : std_logic_vector((C0_DDR2_DM_WIDTH - 1) downto 0);
   signal c0_ddr2_dm_fpga        : std_logic_vector((C0_DDR2_DM_WIDTH - 1) downto 0);
   signal c0_ddr2_clk_sdram      : std_logic_vector((C0_DDR2_CLK_WIDTH - 1) downto 0);
   signal c0_ddr2_clk_fpga       : std_logic_vector((C0_DDR2_CLK_WIDTH - 1) downto 0);
   signal c0_ddr2_clk_n_sdram    : std_logic_vector((C0_DDR2_CLK_WIDTH - 1) downto 0);
   signal c0_ddr2_clk_n_fpga     : std_logic_vector((C0_DDR2_CLK_WIDTH - 1) downto 0);
   signal c0_ddr2_address_sdram   : std_logic_vector((C0_DDR2_ROW_WIDTH - 1) downto 0);
   signal c0_ddr2_address_fpga   : std_logic_vector((C0_DDR2_ROW_WIDTH - 1) downto 0);
   signal c0_ddr2_ba_sdram       : std_logic_vector((C0_DDR2_BANK_WIDTH - 1) downto 0);
   signal c0_ddr2_ba_fpga        : std_logic_vector((C0_DDR2_BANK_WIDTH - 1) downto 0);
   signal c0_ddr2_ras_n_sdram    : std_logic;
   signal c0_ddr2_ras_n_fpga     : std_logic;
   signal c0_ddr2_cas_n_sdram    : std_logic;
   signal c0_ddr2_cas_n_fpga     : std_logic;
   signal c0_ddr2_we_n_sdram     : std_logic;
   signal c0_ddr2_we_n_fpga      : std_logic;
   signal c0_ddr2_cs_n_sdram     : std_logic_vector((C0_DDR2_CS_WIDTH - 1) downto 0);
   signal c0_ddr2_cs_n_fpga      : std_logic_vector((C0_DDR2_CS_WIDTH - 1) downto 0);
   signal c0_ddr2_cke_sdram      : std_logic_vector((C0_DDR2_CKE_WIDTH - 1) downto 0);
   signal c0_ddr2_cke_fpga       : std_logic_vector((C0_DDR2_CKE_WIDTH - 1) downto 0);
   signal c0_ddr2_odt_sdram      : std_logic_vector((C0_DDR2_ODT_WIDTH - 1) downto 0);
   signal c0_ddr2_odt_fpga       : std_logic_vector((C0_DDR2_ODT_WIDTH - 1) downto 0);
   signal c0_error               : std_logic;
   signal c0_phy_init_done       : std_logic;
   signal c0_command             : std_logic_vector(2 downto 0);
   signal c0_enable              : std_logic;
   signal c0_enable_o            : std_logic;
   signal c0_dq_vector           : std_logic_vector(15 downto 0);
   signal c0_dqs_vector          : std_logic_vector(1 downto 0);
   signal c0_dqs_n_vector        : std_logic_vector(1 downto 0);
   signal c0_dm_vector           : std_logic_vector(1 downto 0);
   signal c1_ddr2_dq_sdram       : std_logic_vector((C1_DDR2_DQ_WIDTH - 1) downto 0);
   signal c1_ddr2_dq_fpga        : std_logic_vector((C1_DDR2_DQ_WIDTH - 1) downto 0);
   signal c1_ddr2_dqs_sdram      : std_logic_vector((C1_DDR2_DQS_WIDTH - 1) downto 0);
   signal c1_ddr2_dqs_fpga       : std_logic_vector((C1_DDR2_DQS_WIDTH - 1) downto 0);
   signal c1_ddr2_dqs_n_sdram    : std_logic_vector((C1_DDR2_DQS_WIDTH - 1) downto 0);
   signal c1_ddr2_dqs_n_fpga     : std_logic_vector((C1_DDR2_DQS_WIDTH - 1) downto 0);
   signal c1_ddr2_dm_sdram       : std_logic_vector((C1_DDR2_DM_WIDTH - 1) downto 0);
   signal c1_ddr2_dm_fpga        : std_logic_vector((C1_DDR2_DM_WIDTH - 1) downto 0);
   signal c1_ddr2_clk_sdram      : std_logic_vector((C1_DDR2_CLK_WIDTH - 1) downto 0);
   signal c1_ddr2_clk_fpga       : std_logic_vector((C1_DDR2_CLK_WIDTH - 1) downto 0);
   signal c1_ddr2_clk_n_sdram    : std_logic_vector((C1_DDR2_CLK_WIDTH - 1) downto 0);
   signal c1_ddr2_clk_n_fpga     : std_logic_vector((C1_DDR2_CLK_WIDTH - 1) downto 0);
   signal c1_ddr2_address_sdram   : std_logic_vector((C1_DDR2_ROW_WIDTH - 1) downto 0);
   signal c1_ddr2_address_fpga   : std_logic_vector((C1_DDR2_ROW_WIDTH - 1) downto 0);
   signal c1_ddr2_ba_sdram       : std_logic_vector((C1_DDR2_BANK_WIDTH - 1) downto 0);
   signal c1_ddr2_ba_fpga        : std_logic_vector((C1_DDR2_BANK_WIDTH - 1) downto 0);
   signal c1_ddr2_ras_n_sdram    : std_logic;
   signal c1_ddr2_ras_n_fpga     : std_logic;
   signal c1_ddr2_cas_n_sdram    : std_logic;
   signal c1_ddr2_cas_n_fpga     : std_logic;
   signal c1_ddr2_we_n_sdram     : std_logic;
   signal c1_ddr2_we_n_fpga      : std_logic;
   signal c1_ddr2_cs_n_sdram     : std_logic_vector((C1_DDR2_CS_WIDTH - 1) downto 0);
   signal c1_ddr2_cs_n_fpga      : std_logic_vector((C1_DDR2_CS_WIDTH - 1) downto 0);
   signal c1_ddr2_cke_sdram      : std_logic_vector((C1_DDR2_CKE_WIDTH - 1) downto 0);
   signal c1_ddr2_cke_fpga       : std_logic_vector((C1_DDR2_CKE_WIDTH - 1) downto 0);
   signal c1_ddr2_odt_sdram      : std_logic_vector((C1_DDR2_ODT_WIDTH - 1) downto 0);
   signal c1_ddr2_odt_fpga       : std_logic_vector((C1_DDR2_ODT_WIDTH - 1) downto 0);
   signal c1_error               : std_logic;
   signal c1_phy_init_done       : std_logic;
   signal c1_command             : std_logic_vector(2 downto 0);
   signal c1_enable              : std_logic;
   signal c1_enable_o            : std_logic;
   signal c1_dq_vector           : std_logic_vector(15 downto 0);
   signal c1_dqs_vector          : std_logic_vector(1 downto 0);
   signal c1_dqs_n_vector        : std_logic_vector(1 downto 0);
   signal c1_dm_vector           : std_logic_vector(1 downto 0);

  signal f0_ddr2_clk0_tb            : std_logic;
  signal f0_rst0_tb            : std_logic;

  signal c0_app_af_afull       : std_logic;
  signal c0_app_wdf_afull      : std_logic;
  signal c0_rd_data_valid      : std_logic;
  signal c0_rd_data_fifo_out   : std_logic_vector(C0_DDR2_APPDATA_WIDTH-1 downto 0);
  signal c0_app_af_wren        : std_logic;
  signal c0_app_af_cmd         : std_logic_vector(2 downto 0);
  signal c0_app_af_addr        : std_logic_vector(30 downto 0);
  signal c0_app_wdf_wren       : std_logic;
  signal c0_app_wdf_data       : std_logic_vector(C0_DDR2_APPDATA_WIDTH-1 downto 0);
  signal c0_app_wdf_mask_data  : std_logic_vector((C0_DDR2_APPDATA_WIDTH/8)-1 downto 0);

  signal c1_app_af_afull       : std_logic;
  signal c1_app_wdf_afull      : std_logic;
  signal c1_rd_data_valid      : std_logic;
  signal c1_rd_data_fifo_out   : std_logic_vector(C1_DDR2_APPDATA_WIDTH-1 downto 0);
  signal c1_app_af_wren        : std_logic;
  signal c1_app_af_cmd         : std_logic_vector(2 downto 0);
  signal c1_app_af_addr        : std_logic_vector(30 downto 0);
  signal c1_app_wdf_wren       : std_logic;
  signal c1_app_wdf_data       : std_logic_vector(C1_DDR2_APPDATA_WIDTH-1 downto 0);
  signal c1_app_wdf_mask_data  : std_logic_vector((C1_DDR2_APPDATA_WIDTH/8)-1 downto 0);





begin

  gnd <= "00";
   --***************************************************************************
   -- Clock generation and reset
   --***************************************************************************
 
  -- Generate design clock
  ddr2_sys_clk_f0 <= not ddr2_sys_clk_f0 after F0_TCYC_SYS_DIV2;

  ddr2_sys_clk_f0_p <= ddr2_sys_clk_f0;
  ddr2_sys_clk_f0_n <= not ddr2_sys_clk_f0;

   process
   begin
     sys_clk200 <= not sys_clk200;
     wait for (TCYC_200);
   end process;

   clk200_p <= sys_clk200;
   clk200_n <= not sys_clk200;

   process
   begin
      sys_rst_n <= '0';
      wait for 200 ns;
      sys_rst_n <= '1';
      wait;
   end process;

  -- Polarity of the reset for the memory controller instantiated can be changed
  -- by changing the parameter RST_ACT_LOW value
  sys_rst_out <= (sys_rst_n) when (RST_ACT_LOW = 1) else (not sys_rst_n);

  phy_init_done <= c0_phy_init_done and c1_phy_init_done;
  error         <= c0_error or c1_error;




   --***************************************************************************
   -- FPGA memory controller
   --***************************************************************************

  u_mem_controller : ddr2_16bx2_mig361
    generic map (
   C0_DDR2_BANK_WIDTH        => C0_DDR2_BANK_WIDTH,
   C0_DDR2_CKE_WIDTH         => C0_DDR2_CKE_WIDTH,
   C0_DDR2_CLK_WIDTH         => C0_DDR2_CLK_WIDTH,
   C0_DDR2_COL_WIDTH         => C0_DDR2_COL_WIDTH,
   C0_DDR2_CS_NUM            => C0_DDR2_CS_NUM,
   C0_DDR2_CS_WIDTH          => C0_DDR2_CS_WIDTH,
   C0_DDR2_CS_BITS           => C0_DDR2_CS_BITS,
   C0_DDR2_DM_WIDTH          => C0_DDR2_DM_WIDTH,
   C0_DDR2_DQ_WIDTH          => C0_DDR2_DQ_WIDTH,
   C0_DDR2_DQ_PER_DQS        => C0_DDR2_DQ_PER_DQS,
   C0_DDR2_DQS_WIDTH         => C0_DDR2_DQS_WIDTH,
   C0_DDR2_DQ_BITS           => C0_DDR2_DQ_BITS,
   C0_DDR2_DQS_BITS          => C0_DDR2_DQS_BITS,
   C0_DDR2_ODT_WIDTH         => C0_DDR2_ODT_WIDTH,
   C0_DDR2_ROW_WIDTH         => C0_DDR2_ROW_WIDTH,
   C0_DDR2_ADDITIVE_LAT      => C0_DDR2_ADDITIVE_LAT,
   C0_DDR2_BURST_LEN         => C0_DDR2_BURST_LEN,
   C0_DDR2_BURST_TYPE        => C0_DDR2_BURST_TYPE,
   C0_DDR2_CAS_LAT           => C0_DDR2_CAS_LAT,
   C0_DDR2_ECC_ENABLE        => C0_DDR2_ECC_ENABLE,
   C0_DDR2_APPDATA_WIDTH     => C0_DDR2_APPDATA_WIDTH,
   C0_DDR2_MULTI_BANK_EN     => C0_DDR2_MULTI_BANK_EN,
   C0_DDR2_TWO_T_TIME_EN     => C0_DDR2_TWO_T_TIME_EN,
   C0_DDR2_ODT_TYPE          => C0_DDR2_ODT_TYPE,
   C0_DDR2_REDUCE_DRV        => C0_DDR2_REDUCE_DRV,
   C0_DDR2_REG_ENABLE        => C0_DDR2_REG_ENABLE,
   C0_DDR2_TREFI_NS          => C0_DDR2_TREFI_NS,
   C0_DDR2_TRAS              => C0_DDR2_TRAS,
   C0_DDR2_TRCD              => C0_DDR2_TRCD,
   C0_DDR2_TRFC              => C0_DDR2_TRFC,
   C0_DDR2_TRP               => C0_DDR2_TRP,
   C0_DDR2_TRTP              => C0_DDR2_TRTP,
   C0_DDR2_TWR               => C0_DDR2_TWR,
   C0_DDR2_TWTR              => C0_DDR2_TWTR,
   C0_DDR2_HIGH_PERFORMANCE_MODE   => C0_DDR2_HIGH_PERFORMANCE_MODE,
   C0_DDR2_SIM_ONLY          => C0_DDR2_SIM_ONLY,
   C0_DDR2_DEBUG_EN          => C0_DDR2_DEBUG_EN,
   F0_DDR2_CLK_PERIOD        => F0_DDR2_CLK_PERIOD,
   F0_DDR2_DLL_FREQ_MODE     => F0_DDR2_DLL_FREQ_MODE,
   CLK_TYPE                  => CLK_TYPE,
   F0_DDR2_NOCLK200          => F0_DDR2_NOCLK200,
   RST_ACT_LOW               => RST_ACT_LOW,
   C1_DDR2_BANK_WIDTH        => C1_DDR2_BANK_WIDTH,
   C1_DDR2_CKE_WIDTH         => C1_DDR2_CKE_WIDTH,
   C1_DDR2_CLK_WIDTH         => C1_DDR2_CLK_WIDTH,
   C1_DDR2_COL_WIDTH         => C1_DDR2_COL_WIDTH,
   C1_DDR2_CS_NUM            => C1_DDR2_CS_NUM,
   C1_DDR2_CS_WIDTH          => C1_DDR2_CS_WIDTH,
   C1_DDR2_CS_BITS           => C1_DDR2_CS_BITS,
   C1_DDR2_DM_WIDTH          => C1_DDR2_DM_WIDTH,
   C1_DDR2_DQ_WIDTH          => C1_DDR2_DQ_WIDTH,
   C1_DDR2_DQ_PER_DQS        => C1_DDR2_DQ_PER_DQS,
   C1_DDR2_DQS_WIDTH         => C1_DDR2_DQS_WIDTH,
   C1_DDR2_DQ_BITS           => C1_DDR2_DQ_BITS,
   C1_DDR2_DQS_BITS          => C1_DDR2_DQS_BITS,
   C1_DDR2_ODT_WIDTH         => C1_DDR2_ODT_WIDTH,
   C1_DDR2_ROW_WIDTH         => C1_DDR2_ROW_WIDTH,
   C1_DDR2_ADDITIVE_LAT      => C1_DDR2_ADDITIVE_LAT,
   C1_DDR2_BURST_LEN         => C1_DDR2_BURST_LEN,
   C1_DDR2_BURST_TYPE        => C1_DDR2_BURST_TYPE,
   C1_DDR2_CAS_LAT           => C1_DDR2_CAS_LAT,
   C1_DDR2_ECC_ENABLE        => C1_DDR2_ECC_ENABLE,
   C1_DDR2_APPDATA_WIDTH     => C1_DDR2_APPDATA_WIDTH,
   C1_DDR2_MULTI_BANK_EN     => C1_DDR2_MULTI_BANK_EN,
   C1_DDR2_TWO_T_TIME_EN     => C1_DDR2_TWO_T_TIME_EN,
   C1_DDR2_ODT_TYPE          => C1_DDR2_ODT_TYPE,
   C1_DDR2_REDUCE_DRV        => C1_DDR2_REDUCE_DRV,
   C1_DDR2_REG_ENABLE        => C1_DDR2_REG_ENABLE,
   C1_DDR2_TREFI_NS          => C1_DDR2_TREFI_NS,
   C1_DDR2_TRAS              => C1_DDR2_TRAS,
   C1_DDR2_TRCD              => C1_DDR2_TRCD,
   C1_DDR2_TRFC              => C1_DDR2_TRFC,
   C1_DDR2_TRP               => C1_DDR2_TRP,
   C1_DDR2_TRTP              => C1_DDR2_TRTP,
   C1_DDR2_TWR               => C1_DDR2_TWR,
   C1_DDR2_TWTR              => C1_DDR2_TWTR,
   C1_DDR2_HIGH_PERFORMANCE_MODE   => C1_DDR2_HIGH_PERFORMANCE_MODE,
   C1_DDR2_SIM_ONLY          => C1_DDR2_SIM_ONLY,
   C1_DDR2_DEBUG_EN          => C1_DDR2_DEBUG_EN
    )
    port map (
   c0_ddr2_dq                 => c0_ddr2_dq_fpga,
   c0_ddr2_a                  => c0_ddr2_address_fpga,
   c0_ddr2_ba                 => c0_ddr2_ba_fpga,
   c0_ddr2_ras_n              => c0_ddr2_ras_n_fpga,
   c0_ddr2_cas_n              => c0_ddr2_cas_n_fpga,
   c0_ddr2_we_n               => c0_ddr2_we_n_fpga,
   c0_ddr2_cs_n               => c0_ddr2_cs_n_fpga,
   c0_ddr2_odt                => c0_ddr2_odt_fpga,
   c0_ddr2_cke                => c0_ddr2_cke_fpga,
   c0_ddr2_dm                 => c0_ddr2_dm_fpga,
   ddr2_sys_clk_f0   => ddr2_sys_clk_f0_p,
   idly_clk_200               => clk200_p,
   sys_rst_n                  => sys_rst_out,
   c0_phy_init_done           => c0_phy_init_done,
   f0_rst0_tb                 => f0_rst0_tb,
   f0_ddr2_clk0_tb            => f0_ddr2_clk0_tb,
   c0_app_wdf_afull           => c0_app_wdf_afull,
   c0_app_af_afull            => c0_app_af_afull,
   c0_rd_data_valid           => c0_rd_data_valid,
   c0_app_wdf_wren            => c0_app_wdf_wren,
   c0_app_af_wren             => c0_app_af_wren,
   c0_app_af_addr             => c0_app_af_addr,
   c0_app_af_cmd              => c0_app_af_cmd,
   c0_rd_data_fifo_out        => c0_rd_data_fifo_out,
   c0_app_wdf_data            => c0_app_wdf_data,
   c0_app_wdf_mask_data       => c0_app_wdf_mask_data,
   c0_ddr2_dqs                => c0_ddr2_dqs_fpga,
   c0_ddr2_dqs_n              => c0_ddr2_dqs_n_fpga,
   c0_ddr2_ck                 => c0_ddr2_clk_fpga,
   c0_ddr2_ck_n               => c0_ddr2_clk_n_fpga,
   c1_ddr2_dq                 => c1_ddr2_dq_fpga,
   c1_ddr2_a                  => c1_ddr2_address_fpga,
   c1_ddr2_ba                 => c1_ddr2_ba_fpga,
   c1_ddr2_ras_n              => c1_ddr2_ras_n_fpga,
   c1_ddr2_cas_n              => c1_ddr2_cas_n_fpga,
   c1_ddr2_we_n               => c1_ddr2_we_n_fpga,
   c1_ddr2_cs_n               => c1_ddr2_cs_n_fpga,
   c1_ddr2_odt                => c1_ddr2_odt_fpga,
   c1_ddr2_cke                => c1_ddr2_cke_fpga,
   c1_ddr2_dm                 => c1_ddr2_dm_fpga,
   c1_phy_init_done           => c1_phy_init_done,
   c1_app_wdf_afull           => c1_app_wdf_afull,
   c1_app_af_afull            => c1_app_af_afull,
   c1_rd_data_valid           => c1_rd_data_valid,
   c1_app_wdf_wren            => c1_app_wdf_wren,
   c1_app_af_wren             => c1_app_af_wren,
   c1_app_af_addr             => c1_app_af_addr,
   c1_app_af_cmd              => c1_app_af_cmd,
   c1_rd_data_fifo_out        => c1_rd_data_fifo_out,
   c1_app_wdf_data            => c1_app_wdf_data,
   c1_app_wdf_mask_data       => c1_app_wdf_mask_data,
   c1_ddr2_dqs                => c1_ddr2_dqs_fpga,
   c1_ddr2_dqs_n              => c1_ddr2_dqs_n_fpga,
   c1_ddr2_ck                 => c1_ddr2_clk_fpga,
   c1_ddr2_ck_n               => c1_ddr2_clk_n_fpga
      );

  --***************************************************************************
  -- Delay insertion modules for each signal
  --***************************************************************************
  -- Use standard non-inertial (transport) delay mechanism for unidirectional
  -- signals from FPGA to SDRAM

   c0_ddr2_dm_sdram           <= TRANSPORT c0_ddr2_dm_fpga            after TPROP_PCB_CTRL;
   c0_ddr2_clk_sdram          <= TRANSPORT c0_ddr2_clk_fpga           after TPROP_PCB_CTRL;
   c0_ddr2_clk_n_sdram        <= TRANSPORT c0_ddr2_clk_n_fpga         after TPROP_PCB_CTRL;
   c0_ddr2_address_sdram      <= TRANSPORT c0_ddr2_address_fpga       after TPROP_PCB_CTRL;
   c0_ddr2_ba_sdram           <= TRANSPORT c0_ddr2_ba_fpga            after TPROP_PCB_CTRL;
   c0_ddr2_ras_n_sdram        <= TRANSPORT c0_ddr2_ras_n_fpga         after TPROP_PCB_CTRL;
   c0_ddr2_cas_n_sdram        <= TRANSPORT c0_ddr2_cas_n_fpga         after TPROP_PCB_CTRL;
   c0_ddr2_we_n_sdram         <= TRANSPORT c0_ddr2_we_n_fpga          after TPROP_PCB_CTRL;
   c0_ddr2_cs_n_sdram         <= TRANSPORT c0_ddr2_cs_n_fpga          after TPROP_PCB_CTRL;
   c0_ddr2_cke_sdram          <= TRANSPORT c0_ddr2_cke_fpga           after TPROP_PCB_CTRL;
   c0_ddr2_odt_sdram          <= TRANSPORT c0_ddr2_odt_fpga           after TPROP_PCB_CTRL;
   c1_ddr2_dm_sdram           <= TRANSPORT c1_ddr2_dm_fpga            after TPROP_PCB_CTRL;
   c1_ddr2_clk_sdram          <= TRANSPORT c1_ddr2_clk_fpga           after TPROP_PCB_CTRL;
   c1_ddr2_clk_n_sdram        <= TRANSPORT c1_ddr2_clk_n_fpga         after TPROP_PCB_CTRL;
   c1_ddr2_address_sdram      <= TRANSPORT c1_ddr2_address_fpga       after TPROP_PCB_CTRL;
   c1_ddr2_ba_sdram           <= TRANSPORT c1_ddr2_ba_fpga            after TPROP_PCB_CTRL;
   c1_ddr2_ras_n_sdram        <= TRANSPORT c1_ddr2_ras_n_fpga         after TPROP_PCB_CTRL;
   c1_ddr2_cas_n_sdram        <= TRANSPORT c1_ddr2_cas_n_fpga         after TPROP_PCB_CTRL;
   c1_ddr2_we_n_sdram         <= TRANSPORT c1_ddr2_we_n_fpga          after TPROP_PCB_CTRL;
   c1_ddr2_cs_n_sdram         <= TRANSPORT c1_ddr2_cs_n_fpga          after TPROP_PCB_CTRL;
   c1_ddr2_cke_sdram          <= TRANSPORT c1_ddr2_cke_fpga           after TPROP_PCB_CTRL;
   c1_ddr2_odt_sdram          <= TRANSPORT c1_ddr2_odt_fpga           after TPROP_PCB_CTRL;


  dq_delay0: for i0 in 0 to C0_DDR2_DQ_WIDTH - 1 generate
    u_delay_dq0: WireDelay
      generic map (
        Delay_g => TPROP_PCB_DATA,
        Delay_rd => TPROP_PCB_DATA_RD)
      port map(
        A => c0_ddr2_dq_fpga(i0),
        B => c0_ddr2_dq_sdram(i0),
        reset => sys_rst_n);
  end generate;

  dqs_delay0: for i0 in 0 to C0_DDR2_DQS_WIDTH - 1 generate
    u_delay_dqs0: WireDelay
      generic map (
        Delay_g => TPROP_DQS,
        Delay_rd => TPROP_DQS_RD)
      port map(
        A => c0_ddr2_dqs_fpga(i0),
        B => c0_ddr2_dqs_sdram(i0),
        reset => sys_rst_n);
  end generate;

  dqs_n_delay0: for i0 in 0 to C0_DDR2_DQS_WIDTH - 1 generate
    u_delay_dqs0: WireDelay
      generic map (
        Delay_g => TPROP_DQS,
        Delay_rd => TPROP_DQS_RD)
      port map(
        A => c0_ddr2_dqs_n_fpga(i0),
        B => c0_ddr2_dqs_n_sdram(i0),
        reset => sys_rst_n);
  end generate;

  dq_delay1: for i1 in 0 to C1_DDR2_DQ_WIDTH - 1 generate
    u_delay_dq1: WireDelay
      generic map (
        Delay_g => TPROP_PCB_DATA,
        Delay_rd => TPROP_PCB_DATA_RD)
      port map(
        A => c1_ddr2_dq_fpga(i1),
        B => c1_ddr2_dq_sdram(i1),
        reset => sys_rst_n);
  end generate;

  dqs_delay1: for i1 in 0 to C1_DDR2_DQS_WIDTH - 1 generate
    u_delay_dqs1: WireDelay
      generic map (
        Delay_g => TPROP_DQS,
        Delay_rd => TPROP_DQS_RD)
      port map(
        A => c1_ddr2_dqs_fpga(i1),
        B => c1_ddr2_dqs_sdram(i1),
        reset => sys_rst_n);
  end generate;

  dqs_n_delay1: for i1 in 0 to C1_DDR2_DQS_WIDTH - 1 generate
    u_delay_dqs1: WireDelay
      generic map (
        Delay_g => TPROP_DQS,
        Delay_rd => TPROP_DQS_RD)
      port map(
        A => c1_ddr2_dqs_n_fpga(i1),
        B => c1_ddr2_dqs_n_sdram(i1),
        reset => sys_rst_n);
  end generate;










  --***************************************************************************
  -- Memory model instances
  --***************************************************************************

      INST_C0: for j0 in 0 to (C0_DDR2_CS_NUM - 1) generate
        gen_c0: for i0 in 0 to (C0_DDR2_DQS_WIDTH/2 - 1) generate
        DDR2_MEM_C0: ddr2_model_c0
          port map (
            ck         => c0_ddr2_clk_sdram(i0),
            ck_n       => c0_ddr2_clk_n_sdram(i0),
            cke        => c0_ddr2_cke_sdram(j0),
            cs_n       => c0_ddr2_cs_n_sdram(i0),
            ras_n      => c0_ddr2_ras_n_sdram,
            cas_n      => c0_ddr2_cas_n_sdram,
            we_n       => c0_ddr2_we_n_sdram,
            dm_rdqs    => c0_ddr2_dm_sdram((2*(i0+1))-1 downto i0*2),
            ba         => c0_ddr2_ba_sdram,
            addr       => c0_ddr2_address_sdram,
            dq         => c0_ddr2_dq_sdram((16*(i0+1))-1 downto i0*16),
            dqs        => c0_ddr2_dqs_sdram((2*(i0+1))-1 downto i0*2),
            dqs_n      => c0_ddr2_dqs_n_sdram((2*(i0+1))-1 downto i0*2),
            rdqs_n     => open,
            odt        => c0_ddr2_odt_sdram(i0)
            );
            end generate gen_c0;
      end generate INST_C0;

      INST_C1: for j1 in 0 to (C1_DDR2_CS_NUM - 1) generate
        gen_c1: for i1 in 0 to (C1_DDR2_DQS_WIDTH/2 - 1) generate
        DDR2_MEM_C1: ddr2_model_c1
          port map (
            ck         => c1_ddr2_clk_sdram(i1),
            ck_n       => c1_ddr2_clk_n_sdram(i1),
            cke        => c1_ddr2_cke_sdram(j1),
            cs_n       => c1_ddr2_cs_n_sdram(i1),
            ras_n      => c1_ddr2_ras_n_sdram,
            cas_n      => c1_ddr2_cas_n_sdram,
            we_n       => c1_ddr2_we_n_sdram,
            dm_rdqs    => c1_ddr2_dm_sdram((2*(i1+1))-1 downto i1*2),
            ba         => c1_ddr2_ba_sdram,
            addr       => c1_ddr2_address_sdram,
            dq         => c1_ddr2_dq_sdram((16*(i1+1))-1 downto i1*16),
            dqs        => c1_ddr2_dqs_sdram((2*(i1+1))-1 downto i1*2),
            dqs_n      => c1_ddr2_dqs_n_sdram((2*(i1+1))-1 downto i1*2),
            rdqs_n     => open,
            odt        => c1_ddr2_odt_sdram(i1)
            );
            end generate gen_c1;
      end generate INST_C1;


  u_tb_top_0 : ddr2_tb_top
    generic map (
      BANK_WIDTH    => C0_DDR2_BANK_WIDTH,
      COL_WIDTH     => C0_DDR2_COL_WIDTH,
      DM_WIDTH      => C0_DDR2_DM_WIDTH,
      DQ_WIDTH      => C0_DDR2_DQ_WIDTH,
      ROW_WIDTH     => C0_DDR2_ROW_WIDTH,
      APPDATA_WIDTH => C0_DDR2_APPDATA_WIDTH,
      ECC_ENABLE    => C0_DDR2_ECC_ENABLE,
      BURST_LEN     => C0_DDR2_BURST_LEN
      )
    port map (
      clk0              => f0_ddr2_clk0_tb,
      rst0              => f0_rst0_tb,
      app_af_afull      => c0_app_af_afull,
      app_wdf_afull     => c0_app_wdf_afull,
      rd_data_valid     => c0_rd_data_valid,
      rd_data_fifo_out  => c0_rd_data_fifo_out,
      phy_init_done     => c0_phy_init_done,
      app_af_wren       => c0_app_af_wren,
      app_af_cmd        => c0_app_af_cmd,
      app_af_addr       => c0_app_af_addr,
      app_wdf_wren      => c0_app_wdf_wren,
      app_wdf_data      => c0_app_wdf_data,
      app_wdf_mask_data => c0_app_wdf_mask_data,
      error             => c0_error
      );
  u_tb_top_1 : ddr2_tb_top
    generic map (
      BANK_WIDTH    => C1_DDR2_BANK_WIDTH,
      COL_WIDTH     => C1_DDR2_COL_WIDTH,
      DM_WIDTH      => C1_DDR2_DM_WIDTH,
      DQ_WIDTH      => C1_DDR2_DQ_WIDTH,
      ROW_WIDTH     => C1_DDR2_ROW_WIDTH,
      APPDATA_WIDTH => C1_DDR2_APPDATA_WIDTH,
      ECC_ENABLE    => C1_DDR2_ECC_ENABLE,
      BURST_LEN     => C1_DDR2_BURST_LEN
      )
    port map (
      clk0              => f0_ddr2_clk0_tb,
      rst0              => f0_rst0_tb,
      app_af_afull      => c1_app_af_afull,
      app_wdf_afull     => c1_app_wdf_afull,
      rd_data_valid     => c1_rd_data_valid,
      rd_data_fifo_out  => c1_rd_data_fifo_out,
      phy_init_done     => c1_phy_init_done,
      app_af_wren       => c1_app_af_wren,
      app_af_cmd        => c1_app_af_cmd,
      app_af_addr       => c1_app_af_addr,
      app_wdf_wren      => c1_app_wdf_wren,
      app_wdf_data      => c1_app_wdf_data,
      app_wdf_mask_data => c1_app_wdf_mask_data,
      error             => c1_error
      );

end architecture;
