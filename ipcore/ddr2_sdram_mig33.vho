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
-- \   \   \/    Version            : 3.3
--  \   \        Application        : MIG
--  /   /        Filename           : ddr2_sdram_mig33.vho
-- /___/   /\    Date Last Modified : $Date: 2009/08/17 16:10:43 $
-- \   \  /  \   Date Created       : Wed May 2 2007
--  \___\/\___\
--
-- Purpose     : Template file containing code that can be used as a model
--               for instantiating a CORE Generator module in a HDL design.
-- Revision History:
--*****************************************************************************

-- The following code must appear in the VHDL architecture header:

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG

component ddr2_sdram_mig33
 generic(
     BANK_WIDTH               : integer := 3;    
                              -- # of memory bank addr bits.
     CKE_WIDTH                : integer := 1;    
                              -- # of memory clock enable outputs.
     CLK_WIDTH                : integer := 2;    
                              -- # of clock outputs.
     COL_WIDTH                : integer := 10;    
                              -- # of memory column bits.
     CS_NUM                   : integer := 1;    
                              -- # of separate memory chip selects.
     CS_WIDTH                 : integer := 2;    
                              -- # of total memory chip selects.
     CS_BITS                  : integer := 0;    
                              -- set to log2(CS_NUM) (rounded up).
     DM_WIDTH                 : integer := 4;    
                              -- # of data mask bits.
     DQ_WIDTH                 : integer := 32;    
                              -- # of data width.
     DQ_PER_DQS               : integer := 8;    
                              -- # of DQ data bits per strobe.
     DQS_WIDTH                : integer := 4;    
                              -- # of DQS strobes.
     DQ_BITS                  : integer := 5;    
                              -- set to log2(DQS_WIDTH*DQ_PER_DQS).
     DQS_BITS                 : integer := 2;    
                              -- set to log2(DQS_WIDTH).
     ODT_WIDTH                : integer := 2;    
                              -- # of memory on-die term enables.
     ROW_WIDTH                : integer := 14;    
                              -- # of memory row and # of addr bits.
     ADDITIVE_LAT             : integer := 0;    
                              -- additive write latency.
     BURST_LEN                : integer := 4;    
                              -- burst length (in double words).
     BURST_TYPE               : integer := 0;    
                              -- burst type (=0 seq; =1 interleaved).
     CAS_LAT                  : integer := 3;    
                              -- CAS latency.
     ECC_ENABLE               : integer := 0;    
                              -- enable ECC (=1 enable).
     APPDATA_WIDTH            : integer := 64;    
                              -- # of usr read/write data bus bits.
     MULTI_BANK_EN            : integer := 1;    
                              -- Keeps multiple banks open. (= 1 enable).
     TWO_T_TIME_EN            : integer := 0;    
                              -- 2t timing for unbuffered dimms.
     ODT_TYPE                 : integer := 3;    
                              -- ODT (=0(none),=1(75),=2(150),=3(50)).
     REDUCE_DRV               : integer := 0;    
                              -- reduced strength mem I/O (=1 yes).
     REG_ENABLE               : integer := 0;    
                              -- registered addr/ctrl (=1 yes).
     TREFI_NS                 : integer := 7800;    
                              -- auto refresh interval (ns).
     TRAS                     : integer := 40000;    
                              -- active->precharge delay.
     TRCD                     : integer := 15000;    
                              -- active->read/write delay.
     TRFC                     : integer := 197500;    
                              -- refresh->refresh, refresh->active delay.
     TRP                      : integer := 15000;    
                              -- precharge->command delay.
     TRTP                     : integer := 7500;    
                              -- read->precharge delay.
     TWR                      : integer := 15000;    
                              -- used to determine write->precharge.
     TWTR                     : integer := 7500;    
                              -- write->read delay.
     HIGH_PERFORMANCE_MODE    : boolean := TRUE;    
                              -- # = TRUE, the IODELAY performance mode is set
                              -- to high.
                              -- # = FALSE, the IODELAY performance mode is set
                              -- to low.
     SIM_ONLY                 : integer := 0;    
                              -- = 1 to skip SDRAM power up delay.
     DEBUG_EN                 : integer := 0;    
                              -- Enable debug signals/controls.
                              -- When this parameter is changed from 0 to 1,
                              -- make sure to uncomment the coregen commands
                              -- in ise_flow.bat or create_ise.bat files in
                              -- par folder.
     CLK_PERIOD               : integer := 5000;    
                              -- Core/Memory clock period (in ps).
     DLL_FREQ_MODE            : string := "HIGH";    
                              -- DCM Frequency range.
     CLK_TYPE                 : string := "SINGLE_ENDED";    
                              -- # = "DIFFERENTIAL " ->; Differential input clocks ,
                              -- # = "SINGLE_ENDED" -> Single ended input clocks.
     NOCLK200                 : boolean := FALSE;    
                              -- clk200 enable and disable
     RST_ACT_LOW              : integer := 1     
                              -- =1 for active low reset, =0 for active high.
);
    port (
   ddr2_dq               : inout  std_logic_vector((DQ_WIDTH-1) downto 0);
   ddr2_a                : out   std_logic_vector((ROW_WIDTH-1) downto 0);
   ddr2_ba               : out   std_logic_vector((BANK_WIDTH-1) downto 0);
   ddr2_ras_n            : out   std_logic;
   ddr2_cas_n            : out   std_logic;
   ddr2_we_n             : out   std_logic;
   ddr2_cs_n             : out   std_logic_vector((CS_WIDTH-1) downto 0);
   ddr2_odt              : out   std_logic_vector((ODT_WIDTH-1) downto 0);
   ddr2_cke              : out   std_logic_vector((CKE_WIDTH-1) downto 0);
   ddr2_dm               : out   std_logic_vector((DM_WIDTH-1) downto 0);
   sys_clk               : in    std_logic;
   idly_clk_200          : in    std_logic;
   sys_rst_n             : in    std_logic;
   phy_init_done         : out   std_logic;
   rst0_tb               : out   std_logic;
   clk0_tb               : out   std_logic;
   app_wdf_afull         : out   std_logic;
   app_af_afull          : out   std_logic;
   rd_data_valid         : out   std_logic;
   app_wdf_wren          : in    std_logic;
   app_af_wren           : in    std_logic;
   app_af_addr           : in    std_logic_vector(30 downto 0);
   app_af_cmd            : in    std_logic_vector(2 downto 0);
   rd_data_fifo_out      : out   std_logic_vector((APPDATA_WIDTH-1) downto 0);
   app_wdf_data          : in    std_logic_vector((APPDATA_WIDTH-1) downto 0);
   app_wdf_mask_data     : in    std_logic_vector((APPDATA_WIDTH/8-1) downto 0);
   ddr2_dqs              : inout  std_logic_vector((DQS_WIDTH-1) downto 0);
   ddr2_dqs_n            : inout  std_logic_vector((DQS_WIDTH-1) downto 0);
   ddr2_ck               : out   std_logic_vector((CLK_WIDTH-1) downto 0);
   ddr2_ck_n             : out   std_logic_vector((CLK_WIDTH-1) downto 0)
);
end component;

