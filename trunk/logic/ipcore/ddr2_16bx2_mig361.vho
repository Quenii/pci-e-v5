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
-- \   \   \/    Version            : 3.6.1
--  \   \        Application        : MIG
--  /   /        Filename           : ddr2_16bx2_mig361.vho
-- /___/   /\    Date Last Modified : $Date: 2010/11/26 18:26:31 $
-- \   \  /  \   Date Created       : Wed May 2 2007
--  \___\/\___\
--
-- Purpose     : Template file containing code that can be used as a model
--               for instantiating a CORE Generator module in a HDL design.
-- Revision History:
--*****************************************************************************

-- The following code must appear in the VHDL architecture header:

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG

component ddr2_16bx2_mig361
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

-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
  u_ddr2_16bx2_mig361 : ddr2_16bx2_mig361
    generic map (
     C0_DDR2_BANK_WIDTH => C0_DDR2_BANK_WIDTH,
     C0_DDR2_CKE_WIDTH => C0_DDR2_CKE_WIDTH,
     C0_DDR2_CLK_WIDTH => C0_DDR2_CLK_WIDTH,
     C0_DDR2_COL_WIDTH => C0_DDR2_COL_WIDTH,
     C0_DDR2_CS_NUM => C0_DDR2_CS_NUM,
     C0_DDR2_CS_WIDTH => C0_DDR2_CS_WIDTH,
     C0_DDR2_CS_BITS => C0_DDR2_CS_BITS,
     C0_DDR2_DM_WIDTH => C0_DDR2_DM_WIDTH,
     C0_DDR2_DQ_WIDTH => C0_DDR2_DQ_WIDTH,
     C0_DDR2_DQ_PER_DQS => C0_DDR2_DQ_PER_DQS,
     C0_DDR2_DQS_WIDTH => C0_DDR2_DQS_WIDTH,
     C0_DDR2_DQ_BITS => C0_DDR2_DQ_BITS,
     C0_DDR2_DQS_BITS => C0_DDR2_DQS_BITS,
     C0_DDR2_ODT_WIDTH => C0_DDR2_ODT_WIDTH,
     C0_DDR2_ROW_WIDTH => C0_DDR2_ROW_WIDTH,
     C0_DDR2_ADDITIVE_LAT => C0_DDR2_ADDITIVE_LAT,
     C0_DDR2_BURST_LEN => C0_DDR2_BURST_LEN,
     C0_DDR2_BURST_TYPE => C0_DDR2_BURST_TYPE,
     C0_DDR2_CAS_LAT => C0_DDR2_CAS_LAT,
     C0_DDR2_ECC_ENABLE => C0_DDR2_ECC_ENABLE,
     C0_DDR2_APPDATA_WIDTH => C0_DDR2_APPDATA_WIDTH,
     C0_DDR2_MULTI_BANK_EN => C0_DDR2_MULTI_BANK_EN,
     C0_DDR2_TWO_T_TIME_EN => C0_DDR2_TWO_T_TIME_EN,
     C0_DDR2_ODT_TYPE => C0_DDR2_ODT_TYPE,
     C0_DDR2_REDUCE_DRV => C0_DDR2_REDUCE_DRV,
     C0_DDR2_REG_ENABLE => C0_DDR2_REG_ENABLE,
     C0_DDR2_TREFI_NS => C0_DDR2_TREFI_NS,
     C0_DDR2_TRAS => C0_DDR2_TRAS,
     C0_DDR2_TRCD => C0_DDR2_TRCD,
     C0_DDR2_TRFC => C0_DDR2_TRFC,
     C0_DDR2_TRP => C0_DDR2_TRP,
     C0_DDR2_TRTP => C0_DDR2_TRTP,
     C0_DDR2_TWR => C0_DDR2_TWR,
     C0_DDR2_TWTR => C0_DDR2_TWTR,
     C0_DDR2_HIGH_PERFORMANCE_MODE => C0_DDR2_HIGH_PERFORMANCE_MODE,
     C0_DDR2_SIM_ONLY => C0_DDR2_SIM_ONLY,
     C0_DDR2_DEBUG_EN => C0_DDR2_DEBUG_EN,
     F0_DDR2_CLK_PERIOD => F0_DDR2_CLK_PERIOD,
     F0_DDR2_DLL_FREQ_MODE => F0_DDR2_DLL_FREQ_MODE,
     CLK_TYPE => CLK_TYPE,
     F0_DDR2_NOCLK200 => F0_DDR2_NOCLK200,
     RST_ACT_LOW => RST_ACT_LOW,
     C1_DDR2_BANK_WIDTH => C1_DDR2_BANK_WIDTH,
     C1_DDR2_CKE_WIDTH => C1_DDR2_CKE_WIDTH,
     C1_DDR2_CLK_WIDTH => C1_DDR2_CLK_WIDTH,
     C1_DDR2_COL_WIDTH => C1_DDR2_COL_WIDTH,
     C1_DDR2_CS_NUM => C1_DDR2_CS_NUM,
     C1_DDR2_CS_WIDTH => C1_DDR2_CS_WIDTH,
     C1_DDR2_CS_BITS => C1_DDR2_CS_BITS,
     C1_DDR2_DM_WIDTH => C1_DDR2_DM_WIDTH,
     C1_DDR2_DQ_WIDTH => C1_DDR2_DQ_WIDTH,
     C1_DDR2_DQ_PER_DQS => C1_DDR2_DQ_PER_DQS,
     C1_DDR2_DQS_WIDTH => C1_DDR2_DQS_WIDTH,
     C1_DDR2_DQ_BITS => C1_DDR2_DQ_BITS,
     C1_DDR2_DQS_BITS => C1_DDR2_DQS_BITS,
     C1_DDR2_ODT_WIDTH => C1_DDR2_ODT_WIDTH,
     C1_DDR2_ROW_WIDTH => C1_DDR2_ROW_WIDTH,
     C1_DDR2_ADDITIVE_LAT => C1_DDR2_ADDITIVE_LAT,
     C1_DDR2_BURST_LEN => C1_DDR2_BURST_LEN,
     C1_DDR2_BURST_TYPE => C1_DDR2_BURST_TYPE,
     C1_DDR2_CAS_LAT => C1_DDR2_CAS_LAT,
     C1_DDR2_ECC_ENABLE => C1_DDR2_ECC_ENABLE,
     C1_DDR2_APPDATA_WIDTH => C1_DDR2_APPDATA_WIDTH,
     C1_DDR2_MULTI_BANK_EN => C1_DDR2_MULTI_BANK_EN,
     C1_DDR2_TWO_T_TIME_EN => C1_DDR2_TWO_T_TIME_EN,
     C1_DDR2_ODT_TYPE => C1_DDR2_ODT_TYPE,
     C1_DDR2_REDUCE_DRV => C1_DDR2_REDUCE_DRV,
     C1_DDR2_REG_ENABLE => C1_DDR2_REG_ENABLE,
     C1_DDR2_TREFI_NS => C1_DDR2_TREFI_NS,
     C1_DDR2_TRAS => C1_DDR2_TRAS,
     C1_DDR2_TRCD => C1_DDR2_TRCD,
     C1_DDR2_TRFC => C1_DDR2_TRFC,
     C1_DDR2_TRP => C1_DDR2_TRP,
     C1_DDR2_TRTP => C1_DDR2_TRTP,
     C1_DDR2_TWR => C1_DDR2_TWR,
     C1_DDR2_TWTR => C1_DDR2_TWTR,
     C1_DDR2_HIGH_PERFORMANCE_MODE => C1_DDR2_HIGH_PERFORMANCE_MODE,
     C1_DDR2_SIM_ONLY => C1_DDR2_SIM_ONLY,
     C1_DDR2_DEBUG_EN => C1_DDR2_DEBUG_EN
)
    port map (
   c0_ddr2_dq                 => c0_ddr2_dq,
   c0_ddr2_a                  => c0_ddr2_a,
   c0_ddr2_ba                 => c0_ddr2_ba,
   c0_ddr2_ras_n              => c0_ddr2_ras_n,
   c0_ddr2_cas_n              => c0_ddr2_cas_n,
   c0_ddr2_we_n               => c0_ddr2_we_n,
   c0_ddr2_cs_n               => c0_ddr2_cs_n,
   c0_ddr2_odt                => c0_ddr2_odt,
   c0_ddr2_cke                => c0_ddr2_cke,
   c0_ddr2_dm                 => c0_ddr2_dm,
   ddr2_sys_clk_f0            => ddr2_sys_clk_f0,
   idly_clk_200               => idly_clk_200,
   sys_rst_n                  => sys_rst_n,
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
   c0_ddr2_dqs                => c0_ddr2_dqs,
   c0_ddr2_dqs_n              => c0_ddr2_dqs_n,
   c0_ddr2_ck                 => c0_ddr2_ck,
   c0_ddr2_ck_n               => c0_ddr2_ck_n,
   c1_ddr2_dq                 => c1_ddr2_dq,
   c1_ddr2_a                  => c1_ddr2_a,
   c1_ddr2_ba                 => c1_ddr2_ba,
   c1_ddr2_ras_n              => c1_ddr2_ras_n,
   c1_ddr2_cas_n              => c1_ddr2_cas_n,
   c1_ddr2_we_n               => c1_ddr2_we_n,
   c1_ddr2_cs_n               => c1_ddr2_cs_n,
   c1_ddr2_odt                => c1_ddr2_odt,
   c1_ddr2_cke                => c1_ddr2_cke,
   c1_ddr2_dm                 => c1_ddr2_dm,
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
   c1_ddr2_dqs                => c1_ddr2_dqs,
   c1_ddr2_dqs_n              => c1_ddr2_dqs_n,
   c1_ddr2_ck                 => c1_ddr2_ck,
   c1_ddr2_ck_n               => c1_ddr2_ck_n
);

-- INST_TAG_END ------ End INSTANTIATION Template ------------

-- You must compile the wrapper file ddr2_16bx2_mig361.vhd when simulating
-- the core, ddr2_16bx2_mig361. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

