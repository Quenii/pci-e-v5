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
-- \   \   \/     Version: 3.3
--  \   \         Application: MIG
--  /   /         Filename: ddr2_usr_addr_fifo.vhd
-- /___/   /\     Date Last Modified: $Date: 2009/08/17 16:10:22 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR/DDR2
--Purpose:
--   This module instantiates the block RAM based FIFO to store the user
--   address and the command information. Also calculates potential bank/row
--   conflicts by comparing the new address with last address issued.
--Reference:
--Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity ddr2_usr_addr_fifo is
  generic (
    -- Following parameters are for 72-bit RDIMM design (for ML561 Reference 
    -- board design). Actual values may be different. Actual parameters values 
    -- are passed from design top module ddr2_sdram_mig33 module. Please refer to
    -- the ddr2_sdram_mig33 module for actual values.
    BANK_WIDTH         : integer := 2;
    COL_WIDTH          : integer := 10;
    CS_BITS            : integer := 0;
    ROW_WIDTH          : integer := 14
  );
  port (
    clk0               : in std_logic;
    rst0               : in std_logic;
    app_af_cmd         : in std_logic_vector(2 downto 0);
    app_af_addr        : in std_logic_vector(30 downto 0);
    app_af_wren        : in std_logic;
    ctrl_af_rden       : in std_logic;
    af_cmd             : out std_logic_vector(2 downto 0);
    af_addr            : out std_logic_vector(30 downto 0);
    af_empty           : out std_logic;
    app_af_afull       : out std_logic
  );
end entity ddr2_usr_addr_fifo;

architecture syn of ddr2_usr_addr_fifo is

  signal fifo_data_out : std_logic_vector(35 downto 0);
  signal rst_r         : std_logic;

  signal i_fifo_data_in : std_logic_vector(35 downto 0);

begin

  i_fifo_data_in(31 downto 0)  <= app_af_cmd(0) & app_af_addr;
  i_fifo_data_in(35 downto 32) <= "00" & app_af_cmd(2 downto 1);

  process (clk0)
  begin
    if (rising_edge(clk0)) then
      rst_r <= rst0;
    end if;
  end process;

  --***************************************************************************

  af_cmd  <= fifo_data_out(33 downto 31);
  af_addr <= fifo_data_out(30 downto 0);

  --***************************************************************************

  u_af : FIFO36
    generic map (
      ALMOST_EMPTY_OFFSET      => X"0007",
      ALMOST_FULL_OFFSET       => X"000F",
      DATA_WIDTH               => 36,
      DO_REG                   => 1,
      EN_SYN                   => true,
      FIRST_WORD_FALL_THROUGH  => false
    )
    port map (
      ALMOSTEMPTY  => open,
      ALMOSTFULL   => app_af_afull,
      DO           => fifo_data_out(31 downto 0),
      DOP          => fifo_data_out(35 downto 32),
      EMPTY        => af_empty,
      FULL         => open,
      RDCOUNT      => open,
      RDERR        => open,
      WRCOUNT      => open,
      WRERR        => open,
      DI           => i_fifo_data_in(31 downto 0),
      DIP          => i_fifo_data_in(35 downto 32),
      RDCLK        => clk0,
      RDEN         => ctrl_af_rden,
      RST          => rst_r,
      WRCLK        => clk0,
      WREN         => app_af_wren
    );

end architecture syn;


