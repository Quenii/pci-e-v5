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
--  /   /         Filename: ddr2_usr_top.vhd
-- /___/   /\     Date Last Modified: $Date: 2009/08/17 16:10:22 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR/DDR2
--Purpose:
--   This module interfaces with the user. The user should provide the data
--   and various commands.
--Reference:
--Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity ddr2_usr_top is
  generic (
    -- Following parameters are for 72-bit RDIMM design (for ML561 Reference 
    -- board design). Actual values may be different. Actual parameters values 
    -- are passed from design top module ddr2_sdram_mig33 module. Please refer to
    -- the ddr2_sdram_mig33 module for actual values.
    BANK_WIDTH         :     integer := 2;
    CS_BITS            :     integer := 0;
    COL_WIDTH          :     integer := 10;
    DQ_WIDTH           :     integer := 72;
    DQ_PER_DQS         :     integer := 8;
    ECC_ENABLE         :     integer := 0;
    APPDATA_WIDTH      :     integer := 144;
    DQS_WIDTH          :     integer := 9;
    ROW_WIDTH          :     integer := 14
    );
  port (
    clk0               : in  std_logic;
    clk90              : in  std_logic;
    rst0               : in  std_logic;
    rd_data_in_rise    : in  std_logic_vector(DQ_WIDTH-1 downto 0);
    rd_data_in_fall    : in  std_logic_vector(DQ_WIDTH-1 downto 0);
    phy_calib_rden     : in  std_logic_vector(DQS_WIDTH-1 downto 0);
    phy_calib_rden_sel : in  std_logic_vector(DQS_WIDTH-1 downto 0);
    rd_data_valid      : out std_logic;
    rd_data_fifo_out   : out std_logic_vector((APPDATA_WIDTH)-1 downto 0);
    app_af_cmd         : in  std_logic_vector(2 downto 0);
    app_af_addr        : in  std_logic_vector(30 downto 0);
    app_af_wren        : in  std_logic;
    ctrl_af_rden       : in  std_logic;
    af_cmd             : out std_logic_vector(2 downto 0);
    af_addr            : out std_logic_vector(30 downto 0);
    af_empty           : out std_logic;
    app_af_afull       : out std_logic;
    rd_ecc_error       : out std_logic_vector(1 downto 0);
    app_wdf_wren       : in  std_logic;
    app_wdf_data       : in  std_logic_vector(APPDATA_WIDTH-1 downto 0);
    app_wdf_mask_data  : in  std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
    wdf_rden           : in  std_logic;
    app_wdf_afull      : out std_logic;
    wdf_data           : out std_logic_vector((2*DQ_WIDTH)-1 downto 0);
    wdf_mask_data      : out std_logic_vector(((2*DQ_WIDTH)/8)-1 downto 0)
    );
end entity ddr2_usr_top;

