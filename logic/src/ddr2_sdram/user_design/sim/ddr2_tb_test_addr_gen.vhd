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
--  /   /         Filename: ddr2_tb_test_addr_gen.vhd
-- /___/   /\     Date Last Modified: $Date: 2009/08/17 16:10:22 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR/DDR2
--Purpose:
--   The address for the memory and the various user commands can be given
--   through this module. It instantiates the block RAM which stores all the
--   information in particular sequence. The data stored should be in a
--   sequence starting from LSB:
--      column address, row address, bank address, commands.
--Reference:
--Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity ddr2_tb_test_addr_gen is
  generic (
    -- Following parameters are for 72-bit RDIMM design (for ML561 Reference
    -- board design). Actual values may be different. Actual parameters values
    -- are passed from design top module ddr2_sdram_mig33 module. Please refer to
    -- the ddr2_sdram_mig33 module for actual values.
    BANK_WIDTH  :     integer := 2;
    COL_WIDTH   :     integer := 10;
    ROW_WIDTH   :     integer := 14
    );
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    wr_addr_en  : in  std_logic;
    app_af_cmd  : out std_logic_vector(2 downto 0);
    app_af_addr : out std_logic_vector(30 downto 0);
    app_af_wren : out std_logic
    );
end entity ddr2_tb_test_addr_gen;