-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
  u_ddr2_sdram_mig33 : ddr2_sdram_mig33
    generic map (
     BANK_WIDTH => BANK_WIDTH,
     CKE_WIDTH => CKE_WIDTH,
     CLK_WIDTH => CLK_WIDTH,
     COL_WIDTH => COL_WIDTH,
     CS_NUM => CS_NUM,
     CS_WIDTH => CS_WIDTH,
     CS_BITS => CS_BITS,
     DM_WIDTH => DM_WIDTH,
     DQ_WIDTH => DQ_WIDTH,
     DQ_PER_DQS => DQ_PER_DQS,
     DQS_WIDTH => DQS_WIDTH,
     DQ_BITS => DQ_BITS,
     DQS_BITS => DQS_BITS,
     ODT_WIDTH => ODT_WIDTH,
     ROW_WIDTH => ROW_WIDTH,
     ADDITIVE_LAT => ADDITIVE_LAT,
     BURST_LEN => BURST_LEN,
     BURST_TYPE => BURST_TYPE,
     CAS_LAT => CAS_LAT,
     ECC_ENABLE => ECC_ENABLE,
     APPDATA_WIDTH => APPDATA_WIDTH,
     MULTI_BANK_EN => MULTI_BANK_EN,
     TWO_T_TIME_EN => TWO_T_TIME_EN,
     ODT_TYPE => ODT_TYPE,
     REDUCE_DRV => REDUCE_DRV,
     REG_ENABLE => REG_ENABLE,
     TREFI_NS => TREFI_NS,
     TRAS => TRAS,
     TRCD => TRCD,
     TRFC => TRFC,
     TRP => TRP,
     TRTP => TRTP,
     TWR => TWR,
     TWTR => TWTR,
     HIGH_PERFORMANCE_MODE => HIGH_PERFORMANCE_MODE,
     SIM_ONLY => SIM_ONLY,
     DEBUG_EN => DEBUG_EN,
     CLK_PERIOD => CLK_PERIOD,
     DLL_FREQ_MODE => DLL_FREQ_MODE,
     CLK_TYPE => CLK_TYPE,
     NOCLK200 => NOCLK200,
     RST_ACT_LOW => RST_ACT_LOW
)
    port map (
   ddr2_dq                    => ddr2_dq,
   ddr2_a                     => ddr2_a,
   ddr2_ba                    => ddr2_ba,
   ddr2_ras_n                 => ddr2_ras_n,
   ddr2_cas_n                 => ddr2_cas_n,
   ddr2_we_n                  => ddr2_we_n,
   ddr2_cs_n                  => ddr2_cs_n,
   ddr2_odt                   => ddr2_odt,
   ddr2_cke                   => ddr2_cke,
   ddr2_dm                    => ddr2_dm,
   sys_clk                    => sys_clk,
   idly_clk_200               => idly_clk_200,
   sys_rst_n                  => sys_rst_n,
   phy_init_done              => phy_init_done,
   rst0_tb                    => rst0_tb,
   clk0_tb                    => clk0_tb,
   app_wdf_afull              => app_wdf_afull,
   app_af_afull               => app_af_afull,
   rd_data_valid              => rd_data_valid,
   app_wdf_wren               => app_wdf_wren,
   app_af_wren                => app_af_wren,
   app_af_addr                => app_af_addr,
   app_af_cmd                 => app_af_cmd,
   rd_data_fifo_out           => rd_data_fifo_out,
   app_wdf_data               => app_wdf_data,
   app_wdf_mask_data          => app_wdf_mask_data,
   ddr2_dqs                   => ddr2_dqs,
   ddr2_dqs_n                 => ddr2_dqs_n,
   ddr2_ck                    => ddr2_ck,
   ddr2_ck_n                  => ddr2_ck_n
);

-- INST_TAG_END ------ End INSTANTIATION Template ------------

-- You must compile the wrapper file ddr2_sdram_mig33.vhd when simulating
-- the core, ddr2_sdram_mig33. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