architecture syn of ddr2_usr_top is

  component ddr2_usr_addr_fifo
    generic (
      BANK_WIDTH    : integer;
      COL_WIDTH     : integer;
      CS_BITS       : integer;
      ROW_WIDTH     : integer);
    port (
      clk0         : in  std_logic;
      rst0         : in  std_logic;
      app_af_cmd   : in  std_logic_vector(2 downto 0);
      app_af_addr  : in  std_logic_vector(30 downto 0);
      app_af_wren  : in  std_logic;
      ctrl_af_rden : in  std_logic;
      af_cmd       : out std_logic_vector(2 downto 0);
      af_addr      : out std_logic_vector(30 downto 0);
      af_empty     : out std_logic;
      app_af_afull : out std_logic);
  end component;

  component ddr2_usr_rd
    generic (
      DQ_PER_DQS     : integer;
      DQS_WIDTH      : integer;
      APPDATA_WIDTH  : integer;
      ECC_ENABLE     : integer);
    port (
      clk0             : in  std_logic;
      rst0             : in  std_logic;
      rd_data_in_rise  : in  std_logic_vector((DQS_WIDTH*DQ_PER_DQS)-1
                                              downto 0);
      rd_data_in_fall  : in  std_logic_vector((DQS_WIDTH*DQ_PER_DQS)-1
                                              downto 0);
      ctrl_rden        : in  std_logic_vector(DQS_WIDTH-1 downto 0);
      ctrl_rden_sel    : in  std_logic_vector(DQS_WIDTH-1 downto 0);
      rd_ecc_error     : out std_logic_vector(1 downto 0);
      rd_data_valid    : out std_logic;
      rd_data_out_rise : out std_logic_vector((APPDATA_WIDTH/2)-1 downto 0);
      rd_data_out_fall : out std_logic_vector((APPDATA_WIDTH/2)-1 downto 0));
  end component;

  component ddr2_usr_wr
    generic (
      BANK_WIDTH     : integer;
      COL_WIDTH      : integer;
      CS_BITS        : integer;
      DQ_WIDTH       : integer;
      ECC_ENABLE     : integer;
      APPDATA_WIDTH  : integer;
      ROW_WIDTH      : integer);
    port (
      clk0              : in  std_logic;
      clk90             : in  std_logic;
      rst0              : in  std_logic;
      app_wdf_wren      : in  std_logic;
      app_wdf_data      : in  std_logic_vector(APPDATA_WIDTH-1 downto 0);
      app_wdf_mask_data : in  std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
      wdf_rden          : in  std_logic;
      app_wdf_afull     : out std_logic;
      wdf_data          : out std_logic_vector((2*DQ_WIDTH)-1 downto 0);
      wdf_mask_data     : out std_logic_vector(((2*DQ_WIDTH)/8)-1 downto 0));
  end component;

  signal i_rd_data_fifo_out_fall : std_logic_vector((APPDATA_WIDTH/2)-1
                                                    downto 0);
  signal i_rd_data_fifo_out_rise : std_logic_vector((APPDATA_WIDTH/2)-1
                                                    downto 0);

begin

  --***************************************************************************

  rd_data_fifo_out <= (i_rd_data_fifo_out_fall &
                       i_rd_data_fifo_out_rise);

  -- read data de-skew and ECC calculation
  u_usr_rd : ddr2_usr_rd
    generic map (
      DQ_PER_DQS       => DQ_PER_DQS,
      ECC_ENABLE       => ECC_ENABLE,
      APPDATA_WIDTH    => APPDATA_WIDTH,
      DQS_WIDTH        => DQS_WIDTH
      )
    port map (
      clk0             => clk0,
      rst0             => rst0,
      rd_data_in_rise  => rd_data_in_rise,
      rd_data_in_fall  => rd_data_in_fall,
      rd_ecc_error     => rd_ecc_error,
      ctrl_rden        => phy_calib_rden,
      ctrl_rden_sel    => phy_calib_rden_sel,
      rd_data_valid    => rd_data_valid,
      rd_data_out_rise => i_rd_data_fifo_out_rise,
      rd_data_out_fall => i_rd_data_fifo_out_fall
      );

  -- Command/Addres FIFO
  u_usr_addr_fifo : ddr2_usr_addr_fifo
    generic map (
      BANK_WIDTH   => BANK_WIDTH,
      COL_WIDTH    => COL_WIDTH,
      CS_BITS      => CS_BITS,
      ROW_WIDTH    => ROW_WIDTH
      )
    port map (
      clk0         => clk0,
      rst0         => rst0,
      app_af_cmd   => app_af_cmd,
      app_af_addr  => app_af_addr,
      app_af_wren  => app_af_wren,
      ctrl_af_rden => ctrl_af_rden,
      af_cmd       => af_cmd,
      af_addr      => af_addr,
      af_empty     => af_empty,
      app_af_afull => app_af_afull
      );

  u_usr_wr : ddr2_usr_wr
    generic map (
      BANK_WIDTH        => BANK_WIDTH,
      COL_WIDTH         => COL_WIDTH,
      CS_BITS           => CS_BITS,
      DQ_WIDTH          => DQ_WIDTH,
      ECC_ENABLE        => ECC_ENABLE,
      APPDATA_WIDTH     => APPDATA_WIDTH,
      ROW_WIDTH         => ROW_WIDTH
      )
    port map (
      clk0              => clk0,
      clk90             => clk90,
      rst0              => rst0,
      app_wdf_wren      => app_wdf_wren,
      app_wdf_data      => app_wdf_data,
      app_wdf_mask_data => app_wdf_mask_data,
      wdf_rden          => wdf_rden,
      app_wdf_afull     => app_wdf_afull,
      wdf_data          => wdf_data,
      wdf_mask_data     => wdf_mask_data
      );

end architecture syn;



