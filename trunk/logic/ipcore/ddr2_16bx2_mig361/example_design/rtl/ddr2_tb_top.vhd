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
-- \   \   \/     Version: 3.6.1
--  \   \         Application: MIG
--  /   /         Filename: ddr2_tb_top.vhd
-- /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:03 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR/DDR2
--Purpose:
--   This module is the synthesizable test bench for the memory interface.
--   This Test bench is to compare the write and the read data and generate
--   an error flag.
--Reference:
--Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity ddr2_tb_top is
  generic (
    -- Following parameters are for 72-bit RDIMM design (for ML561 Reference 
    -- board design). Actual values may be different. Actual parameters values 
    -- are passed from design top module ddr2_16bx2_mig361 module. Please refer to
    -- the ddr2_16bx2_mig361 module for actual values.
    BANK_WIDTH    : integer := 2;
    COL_WIDTH     : integer := 10;
    DM_WIDTH      : integer := 9;
    DQ_WIDTH      : integer := 72;
    ROW_WIDTH     : integer := 14;
    APPDATA_WIDTH : integer := 144;
    ECC_ENABLE    : integer := 0;
    BURST_LEN     : integer := 4
    );
  port (
    clk0              : in  std_logic;
    rst0              : in  std_logic;
    app_af_afull      : in  std_logic;
    app_wdf_afull     : in  std_logic;
    rd_data_valid     : in  std_logic;
    rd_data_fifo_out  : in  std_logic_vector(APPDATA_WIDTH-1 downto 0);
    phy_init_done     : in  std_logic;
    app_af_wren       : out std_logic;
    app_af_cmd        : out std_logic_vector(2 downto 0);
    app_af_addr       : out std_logic_vector(30 downto 0);
    app_wdf_wren      : out std_logic;
    app_wdf_data      : out std_logic_vector(APPDATA_WIDTH-1 downto 0);
    app_wdf_mask_data : out std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
    error             : out std_logic;
    error_cmp         : out std_logic
    );
end entity ddr2_tb_top;

