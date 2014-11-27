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
--  /   /         Filename: ddr2_tb_test_cmp_0.vhd
-- /___/   /\     Date Last Modified: $Date: 2009/08/17 16:10:22 $
-- \   \  /  \    Date Created: Wed Jan 10 2007
--  \___\/\___\
--
--Device: Virtex-5
--Design Name: DDR/DDR2
--Purpose:
--   This module generates the error signal in case of bit errors. It compares
--   the read data with expected data value.
--Reference:
--Revision History:
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity ddr2_tb_test_cmp is
  generic (
    -- Following parameters are for 72-bit RDIMM design (for ML561 Reference 
    -- board design). Actual values may be different. Actual parameters values 
    -- are passed from design top module ddr2_sdram_mig33 module. Please refer to
    -- the ddr2_sdram_mig33 module for actual values.
    DQ_WIDTH           : integer := 72;
    APPDATA_WIDTH      : integer := 144;
    ECC_ENABLE         : integer := 0
  );
  port (
    clk                : in std_logic;
    rst                : in std_logic;
    phy_init_done      : in std_logic;
    rd_data_valid      : in std_logic;
    app_cmp_data       : in std_logic_vector(APPDATA_WIDTH-1 downto 0);
    rd_data_fifo_in    : in std_logic_vector(APPDATA_WIDTH-1 downto 0);
    error              : out std_logic;
    error_cmp          : out std_logic
  );
end entity ddr2_tb_test_cmp;

