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
--  /   /         Filename: ddr2_tb_test_data_gen.vhd
-- /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:03 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR/DDR2
--Purpose:
--   This module contains the data generation logic for the synthesizable
--   testbench.
--Reference:
--Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity ddr2_tb_test_data_gen is
  generic (
    -- Following parameters are for 72-bit RDIMM design (for ML561 Reference 
    -- board design). Actual values may be different. Actual parameters values 
    -- are passed from design top module ddr2_16bx2_mig361 module. Please refer to
    -- the ddr2_16bx2_mig361 module for actual values.
    DM_WIDTH            : integer := 9;
    DQ_WIDTH            : integer := 72;
    APPDATA_WIDTH       : integer := 144;
    ECC_ENABLE          : integer := 0
  );
  port (
    clk                 : in std_logic;
    rst                 : in std_logic;
    wr_data_en          : in std_logic;
    rd_data_valid       : in std_logic;
    app_wdf_wren        : out std_logic;
    app_wdf_data        : out std_logic_vector(APPDATA_WIDTH-1 downto 0);
    app_wdf_mask_data   : out std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
    app_cmp_data        : out std_logic_vector(APPDATA_WIDTH-1 downto 0)
  );
end entity ddr2_tb_test_data_gen;

architecture syn of ddr2_tb_test_data_gen is

  type WR_STATE_TYPE is (WR_IDLE_FIRST_DATA, WR_SECOND_DATA,
                         WR_THIRD_DATA, WR_FOURTH_DATA);
  type RD_STATE_TYPE is (RD_IDLE_FIRST_DATA, RD_SECOND_DATA,
                         RD_THIRD_DATA, RD_FOURTH_DATA);

  -- Kluge for VHDL to assign testbench pattern - max databits = 512
  constant WR_DATA_A_PAT      : std_logic_vector(255 downto 0) :=
    X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  constant WR_DATA_5_PAT      : std_logic_vector(255 downto 0) :=
    X"5555555555555555555555555555555555555555555555555555555555555555";
  constant WR_DATA_9_PAT      : std_logic_vector(255 downto 0) :=
    X"9999999999999999999999999999999999999999999999999999999999999999";
  constant WR_DATA_6_PAT      : std_logic_vector(255 downto 0) :=
    X"6666666666666666666666666666666666666666666666666666666666666666";

  signal app_wdf_data_r      : std_logic_vector(APPDATA_WIDTH-1 downto 0);
  signal app_wdf_mask_data_r : std_logic_vector((APPDATA_WIDTH/8)-1
                                                downto 0);
  signal app_wdf_wren_r      : std_logic;
  signal rd_data_pat_fall    : std_logic_vector((APPDATA_WIDTH/2)-1 downto 0);
  signal rd_data_pat_rise    : std_logic_vector((APPDATA_WIDTH/2)-1 downto 0);
  signal rd_data_valid_r     : std_logic;
  signal rd_state            : RD_STATE_TYPE;
  signal rst_r               : std_logic;
  signal rst_r1              : std_logic;
  signal wr_data             : std_logic_vector(APPDATA_WIDTH-1 downto 0);
  signal wr_data_en_r        : std_logic;
  signal wr_data_fall        : std_logic_vector((APPDATA_WIDTH/2)-1 downto 0);
  signal wr_data_rise        : std_logic_vector((APPDATA_WIDTH/2)-1 downto 0);
  signal wr_mask_data        : std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
  signal wr_mask_data_fall   : std_logic_vector((APPDATA_WIDTH/16)-1 downto 0);
  signal wr_mask_data_rise   : std_logic_vector((APPDATA_WIDTH/16)-1 downto 0);
  signal wr_state            : WR_STATE_TYPE;

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

  process (clk)
  begin
    if (rising_edge(clk)) then
      app_wdf_data_r      <= wr_data;
      app_wdf_mask_data_r <= wr_mask_data;
      app_wdf_data        <= app_wdf_data_r;
      app_wdf_mask_data   <= app_wdf_mask_data_r;
    end if;
  end process;

  -- inst ff for timing
  ff_wdf_wren : FDRSE
    port map (
      Q    => app_wdf_wren_r,
      C    => clk,
      CE   => '1',
      D    => wr_data_en_r,
      R    => '0',
      S    => '0'
    );

  ff_wdf_wren_r : FDRSE
    port map (
      Q    => app_wdf_wren,
      C    => clk,
      CE   => '1',
      D    => app_wdf_wren_r,
      R    => '0',
      S    => '0'
    );

  ff_rd_data_valid_r : FDRSE
    port map (
      Q    => rd_data_valid_r,
      C    => clk,
      CE   => '1',
      D    => rd_data_valid,
      R    => '0',
      S    => '0'
    );

  --***************************************************************************
  -- DATA generation for WRITE DATA FIFOs & for READ DATA COMPARE
  --***************************************************************************

  wr_data      <= wr_data_fall & wr_data_rise;
  wr_mask_data <= wr_mask_data_fall & wr_mask_data_rise;

  --*****************************************************************
  -- For now, don't vary data masks
  --*****************************************************************

  wr_mask_data_rise <= (others => '0');
  wr_mask_data_fall <= (others => '0');

  --*****************************************************************
  -- Write data logic
  --*****************************************************************

  -- write data generation
  process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst_r1 = '1') then
        wr_data_rise <= (others => 'X');
        wr_data_fall <= (others => 'X');
        wr_state <= WR_IDLE_FIRST_DATA;
      else
        case (wr_state) is
          when WR_IDLE_FIRST_DATA =>
            if (wr_data_en = '1') then
              wr_data_rise <= (others => '1'); -- 0xF
              wr_data_fall <= (others => '0'); -- 0x0
              wr_state <= WR_SECOND_DATA;
            end if;
          when WR_SECOND_DATA =>
            if (wr_data_en = '1') then
              wr_data_rise <=
                WR_DATA_A_PAT((APPDATA_WIDTH/2)-1 downto 0); -- 0xA
              wr_data_fall <=
                WR_DATA_5_PAT((APPDATA_WIDTH/2)-1 downto 0); -- 0x5
              wr_state <= WR_THIRD_DATA;
            end if;
          when WR_THIRD_DATA =>
            if (wr_data_en = '1') then
              wr_data_rise <=
                WR_DATA_5_PAT((APPDATA_WIDTH/2)-1 downto 0); -- 0x5
              wr_data_fall <=
                WR_DATA_A_PAT((APPDATA_WIDTH/2)-1 downto 0); -- 0xA
              wr_state <= WR_FOURTH_DATA;
            end if;
          when WR_FOURTH_DATA =>
            if (wr_data_en = '1') then
              wr_data_rise <=
                WR_DATA_9_PAT((APPDATA_WIDTH/2)-1 downto 0); -- 0x9
              wr_data_fall <=
                WR_DATA_6_PAT((APPDATA_WIDTH/2)-1 downto 0); -- 0x6
              wr_state <= WR_IDLE_FIRST_DATA;
            end if;
        end case;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst_r1 = '1') then
        wr_data_en_r <= '0';
      else
        -- read comparison data generation
        wr_data_en_r <= wr_data_en;
      end if;
    end if;
  end process;

  --*****************************************************************
  -- Read data logic
  --*****************************************************************

  process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst_r1 = '1') then
        rd_data_pat_rise <= (others => 'X');
        rd_data_pat_fall <= (others => 'X');
        rd_state <= RD_IDLE_FIRST_DATA;
      else
        case (rd_state) is
          when RD_IDLE_FIRST_DATA =>
            if (rd_data_valid_r = '1') then
              rd_data_pat_rise <= (others => '1');  -- 0xF
              rd_data_pat_fall <= (others => '0');  -- 0x0
              rd_state <= RD_SECOND_DATA;
            end if;
          when RD_SECOND_DATA =>
            if (rd_data_valid_r = '1') then
              rd_data_pat_rise <=
                WR_DATA_A_PAT((APPDATA_WIDTH/2)-1 downto 0);  -- 0xA
              rd_data_pat_fall <=
                WR_DATA_5_PAT((APPDATA_WIDTH/2)-1 downto 0);  -- 0x5
              rd_state <= RD_THIRD_DATA;
            end if;
          when RD_THIRD_DATA =>
            if (rd_data_valid_r = '1') then
              rd_data_pat_rise <=
                WR_DATA_5_PAT((APPDATA_WIDTH/2)-1 downto 0);  -- 0x5
              rd_data_pat_fall <=
                WR_DATA_A_PAT((APPDATA_WIDTH/2)-1 downto 0);  -- 0xA
              rd_state <= RD_FOURTH_DATA;
            end if;
          when RD_FOURTH_DATA =>
            if (rd_data_valid_r = '1') then
              rd_data_pat_rise <=
                WR_DATA_9_PAT((APPDATA_WIDTH/2)-1 downto 0);  -- 0x9
              rd_data_pat_fall <=
                WR_DATA_6_PAT((APPDATA_WIDTH/2)-1 downto 0);  -- 0x6
              rd_state <= RD_IDLE_FIRST_DATA;
            end if;
        end case;
      end if;
    end if;
  end process;

  --data to the compare circuit during read
  app_cmp_data <= (rd_data_pat_fall & rd_data_pat_rise);

end architecture syn;