architecture syn of ddr2_tb_top is

  component ddr2_tb_test_cmp is
    generic (
      DQ_WIDTH            : integer;
      APPDATA_WIDTH       : integer;
      ECC_ENABLE          : integer
    );
    port (
      clk                 : in std_logic;
      rst                 : in std_logic;
      phy_init_done       : in std_logic;
      rd_data_valid       : in std_logic;
      app_cmp_data        : in std_logic_vector(APPDATA_WIDTH-1 downto 0);
      rd_data_fifo_in     : in std_logic_vector(APPDATA_WIDTH-1 downto 0);
      error               : out std_logic;
      error_cmp           : out std_logic
    );
  end component;

  component ddr2_tb_test_gen is
    generic (
      BANK_WIDTH          : integer;
      COL_WIDTH           : integer;
      DM_WIDTH            : integer;
      DQ_WIDTH            : integer;
      APPDATA_WIDTH       : integer;
      ECC_ENABLE          : integer;
      ROW_WIDTH           : integer
    );
    port (
      clk                 : in std_logic;
      rst                 : in std_logic;
      wr_addr_en          : in std_logic;
      wr_data_en          : in std_logic;
      rd_data_valid       : in std_logic;
      app_af_wren         : out std_logic;
      app_af_cmd          : out std_logic_vector(2 downto 0);
      app_af_addr         : out std_logic_vector(30 downto 0);
      app_wdf_wren        : out std_logic;
      app_wdf_data        : out std_logic_vector(APPDATA_WIDTH-1 downto 0);
      app_wdf_mask_data   : out std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
      app_cmp_data        : out std_logic_vector(APPDATA_WIDTH-1 downto 0)
    );
  end component;

  constant BURST_LEN_DIV2 : integer := BURST_LEN / 2;

  type TB_STATE_TYPE is (TB_IDLE, TB_WRITE, TB_READ);

  signal app_af_afull_r      : std_logic;
  signal app_af_afull_r1     : std_logic;
  signal app_af_afull_r2     : std_logic;
  signal app_af_not_afull_r  : std_logic;
  signal app_cmp_data        : std_logic_vector(APPDATA_WIDTH-1 downto 0);
  signal app_wdf_afull_r     : std_logic;
  signal app_wdf_afull_r1    : std_logic;
  signal app_wdf_afull_r2    : std_logic;
  signal app_wdf_not_afull_r : std_logic;
  signal burst_cnt           : unsigned(2 downto 0);
  signal phy_init_done_tb_r  : std_logic;
  signal phy_init_done_r     : std_logic;
  signal rst_r               : std_logic;
  signal rst_r1              : std_logic;
  signal state               : TB_STATE_TYPE;
  signal state_cnt           : unsigned(3 downto 0);
  signal wr_addr_en          : std_logic;
  signal wr_data_en          : std_logic;

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
  process (clk0)
  begin
    if (rising_edge(clk0)) then
      rst_r  <= rst0;
      rst_r1 <= rst_r;
    end if;
  end process;

  -- Instantiate flops for timing.
  ff_af_afull_r : FDRSE
    port map (
      Q    => app_af_afull_r,
      C    => clk0,
      CE   => '1',
      D    => app_af_afull,
      R    => '0',
      S    => '0'
    );

  ff_af_afull_r1 : FDRSE
    port map (
      Q    => app_af_afull_r1,
      C    => clk0,
      CE   => '1',
      D    => app_af_afull_r,
      R    => '0',
      S    => '0'
    );

  ff_af_afull_r2 : FDRSE
    port map (
      Q    => app_af_afull_r2,
      C    => clk0,
      CE   => '1',
      D    => app_af_afull_r1,
      R    => '0',
      S    => '0'
    );

  ff_wdf_afull_r : FDRSE
    port map (
      Q    => app_wdf_afull_r,
      C    => clk0,
      CE   => '1',
      D    => app_wdf_afull,
      R    => '0',
      S    => '0'
    );

  ff_wdf_afull_r1 : FDRSE
    port map (
      Q    => app_wdf_afull_r1,
      C    => clk0,
      CE   => '1',
      D    => app_wdf_afull_r,
      R    => '0',
      S    => '0'
    );

  ff_wdf_afull_r2 : FDRSE
    port map (
      Q    => app_wdf_afull_r2,
      C    => clk0,
      CE   => '1',
      D    => app_wdf_afull_r1,
      R    => '0',
      S    => '0'
    );

  ff_phy_init_done : FDRSE
    port map (
      Q    => phy_init_done_r,
      C    => clk0,
      CE   => '1',
      D    => phy_init_done,
      R    => '0',
      S    => '0'
    );

  --***************************************************************************
  -- State Machine for writing to WRITE DATA & ADDRESS FIFOs
  -- state machine changed for low FIFO threshold values
  --***************************************************************************

  process (clk0)
  begin
    if (rising_edge(clk0)) then
      if (rst_r1 = '1') then
        wr_data_en          <= 'X';
        wr_addr_en          <= 'X';
        state               <= TB_IDLE;
        state_cnt           <= (others => 'X');
        app_af_not_afull_r  <= 'X';
        app_wdf_not_afull_r <= 'X';
        burst_cnt           <= (others => 'X');
        phy_init_done_tb_r  <= 'X';
      else
        wr_data_en          <= '0';
        wr_addr_en          <= '0';
        app_af_not_afull_r  <= not(app_af_afull_r2);
        app_wdf_not_afull_r <= not(app_wdf_afull_r2);
        phy_init_done_tb_r  <= phy_init_done_r;

        case (state) is
          when TB_IDLE =>
            state_cnt <= "0000";
            burst_cnt <= TO_UNSIGNED(BURST_LEN_DIV2-1,3);
            -- only start writing when initialization done
            if ((app_wdf_not_afull_r = '1') and (app_af_not_afull_r = '1') and
                (phy_init_done_tb_r = '1')) then
              state <= TB_WRITE;
            end if;

          when TB_WRITE =>
            if ((app_wdf_not_afull_r = '1') and
                (app_af_not_afull_r = '1')) then
              wr_data_en <= '1';
              -- When we're done with the current burst...
              if (burst_cnt = "000") then
                burst_cnt <= TO_UNSIGNED(BURST_LEN_DIV2-1,3);
                wr_addr_en <= '1';
                -- Writes occurs in groups of 8 consecutive bursts. Once 8
                -- writes have been issued, now issue the corresponding read
                -- back bursts
                if (state_cnt = "0111") then
                  state <= TB_READ;
                  state_cnt <= "0000";
                else
                  state_cnt <= state_cnt + 1;
                end if;
              else
                burst_cnt <= burst_cnt - 1;
              end if;
            end if;

          when TB_READ =>
            burst_cnt <= TO_UNSIGNED(BURST_LEN_DIV2-1,3);
            if (app_af_not_afull_r = '1') then
              wr_addr_en <= '1';
              -- if finished with all 8 reads, proceed to next 8 writes
              if (state_cnt = "0111") then
                state <= TB_WRITE;
                state_cnt <= "0000";
              else
                state_cnt <= state_cnt + 1;
              end if;
            end if;
        end case;
      end if;
    end if;
  end process;

  -- Read data comparision
  u_tb_test_cmp : ddr2_tb_test_cmp
    generic map (
      DQ_WIDTH        => DQ_WIDTH,
      APPDATA_WIDTH   => APPDATA_WIDTH,
      ECC_ENABLE      => ECC_ENABLE
      )
    port map (
      clk             => clk0,
      rst             => rst0,
      phy_init_done   => phy_init_done_tb_r,
      rd_data_valid   => rd_data_valid,
      app_cmp_data    => app_cmp_data,
      rd_data_fifo_in => rd_data_fifo_out,
      error           => error,
      error_cmp       => error_cmp
      );

  -- Command/Address and Write Data generation
  u_tb_test_gen : ddr2_tb_test_gen
    generic map (
      BANK_WIDTH        => BANK_WIDTH,
      COL_WIDTH         => COL_WIDTH,
      DM_WIDTH          => DM_WIDTH,
      DQ_WIDTH          => DQ_WIDTH,
      APPDATA_WIDTH     => APPDATA_WIDTH,
      ECC_ENABLE        => ECC_ENABLE,
      ROW_WIDTH         => ROW_WIDTH
      )
    port map (
      clk               => clk0,
      rst               => rst0,
      wr_addr_en        => wr_addr_en,
      wr_data_en        => wr_data_en,
      rd_data_valid     => rd_data_valid,
      app_af_wren       => app_af_wren,
      app_af_cmd        => app_af_cmd,
      app_af_addr       => app_af_addr,
      app_wdf_wren      => app_wdf_wren,
      app_wdf_data      => app_wdf_data,
      app_wdf_mask_data => app_wdf_mask_data,
      app_cmp_data      => app_cmp_data
      );

end architecture syn;