architecture syn of ddr2_tb_test_cmp is

  function or_br (val : std_logic_vector) return std_logic is
    variable rtn : std_logic := '0';
  begin
    for index in val'range loop
      rtn := rtn or val(index);
    end loop;
    return(rtn);
  end or_br;

  signal byte_err_fall    : std_logic_vector((APPDATA_WIDTH/16)-1 downto 0);
  signal byte_err_fall_r  : std_logic_vector((APPDATA_WIDTH/16)-1 downto 0);
  signal byte_err_rise    : std_logic_vector((APPDATA_WIDTH/16)-1 downto 0);
  signal byte_err_rise_r  : std_logic_vector((APPDATA_WIDTH/16)-1 downto 0);
  signal cmp_data_fall    : std_logic_vector((APPDATA_WIDTH/2)-1 downto 0);
  signal cmp_data_rise    : std_logic_vector((APPDATA_WIDTH/2)-1 downto 0);
  signal cmp_data_r       : std_logic_vector(APPDATA_WIDTH-1 downto 0);
  signal cmp_data_r1      : std_logic_vector(APPDATA_WIDTH-1 downto 0);
  signal cmp_start        : std_logic;
  signal data_fall_r      : std_logic_vector((APPDATA_WIDTH/2)-1 downto 0);
  signal data_rise_r      : std_logic_vector((APPDATA_WIDTH/2)-1 downto 0);
  signal err_fall         : std_logic;
  signal err_rise         : std_logic;
  signal error_tmp_r      : std_logic;
  signal error_tmp_r1     : std_logic;
  signal error_tmp_r2     : std_logic;
  signal rd_data_r        : std_logic_vector(APPDATA_WIDTH-1 downto 0);
  signal rd_data_r1       : std_logic_vector(APPDATA_WIDTH-1 downto 0);
  signal rd_data_r2       : std_logic_vector(APPDATA_WIDTH-1 downto 0);
  signal rd_data_valid_r  : std_logic;
  signal rd_data_valid_r1 : std_logic;
  signal rd_data_valid_r2 : std_logic;
  signal rst_r            : std_logic;
  signal rst_r1           : std_logic;

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

  -- instantiate discrete flops for better timing
  gen_rd_data: for rd_data_i in 0 to APPDATA_WIDTH-1 generate
    ff_rd_data : FDRSE
      port map (
        Q    => rd_data_r(rd_data_i),
        C    => clk,
        CE   => '1',
        D    => rd_data_fifo_in(rd_data_i),
        R    => '0',
        S    => '0'
      );

    ff_rd_data_r1 : FDRSE
      port map (
        Q    => rd_data_r1(rd_data_i),
        C    => clk,
        CE   => '1',
        D    => rd_data_r(rd_data_i),
        R    => '0',
        S    => '0'
      );
  end generate;

  gen_cmp_data: for cmp_data_i in 0 to APPDATA_WIDTH-1 generate
    ff_cmp_data : FDRSE
      port map (
        Q    => cmp_data_r(cmp_data_i),
        C    => clk,
        CE   => '1',
        D    => app_cmp_data(cmp_data_i),
        R    => '0',
        S    => '0'
      );
  end generate;

  data_fall_r   <= rd_data_r2(APPDATA_WIDTH-1 downto (APPDATA_WIDTH/2));
  data_rise_r   <= rd_data_r2((APPDATA_WIDTH/2)-1 downto 0);
  cmp_data_fall <= cmp_data_r(APPDATA_WIDTH-1 downto (APPDATA_WIDTH/2));
  cmp_data_rise <= cmp_data_r((APPDATA_WIDTH/2)-1 downto 0);

  -- Instantiate ff for timing.
  ff_rd_data_valid_r : FDRSE
    port map (
     Q    => rd_data_valid_r,
     C    => clk,
     CE   => '1',
     D    => rd_data_valid,
     R    => '0',
     S    => '0'
     );

  process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst_r1 = '1') then
        rd_data_valid_r1 <= '0';
      else
        rd_data_valid_r1 <= rd_data_valid_r and phy_init_done;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if (rising_edge(clk)) then
      rd_data_r2 <= rd_data_r1;
      cmp_data_r1 <= cmp_data_r;
      rd_data_valid_r2 <= rd_data_valid_r1;
    end if;
  end process;

  gen_cmp: for cmp_i in 0 to (APPDATA_WIDTH/16)-1 generate
    byte_err_fall(cmp_i) <= '1' when
                            ((rd_data_valid_r2 = '1') and
                             (data_fall_r(8*(cmp_i+1)-1 downto 8*cmp_i) /=
                              cmp_data_fall(8*(cmp_i+1)-1 downto 8*cmp_i)))
                            else '0';
    byte_err_rise(cmp_i) <= '1' when
                            ((rd_data_valid_r2 = '1') and
                             (data_rise_r(8*(cmp_i+1)-1 downto 8*cmp_i) /=
                              cmp_data_rise(8*(cmp_i+1)-1 downto 8*cmp_i)))
                            else '0';
  end generate;

  process (clk)
  begin
    if (rising_edge(clk)) then
      byte_err_rise_r <= byte_err_rise;
      byte_err_fall_r <= byte_err_fall;
    end if;
  end process;

  process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst_r1 = '1') then
        err_rise    <= 'X';
        err_fall    <= 'X';
        cmp_start   <= '0';
        error_tmp_r <= '0';
      else
        err_rise <= or_br(byte_err_rise_r);
        err_fall <= or_br(byte_err_fall_r);
        -- start comparing when initialization/calibration complete, and we
        -- get first valid readback
        if (rd_data_valid_r2 = '1') then
          cmp_start <= '1';
        end if;
        if ((cmp_start = '1') and (error_tmp_r = '0')) then
          error_tmp_r <= err_rise or err_fall;
        end if;
        --synthesis translate_off
        if (cmp_start = '1') then
          assert ((err_rise = '0') and (err_fall = '0'))
            report "ERROR at time " & time'image(now);
        end if;
        --synthesis translate_on
      end if;
    end if;
  end process;

  -- FF inst to force synthesis to infer ff's.
  -- Done for timing.
  ff_error_1 : FDRSE
    port map (
       Q    => error_tmp_r1,
       C    => clk,
       CE   => '1',
       D    => error_tmp_r,
       R    => '0',
       S    => '0'
    );

  ff_error_2 : FDRSE
    port map (
      Q    => error_tmp_r2,
      C    => clk,
      CE   => '1',
      D    => error_tmp_r1,
      R    => '0',
      S    => '0'
    );

  process (clk)
  begin
    if (rising_edge(clk)) then
      error     <= error_tmp_r2;
      error_cmp <= err_rise or err_fall;
    end if;
  end process;

end architecture syn;