architecture syn of ddr2_tb_test_addr_gen is

  -- RAM initialization patterns
  -- NOTE: Not all bits in each range may be used (e.g. in an application
  --  using only 10 column bits, bits[11:10] of ROM output will be unused
  --  COLUMN  = [11:0]
  --  ROW     = [27:12]
  --  BANK    = [30:28]
  --  CHIP    = [31]
  --  COMMAND = [35:32]

  constant RAM_INIT_00 : bit_vector(255 downto 0) :=
    (X"800020C0" & X"800020C8" & X"000020D0" & X"000020D8" &
     X"000010E0" & X"000010E8" & X"800010F0" & X"800010F8");
  constant RAM_INIT_01 : bit_vector(255 downto 0) :=
    (X"800020C0" & X"800020C8" & X"000020D0" & X"000020D8" &
     X"000010E0" & X"000010E8" & X"800010F0" & X"800010F8");
  constant RAM_INIT_02 : bit_vector(255 downto 0) :=
    (X"100040C0" & X"100040C8" & X"900040D0" & X"900040D8" &
     X"900030E0" & X"900030E8" & X"100030F0" & X"100030F8");
  constant RAM_INIT_03 : bit_vector(255 downto 0) :=
    (X"100040C0" & X"100040C8" & X"900040D0" & X"900040D8" &
     X"900030E0" & X"900030E8" & X"100030F0" & X"100030F8");
  constant RAM_INIT_04 : bit_vector(255 downto 0) :=
    (X"A00060C0" & X"200060C8" & X"200060D0" & X"A00060D8" &
     X"200050E0" & X"A00050E8" & X"A00050F0" & X"200050F8");
  constant RAM_INIT_05 : bit_vector(255 downto 0) :=
    (X"A00060C0" & X"200060C8" & X"200060D0" & X"A00060D8" &
     X"200050E0" & X"A00050E8" & X"A00050F0" & X"200050F8");
  constant RAM_INIT_06 : bit_vector(255 downto 0) :=
    (X"300080C0" & X"B00080C8" & X"B00080D0" & X"300080D8" &
     X"B00070E0" & X"300070E8" & X"300070F0" & X"B00070F8");
  constant RAM_INIT_07 : bit_vector(255 downto 0) :=
    (X"300080C0" & X"B00080C8" & X"B00080D0" & X"300080D8" &
     X"B00070E0" & X"300070E8" & X"300070F0" & X"B00070F8");
  constant RAM_INITP_00 : bit_vector(255 downto 0) :=
    (X"11111111" & X"00000000" & X"11111111" & X"00000000" &
     X"11111111" & X"00000000" & X"11111111" & X"00000000");

  signal wr_addr_en_r1 : std_logic;
  signal af_cmd_r      : std_logic_vector(2 downto 0);
  signal af_addr_r     : std_logic_vector(30 downto 0);
  signal af_wren_r     : std_logic;
  signal ramb_addr     : std_logic_vector(15 downto 0);
  signal ramb_dout     : std_logic_vector(35 downto 0);
  signal rst_r         : std_logic;
  signal rst_r1        : std_logic;
  signal wr_addr_cnt   : unsigned(5 downto 0);
  signal wr_addr_en_r0 : std_logic;

  attribute syn_maxfan : integer;
  attribute syn_preserve : boolean;
  attribute equivalent_register_removal : string;
  attribute shreg_extract : string;
  attribute equivalent_register_removal of rst_r  : signal is "no";
  attribute syn_preserve                of rst_r  : signal is true;
  attribute shreg_extract               of rst_r  : signal is "no";
  attribute shreg_extract               of rst_r1 : signal is "no";
  attribute syn_maxfan of rst_r1 : signal is 10;

begin

  --***************************************************************************

  -- local reset "tree" for controller logic only. Create this to ease timing
  -- on reset path. Prohibit equivalent register removal on RST_R to prevent
  -- "sharing" with other local reset trees (caution: make sure global fanout
  -- limit is set to large enough value, otherwise SLICES may be used for
  -- fanout control on RST_R.
  process (clk)
  begin
    if (rising_edge(clk)) then
      rst_r  <= rst;
      rst_r1 <= rst_r;
    end if;
  end process;

  --***************************************************************************
  -- ADDRESS generation for Write and Read Address FIFOs:
  -- ROM with address patterns
  -- 512x36 mode is used with addresses 0-127 for storing write addresses and
  -- addresses (128-511) for storing read addresses
  -- INIP_OO: read 1
  -- INIP_OO: write 0
  --***************************************************************************

  ramb_addr <= ("00000" & std_logic_vector(wr_addr_cnt) & "00000");

  -- register to help timing
  u_wr_rd_addr_lookup : RAMB36
    generic map (
      READ_WIDTH_A  => 36,
      READ_WIDTH_B  => 36,
      DOA_REG       => 1,
      INIT_00       => RAM_INIT_00,
      INIT_01       => RAM_INIT_01,
      INIT_02       => RAM_INIT_02,
      INIT_03       => RAM_INIT_03,
      INIT_04       => RAM_INIT_04,
      INIT_05       => RAM_INIT_05,
      INIT_06       => RAM_INIT_06,
      INIT_07       => RAM_INIT_07,
      INITP_00      => RAM_INITP_00
      )
    port map (
      CASCADEOUTLATA  => open,
      CASCADEOUTLATB  => open,
      CASCADEOUTREGA  => open,
      CASCADEOUTREGB  => open,
      DOA             => ramb_dout(31 downto 0),
      DOB             => open,
      DOPA            => ramb_dout(35 downto 32),
      DOPB            => open,
      ADDRA           => ramb_addr,
      ADDRB           => X"0000",
      CASCADEINLATA   => '0',
      CASCADEINLATB   => '0',
      CASCADEINREGA   => '0',
      CASCADEINREGB   => '0',
      CLKA            => clk,
      CLKB            => clk,
      DIA             => X"00000000",
      DIB             => X"00000000",
      DIPA            => "0000",
      DIPB            => "0000",
      ENA             => '1',
      ENB             => '1',
      REGCEA          => '1',
      REGCEB          => '1',
      SSRA            => '0',
      SSRB            => '0',
      WEA             => "0000",
      WEB             => "0000"
      );

  -- register backend enables / FIFO enables
  -- write enable for Command/Address FIFO is generated 2 CC after WR_ADDR_EN
  -- (takes 2 CC to come out of test RAM)
  process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst_r1 = '1') then
        app_af_wren <= '0';
        wr_addr_en_r0 <= '0';
        wr_addr_en_r1 <= '0';
        af_wren_r <= '0';
      else
        wr_addr_en_r0 <= wr_addr_en;
        wr_addr_en_r1 <= wr_addr_en_r0;
        af_wren_r <= wr_addr_en_r1;
        app_af_wren <= af_wren_r;
      end if;
    end if;
  end process;

  -- FIFO addresses
  process (clk)
  begin
    if (rising_edge(clk)) then
      af_addr_r <= (others => '0');
      af_addr_r(COL_WIDTH-1 downto 0) <= ramb_dout(COL_WIDTH-1 downto 0);
      af_addr_r(ROW_WIDTH+COL_WIDTH-1 downto COL_WIDTH) <=
        ramb_dout(ROW_WIDTH+11 downto 12);
      af_addr_r(BANK_WIDTH+ROW_WIDTH+COL_WIDTH-1 downto
                ROW_WIDTH+COL_WIDTH) <= ramb_dout(BANK_WIDTH+27 downto 28);
      af_addr_r(BANK_WIDTH+ROW_WIDTH+COL_WIDTH) <= ramb_dout(31);
      -- only reads and writes are supported for now
      af_cmd_r <= ('0' & ramb_dout(33 downto 32));
      app_af_cmd  <= af_cmd_r;
      app_af_addr <= af_addr_r;
    end if;
  end process;

  -- address input for RAM
  process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst_r1 = '1') then
        wr_addr_cnt <= (others => '0');
      elsif (wr_addr_en = '1') then
        wr_addr_cnt <= wr_addr_cnt + 1;
      end if;
    end if;
  end process;

end architecture syn;


