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
--  /   /         Filename: ddr2_phy_dm_iob.vhd
-- /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:03 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR2
--Purpose:
--   This module places the data mask signals into the IOBs.
--Reference:
--Revision History:
--   Rev 1.1 - To fix timing issues with Synplicity 9.6.1, syn_preserve 
--             attribute added for the instance u_dm_ce. PK. 11/11/08
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity ddr2_phy_dm_iob is
  port (
    clk90           : in std_logic;
    dm_ce           : in std_logic;
    mask_data_rise  : in std_logic;
    mask_data_fall  : in std_logic;
    ddr_dm          : out std_logic
  );
end entity ddr2_phy_dm_iob;

architecture syn of ddr2_phy_dm_iob is

  signal dm_out        : std_logic;
  signal dm_ce_r       : std_logic;

  attribute syn_preserve : boolean;
  attribute syn_preserve of u_dm_ce : label is true;

begin

  u_dm_ce : FDRSE_1
    port map (
      Q    => dm_ce_r,
      C    => clk90,
      CE   => '1',
      D    => dm_ce,
      R    => '0',
      S    => '0'
      );

  u_oddr_dm : ODDR
    generic map (
      SRTYPE        => "SYNC",
      DDR_CLK_EDGE  => "SAME_EDGE"
      )
    port map (
      Q  => dm_out,
      C  => clk90,
      CE => dm_ce_r,
      D1 => mask_data_rise,
      D2 => mask_data_fall,
      R  => '0',
      S  => '0'
      );

  u_obuf_dm : OBUF
    port map (
      I  => dm_out,
      O  => ddr_dm
    );

end architecture syn;


