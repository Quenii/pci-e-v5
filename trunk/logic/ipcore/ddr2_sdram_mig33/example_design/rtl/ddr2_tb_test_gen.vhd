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
-- Copyright 2006, 2007 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: 3.3
--  \   \         Application: MIG
--  /   /         Filename: ddr2_tb_test_gen.vhd
-- /___/   /\     Date Last Modified: $Date: 2009/08/17 16:10:22 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR/DDR2
--Purpose:
--   This module instantiates the addr_gen and the data_gen modules. It takes
--   the user data stored in internal FIFOs and gives the data that is to be
--   compared with the read data
--Reference:
--Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity ddr2_tb_test_gen is
  generic (
    -- Following parameters are for 72-bit RDIMM design (for ML561 Reference 
    -- board design). Actual values may be different. Actual parameters values 
    -- are passed from design top module ddr2_sdram_mig33 module. Please refer to
    -- the ddr2_sdram_mig33 module for actual values.
    BANK_WIDTH          : integer := 2;
    COL_WIDTH           : integer := 10;
    DM_WIDTH            : integer := 9;
    DQ_WIDTH            : integer := 72;
    APPDATA_WIDTH       : integer := 144 ;
    ECC_ENABLE          : integer := 0;
    ROW_WIDTH           : integer := 14
  );
  port (
    clk               : in  std_logic;
    rst               : in  std_logic;
    wr_addr_en        : in  std_logic;
    wr_data_en        : in  std_logic;
    rd_data_valid     : in  std_logic;
    app_af_wren       : out std_logic;
    app_af_cmd        : out std_logic_vector(2 downto 0);
    app_af_addr       : out std_logic_vector(30 downto 0);
    app_wdf_wren      : out std_logic;
    app_wdf_data      : out std_logic_vector(APPDATA_WIDTH-1 downto 0);
    app_wdf_mask_data : out std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
    app_cmp_data      : out std_logic_vector(APPDATA_WIDTH-1 downto 0)
    );
end entity ddr2_tb_test_gen;

architecture syn of ddr2_tb_test_gen is

  component ddr2_tb_test_addr_gen
    generic (
      BANK_WIDTH : integer;
      COL_WIDTH  : integer;
      ROW_WIDTH  : integer);
    port (
      clk         : in  std_logic;
      rst         : in  std_logic;
      wr_addr_en  : in  std_logic;
      app_af_cmd  : out std_logic_vector(2 downto 0);
      app_af_addr : out std_logic_vector(30 downto 0);
      app_af_wren : out std_logic);
  end component;

  component ddr2_tb_test_data_gen
    generic (
      DM_WIDTH      : integer;
      DQ_WIDTH      : integer;
      APPDATA_WIDTH : integer;
      ECC_ENABLE    : integer);
    port (
      clk               : in  std_logic;
      rst               : in  std_logic;
      wr_data_en        : in  std_logic;
      rd_data_valid     : in  std_logic;
      app_wdf_wren      : out std_logic;
      app_wdf_data      : out std_logic_vector(APPDATA_WIDTH-1 downto 0);
      app_wdf_mask_data : out std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
      app_cmp_data      : out std_logic_vector(APPDATA_WIDTH-1 downto 0));
  end component;

begin

  --***************************************************************************

  u_addr_gen : ddr2_tb_test_addr_gen
    generic map (
      BANK_WIDTH  => BANK_WIDTH,
      COL_WIDTH   => COL_WIDTH,
      ROW_WIDTH   => ROW_WIDTH
      )
    port map (
      clk         => clk,
      rst         => rst,
      wr_addr_en  => wr_addr_en,
      app_af_cmd  => app_af_cmd,
      app_af_addr => app_af_addr,
      app_af_wren => app_af_wren
      );

  u_data_gen : ddr2_tb_test_data_gen
    generic map (
      DM_WIDTH          => DM_WIDTH,
      DQ_WIDTH          => DQ_WIDTH,
      APPDATA_WIDTH     => APPDATA_WIDTH,
      ECC_ENABLE        => ECC_ENABLE
      )
    port map (
      clk               => clk,
      rst               => rst,
      wr_data_en        => wr_data_en,
      rd_data_valid     => rd_data_valid,
      app_wdf_wren      => app_wdf_wren,
      app_wdf_data      => app_wdf_data,
      app_wdf_mask_data => app_wdf_mask_data,
      app_cmp_data      => app_cmp_data
      );

end architecture syn;


