-------------------------------------------------------------------------------
-- Title      : ddr2_sdram_wrapper
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ddr2_sdram_wrapper.vhd
-- Author     :   <Administrator@GUOYONGDONG>
-- Company    : 
-- Created    : 2012-08-08
-- Last update: 2012-08-23
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-08-08  1.0      GuoYongDong   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ddr2_sdram_wrapper is
  port (
    sys_rst       : in    std_logic;
    -- fifo interface
    fifo_clk      : out   std_logic;
    fifo_wr_en    : in    std_logic;
    fifo_wr_data  : in    std_logic_vector(63 downto 0);
    fifo_full     : out   std_logic;
    fifo_rd_en    : in    std_logic;
    fifo_rd_data  : out   std_logic_vector(63 downto 0);
    fifo_empty    : out   std_logic;
    fifo_data_cnt : out   std_logic_vector(31 downto 0);
    -- ddr2 controler clock and initialization signals
    ddr2_clk      : in    std_logic;
    idly_clk_200  : in    std_logic;    -- 200MHz
    rdy           : out   std_logic;
    -- ddr2 sdram interface
    ddr2_dq       : inout std_logic_vector(31 downto 0);
    ddr2_a        : out   std_logic_vector(13 downto 0);
    ddr2_ba       : out   std_logic_vector(2 downto 0);
    ddr2_dm       : out   std_logic_vector(3 downto 0);
    ddr2_dqs      : inout std_logic_vector(3 downto 0);
    ddr2_dqs_n    : inout std_logic_vector(3 downto 0);
    ddr2_ras_n    : out   std_logic;
    ddr2_cas_n    : out   std_logic;
    ddr2_we_n     : out   std_logic;
    ddr2_cs_n     : out   std_logic_vector(0 downto 0);
    ddr2_odt      : out   std_logic_vector(0 downto 0);
    ddr2_cke      : out   std_logic_vector(0 downto 0);
    ddr2_ck       : out   std_logic_vector(0 downto 0);
    ddr2_ck_n     : out   std_logic_vector(0 downto 0)
    );
end ddr2_sdram_wrapper;

architecture archi of ddr2_sdram_wrapper is
  component ddr2_sdram_mig33
    generic (
      BANK_WIDTH            : integer;
      CKE_WIDTH             : integer;
      CLK_WIDTH             : integer;
      COL_WIDTH             : integer;
      CS_NUM                : integer;
      CS_WIDTH              : integer;
      CS_BITS               : integer;
      DM_WIDTH              : integer;
      DQ_WIDTH              : integer;
      DQ_PER_DQS            : integer;
      DQS_WIDTH             : integer;
      DQ_BITS               : integer;
      DQS_BITS              : integer;
      ODT_WIDTH             : integer;
      ROW_WIDTH             : integer;
      ADDITIVE_LAT          : integer;
      BURST_LEN             : integer;
      BURST_TYPE            : integer;
      CAS_LAT               : integer;
      ECC_ENABLE            : integer;
      APPDATA_WIDTH         : integer;
      MULTI_BANK_EN         : integer;
      TWO_T_TIME_EN         : integer;
      ODT_TYPE              : integer;
      REDUCE_DRV            : integer;
      REG_ENABLE            : integer;
      TREFI_NS              : integer;
      TRAS                  : integer;
      TRCD                  : integer;
      TRFC                  : integer;
      TRP                   : integer;
      TRTP                  : integer;
      TWR                   : integer;
      TWTR                  : integer;
      HIGH_PERFORMANCE_MODE : boolean;
      SIM_ONLY              : integer;
      DEBUG_EN              : integer;
      CLK_PERIOD            : integer;
      DLL_FREQ_MODE         : string;
      CLK_TYPE              : string;
      NOCLK200              : boolean;
      RST_ACT_LOW           : integer);
    port (
      ddr2_dq           : inout std_logic_vector((DQ_WIDTH-1) downto 0);
      ddr2_a            : out   std_logic_vector((ROW_WIDTH-1) downto 0);
      ddr2_ba           : out   std_logic_vector((BANK_WIDTH-1) downto 0);
      ddr2_ras_n        : out   std_logic;
      ddr2_cas_n        : out   std_logic;
      ddr2_we_n         : out   std_logic;
      ddr2_cs_n         : out   std_logic_vector((CS_WIDTH-1) downto 0);
      ddr2_odt          : out   std_logic_vector((ODT_WIDTH-1) downto 0);
      ddr2_cke          : out   std_logic_vector((CKE_WIDTH-1) downto 0);
      ddr2_dm           : out   std_logic_vector((DM_WIDTH-1) downto 0);
      sys_clk           : in    std_logic;
      idly_clk_200      : in    std_logic;
      sys_rst_n         : in    std_logic;
      phy_init_done     : out   std_logic;
      rst0_tb           : out   std_logic;
      clk0_tb           : out   std_logic;
      app_wdf_afull     : out   std_logic;
      app_af_afull      : out   std_logic;
      rd_data_valid     : out   std_logic;
      app_wdf_wren      : in    std_logic;
      app_af_wren       : in    std_logic;
      app_af_addr       : in    std_logic_vector(30 downto 0);
      app_af_cmd        : in    std_logic_vector(2 downto 0);
      rd_data_fifo_out  : out   std_logic_vector((APPDATA_WIDTH-1) downto 0);
      app_wdf_data      : in    std_logic_vector((APPDATA_WIDTH-1) downto 0);
      app_wdf_mask_data : in    std_logic_vector((APPDATA_WIDTH/8-1) downto 0);
      ddr2_dqs          : inout std_logic_vector((DQS_WIDTH-1) downto 0);
      ddr2_dqs_n        : inout std_logic_vector((DQS_WIDTH-1) downto 0);
      ddr2_ck           : out   std_logic_vector((CLK_WIDTH-1) downto 0);
      ddr2_ck_n         : out   std_logic_vector((CLK_WIDTH-1) downto 0));
  end component;
  component fifo_fwft_32x64_pf16
    port (
      clk        : in  std_logic;
      rst        : in  std_logic;
      din        : in  std_logic_vector(63 downto 0);
      wr_en      : in  std_logic;
      rd_en      : in  std_logic;
      dout       : out std_logic_vector(63 downto 0);
      full       : out std_logic;
      empty      : out std_logic;
      data_count : out std_logic_vector(5 downto 0);
      prog_full  : out std_logic);
  end component;

  -- memory controller parameters
  constant BANK_WIDTH            : integer := 3;  -- # of memory bank addr bits.
  constant CKE_WIDTH             : integer := 1;  -- # of memory clock enable outputs.
  constant CLK_WIDTH             : integer := 1;  -- # of clock outputs.
  constant COL_WIDTH             : integer := 10;  -- # of memory column bits.
  constant CS_NUM                : integer := 1;  -- # of separate memory chip selects.
  constant CS_WIDTH              : integer := 1;  -- # of total memory chip selects.
  constant CS_BITS               : integer := 0;  -- set to log2(CS_NUM) (rounded up).
  constant DM_WIDTH              : integer := 4;  -- # of data mask bits.
  constant DQ_WIDTH              : integer := 32;  -- # of data width.
  constant DQ_PER_DQS            : integer := 8;  -- # of DQ data bits per strobe.
  constant DQS_WIDTH             : integer := 4;  -- # of DQS strobes.
  constant DQ_BITS               : integer := 5;  -- set to log2(DQS_WIDTH*DQ_PER_DQS).
  constant DQS_BITS              : integer := 2;  -- set to log2(DQS_WIDTH).
  constant ODT_WIDTH             : integer := 1;  -- # of memory on-die term enables.
  constant ROW_WIDTH             : integer := 14;  -- # of memory row and # of addr bits.
  constant ADDITIVE_LAT          : integer := 0;  -- additive write latency.
  constant BURST_LEN             : integer := 4;  -- burst length (in double words).
  constant BURST_TYPE            : integer := 0;  -- burst type (=0 seq; =1 interleaved).
  constant CAS_LAT               : integer := 3;  -- CAS latency.
  constant ECC_ENABLE            : integer := 0;  -- enable ECC (=1 enable).
  constant APPDATA_WIDTH         : integer := 64;  -- # of usr read/write data bus bits.
  constant MULTI_BANK_EN         : integer := 1;  -- Keeps multiple banks open. (= 1 enable).
  constant TWO_T_TIME_EN         : integer := 0;  -- 2t timing for unbuffered dimms.
  constant ODT_TYPE              : integer := 3;  -- ODT (=0(none),=1(75),=2(150),=3(50)).
  constant REDUCE_DRV            : integer := 0;  -- reduced strength mem I/O (=1 yes).
  constant REG_ENABLE            : integer := 0;  -- registered addr/ctrl (=1 yes).
  constant TREFI_NS              : integer := 7800;  -- auto refresh interval (ns).
  constant TRAS                  : integer := 40000;  -- active->precharge delay.
  constant TRCD                  : integer := 15000;  -- active->read/write delay.
  constant TRFC                  : integer := 197500;  -- refresh->refresh, refresh->active delay.
  constant TRP                   : integer := 15000;  -- precharge->command delay.
  constant TRTP                  : integer := 7500;  -- read->precharge delay.
  constant TWR                   : integer := 15000;  -- used to determine write->precharge.
  constant TWTR                  : integer := 7500;  -- write->read delay.
  constant HIGH_PERFORMANCE_MODE : boolean := true;
  constant SIM_ONLY              : integer := 0;  -- = 1 to skip SDRAM power up delay.
  constant DEBUG_EN              : integer := 0;  -- Enable debug signals/controls.
  constant CLK_PERIOD            : integer := 5000;  -- Core/Memory clock period (in ps).
  constant DLL_FREQ_MODE         : string  := "HIGH";  -- DCM Frequency range.
  constant CLK_TYPE              : string  := "SINGLE_ENDED";
  constant NOCLK200              : boolean := false;  -- clk200 enable and disable
  constant RST_ACT_LOW           : integer := 1;  -- =1 for active low reset, =0 for active high.
  constant BURST_LEN_DIV2        : integer := BURST_LEN / 2;
  constant CONSECUTIVE_TIME      : integer := 4;  -- consecutive write burst or read burst time.

  type ddr2_state_fsm is (s_init, s_decision, s_bypass_mfifo, s_write_mfifo,
                          s_read_mfifo_pre, s_read_mfifo_data);
  signal ddr2_state : ddr2_state_fsm;

  signal sys_rst_n       : std_logic;
  signal cnt             : std_logic_vector(31 downto 0);
  signal ififo_wr_data   : std_logic_vector(63 downto 0);
  signal ififo_wr_en     : std_logic;
  signal ififo_rd_en     : std_logic;
  signal ififo_rd_data   : std_logic_vector(63 downto 0);
  signal ififo_full      : std_logic;
  signal ififo_prog_full : std_logic;
  signal ififo_empty     : std_logic;
  signal ififo_rd_dcnt   : std_logic_vector(5 downto 0);
  signal ififo_wr_dcnt   : std_logic_vector(5 downto 0);
  signal ofifo_wr_data   : std_logic_vector(63 downto 0);
  signal ofifo_wr_en     : std_logic;
  signal ofifo_rd_en     : std_logic;
  signal ofifo_rd_data   : std_logic_vector(63 downto 0);
  signal ofifo_full      : std_logic;
  signal ofifo_prog_full : std_logic;
  signal ofifo_empty     : std_logic;
  signal ofifo_rd_dcnt   : std_logic_vector(5 downto 0);
  signal ofifo_wr_dcnt   : std_logic_vector(5 downto 0);

  signal phy_init_done     : std_logic;
  signal clk0_tb           : std_logic;
  signal rst0_tb           : std_logic;
  signal app_af_wren       : std_logic;
  signal app_af_wren_r     : std_logic;
  signal app_af_addr       : std_logic_vector(30 downto 0);
  signal app_wr_af_addr    : std_logic_vector(30 downto 0);
  signal app_rd_af_addr    : std_logic_vector(30 downto 0);
  signal app_af_cmd        : std_logic_vector(2 downto 0);
  signal app_af_afull      : std_logic;
  signal app_wdf_wren      : std_logic;
  signal app_wdf_data      : std_logic_vector((APPDATA_WIDTH)-1 downto 0);
  signal app_wdf_mask_data : std_logic_vector((APPDATA_WIDTH/8)-1 downto 0);
  signal app_wdf_afull     : std_logic;
  signal rd_data_valid     : std_logic;
  signal rd_data_fifo_out  : std_logic_vector((APPDATA_WIDTH)-1 downto 0);
  signal mfifo_empty       : std_logic;
  signal mfifo_full        : std_logic;

  constant DDR2_ADDR_SIZE : integer := 8 * 16 * 1024 * 1024;  -- DDR2_SDRAM_IC : MT47H128M16HG-3
  signal   mfifo_cnt      : integer range 0 to DDR2_ADDR_SIZE;
  signal   wrptr          : integer range 0 to (DDR2_ADDR_SIZE-1);
  signal   rdptr          : integer range 0 to (DDR2_ADDR_SIZE-1);

  signal clk_cnt         : integer range 0 to (BURST_LEN_DIV2-1);
  signal consecutive_cnt : integer range 0 to (CONSECUTIVE_TIME-1);
  signal rd_data_cnt     : integer range 0 to ((BURST_LEN_DIV2*CONSECUTIVE_TIME)-1);
  
  
  
begin  -- archi


  sys_rst_n <= not sys_rst;
  rdy       <= phy_init_done and (not rst0_tb);

  fifo_clk      <= clk0_tb;
  ififo_wr_en   <= fifo_wr_en;
  ififo_wr_data <= fifo_wr_data;
  fifo_full     <= ififo_full;
  ofifo_rd_en   <= fifo_rd_en;
  fifo_rd_data  <= ofifo_rd_data;
  fifo_empty    <= ofifo_empty;
  fifo_data_cnt <= cnt;

  app_wdf_mask_data <= (others => '0');


  process (clk0_tb, rst0_tb)
    variable wr : std_logic;
    variable rd : std_logic;
  begin  -- process
    if rst0_tb = '1' then               -- asynchronous reset (active low)
      cnt <= (others => '0');
    elsif clk0_tb'event and clk0_tb = '1' then  -- rising clock edge
      wr := ififo_wr_en and (not ififo_full);
      rd := ofifo_rd_en and (not ofifo_empty);
      if(wr and (not rd)) = '1' then
        cnt <= cnt + '1';
      elsif (rd and (not wr)) = '1' then
        cnt <= cnt - '1';
      else
        cnt <= cnt;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  process (clk0_tb, rst0_tb)
  begin  -- process
    if rst0_tb = '1' then               -- asynchronous reset (active low)
      ddr2_state      <= s_init;
      clk_cnt         <= 0;
      rd_data_cnt     <= 0;
      consecutive_cnt <= 0;
      app_af_wren_r   <= '0';
    elsif clk0_tb'event and clk0_tb = '1' then  -- rising clock edge
      case ddr2_state is
        when s_init =>
          clk_cnt         <= 0;
          rd_data_cnt     <= 0;
          consecutive_cnt <= 0;
          app_af_wren_r   <= '1';
          if phy_init_done = '1' then
            ddr2_state <= s_decision;
          else
            ddr2_state <= s_init;
          end if;
          
        when s_decision =>
          app_af_wren_r <= '1';
          if mfifo_empty = '1' and conv_integer(ififo_rd_dcnt) < (BURST_LEN_DIV2 * CONSECUTIVE_TIME) and ififo_empty = '0' and ofifo_prog_full = '0' then
            ddr2_state <= s_bypass_mfifo;
          elsif conv_integer(ififo_rd_dcnt) >= (BURST_LEN_DIV2 * CONSECUTIVE_TIME) and app_af_afull = '0' and app_wdf_afull = '0' then
            ddr2_state <= s_write_mfifo;
          elsif mfifo_empty = '0' and ofifo_prog_full = '0' and app_af_afull = '0' then
            ddr2_state <= s_read_mfifo_pre;
          else
            ddr2_state <= s_decision;
          end if;
          
        when s_bypass_mfifo =>
          if ififo_empty = '1' or ofifo_prog_full = '1' then
            ddr2_state <= s_decision;
          else
            ddr2_state <= s_bypass_mfifo;
          end if;
          
        when s_write_mfifo =>
          if clk_cnt = BURST_LEN_DIV2-1 then
            clk_cnt <= 0;
            if consecutive_cnt = CONSECUTIVE_TIME-1 then
              consecutive_cnt <= 0;
              app_af_wren_r   <= '0';
              ddr2_state      <= s_decision;
            else
              app_af_wren_r   <= '1';
              consecutive_cnt <= consecutive_cnt + 1;
              ddr2_state      <= s_write_mfifo;
            end if;
          else
            app_af_wren_r <= '0';
            clk_cnt       <= clk_cnt + 1;
            ddr2_state    <= s_write_mfifo;
          end if;
          
        when s_read_mfifo_pre =>
          if consecutive_cnt = CONSECUTIVE_TIME-1 then
            consecutive_cnt <= 0;
            app_af_wren_r   <= '0';
            ddr2_state      <= s_read_mfifo_data;
          else
            consecutive_cnt <= consecutive_cnt + 1;
            app_af_wren_r   <= '1';
            ddr2_state      <= s_read_mfifo_pre;
          end if;
          
        when s_read_mfifo_data =>
          if rd_data_valid = '1' then
            if rd_data_cnt = ((BURST_LEN_DIV2 * CONSECUTIVE_TIME) - 1) then
              rd_data_cnt <= 0;
              ddr2_state  <= s_decision;
            else
              rd_data_cnt <= rd_data_cnt + 1;
              ddr2_state  <= s_read_mfifo_data;
            end if;
          end if;

        when others =>
          ddr2_state <= s_init;
      end case;
    end if;
  end process;


  process (app_af_wren_r, app_rd_af_addr, app_wr_af_addr, ddr2_state,
           ififo_empty, ififo_rd_data, ififo_rd_en, ofifo_prog_full,
           rd_data_fifo_out, rd_data_valid)
  begin  -- process
    case ddr2_state is
      when s_bypass_mfifo =>
        ififo_rd_en   <= (not ififo_empty) and (not ofifo_prog_full);
        app_wdf_wren  <= '0';
        app_wdf_data  <= (others => '0');
        app_af_wren   <= '0';
        app_af_addr   <= (others => '0');
        app_af_cmd    <= "000";
        ofifo_wr_en   <= ififo_rd_en;
        ofifo_wr_data <= ififo_rd_data;

      when s_write_mfifo =>
        ififo_rd_en   <= '1';
        app_wdf_wren  <= '1';
        app_wdf_data  <= ififo_rd_data;
        app_af_wren   <= app_af_wren_r;
        app_af_addr   <= app_wr_af_addr;
        app_af_cmd    <= "000";
        ofifo_wr_en   <= '0';
        ofifo_wr_data <= (others => '0');

      when s_read_mfifo_pre =>
        ififo_rd_en   <= '0';
        app_wdf_wren  <= '0';
        app_wdf_data  <= (others => '0');
        app_af_wren   <= app_af_wren_r;
        app_af_addr   <= app_rd_af_addr;
        app_af_cmd    <= "001";
        ofifo_wr_en   <= '0';
        ofifo_wr_data <= (others => '0');

      when s_read_mfifo_data =>
        ififo_rd_en   <= '0';
        app_wdf_wren  <= '0';
        app_wdf_data  <= (others => '0');
        app_af_wren   <= '0';
        app_af_addr   <= (others => '0');
        app_af_cmd    <= "000";
        ofifo_wr_en   <= rd_data_valid;
        ofifo_wr_data <= rd_data_fifo_out;

      when others =>
        ififo_rd_en   <= '0';
        app_wdf_wren  <= '0';
        app_wdf_data  <= (others => '0');
        app_af_wren   <= '0';
        app_af_addr   <= (others => '0');
        app_af_cmd    <= "000";
        ofifo_wr_en   <= '0';
        ofifo_wr_data <= (others => '0');
    end case;
  end process;



  mfifo_full     <= '1' when mfifo_cnt = DDR2_ADDR_SIZE else '0';
  mfifo_empty    <= '1' when mfifo_cnt = 0              else '0';
  app_wr_af_addr <= conv_std_logic_vector(wrptr, app_wr_af_addr'length);
  app_rd_af_addr <= conv_std_logic_vector(rdptr, app_rd_af_addr'length);



  process (clk0_tb, rst0_tb)
  begin  -- process
    if rst0_tb = '1' then               -- asynchronous reset (active low)
      mfifo_cnt <= 0;
      wrptr     <= 0;
      rdptr     <= 0;
    elsif clk0_tb'event and clk0_tb = '1' then  -- rising clock edge
      if ddr2_state = s_write_mfifo and app_af_wren_r = '1' then
        mfifo_cnt <= mfifo_cnt + BURST_LEN;
        if wrptr = DDR2_ADDR_SIZE - 1 then
          wrptr <= 0;
        else
          wrptr <= wrptr + BURST_LEN;
        end if;
        --elsif ddr2_state = s_read_mfifo_data and rd_data_valid = '1' then
        --  mfifo_cnt <= mfifo_cnt - BURST_LEN_DIV2;
        --  if rdptr = DDR2_ADDR_SIZE - 1 then
        --    rdptr <= 0;
        --  else
        --    rdptr <= rdptr + BURST_LEN_DIV2;
        --  end if;
      elsif ddr2_state = s_read_mfifo_pre and app_af_wren_r = '1' then
        mfifo_cnt <= mfifo_cnt - BURST_LEN;
        if rdptr = DDR2_ADDR_SIZE - 1 then
          rdptr <= 0;
        else
          rdptr <= rdptr + BURST_LEN;
        end if;
      end if;
    end if;
  end process;


  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  ififo : fifo_fwft_32x64_pf16
    port map (
      clk        => clk0_tb,
      rst        => rst0_tb,
      wr_en      => ififo_wr_en,
      din        => ififo_wr_data,
      rd_en      => ififo_rd_en,
      dout       => ififo_rd_data,
      full       => ififo_full,
      empty      => ififo_empty,
      prog_full  => open,
      data_count => ififo_rd_dcnt
      );

  
  ofifo : fifo_fwft_32x64_pf16
    port map (
      clk        => clk0_tb,
      rst        => rst0_tb,
      wr_en      => ofifo_wr_en,
      din        => ofifo_wr_data,
      rd_en      => ofifo_rd_en,
      dout       => ofifo_rd_data,
      full       => open,
      empty      => ofifo_empty,
      prog_full  => ofifo_prog_full,
      data_count => open
      );


  mfifo : ddr2_sdram_mig33
    generic map (
      BANK_WIDTH            => BANK_WIDTH,
      CKE_WIDTH             => CKE_WIDTH,
      CLK_WIDTH             => CLK_WIDTH,
      COL_WIDTH             => COL_WIDTH,
      CS_NUM                => CS_NUM,
      CS_WIDTH              => CS_WIDTH,
      CS_BITS               => CS_BITS,
      DM_WIDTH              => DM_WIDTH,
      DQ_WIDTH              => DQ_WIDTH,
      DQ_PER_DQS            => DQ_PER_DQS,
      DQS_WIDTH             => DQS_WIDTH,
      DQ_BITS               => DQ_BITS,
      DQS_BITS              => DQS_BITS,
      ODT_WIDTH             => ODT_WIDTH,
      ROW_WIDTH             => ROW_WIDTH,
      ADDITIVE_LAT          => ADDITIVE_LAT,
      BURST_LEN             => BURST_LEN,
      BURST_TYPE            => BURST_TYPE,
      CAS_LAT               => CAS_LAT,
      ECC_ENABLE            => ECC_ENABLE,
      APPDATA_WIDTH         => APPDATA_WIDTH,
      MULTI_BANK_EN         => MULTI_BANK_EN,
      TWO_T_TIME_EN         => TWO_T_TIME_EN,
      ODT_TYPE              => ODT_TYPE,
      REDUCE_DRV            => REDUCE_DRV,
      REG_ENABLE            => REG_ENABLE,
      TREFI_NS              => TREFI_NS,
      TRAS                  => TRAS,
      TRCD                  => TRCD,
      TRFC                  => TRFC,
      TRP                   => TRP,
      TRTP                  => TRTP,
      TWR                   => TWR,
      TWTR                  => TWTR,
      HIGH_PERFORMANCE_MODE => HIGH_PERFORMANCE_MODE,
      SIM_ONLY              => SIM_ONLY,
      DEBUG_EN              => DEBUG_EN,
      CLK_PERIOD            => CLK_PERIOD,
      DLL_FREQ_MODE         => DLL_FREQ_MODE,
      CLK_TYPE              => CLK_TYPE,
      NOCLK200              => NOCLK200,
      RST_ACT_LOW           => RST_ACT_LOW)
    port map (
      ddr2_dq           => ddr2_dq,
      ddr2_a            => ddr2_a,
      ddr2_ba           => ddr2_ba,
      ddr2_dm           => ddr2_dm,
      ddr2_dqs          => ddr2_dqs,
      ddr2_dqs_n        => ddr2_dqs_n,
      ddr2_ras_n        => ddr2_ras_n,
      ddr2_cas_n        => ddr2_cas_n,
      ddr2_we_n         => ddr2_we_n,
      ddr2_cs_n         => ddr2_cs_n,
      ddr2_odt          => ddr2_odt,
      ddr2_cke          => ddr2_cke,
      ddr2_ck           => ddr2_ck,
      ddr2_ck_n         => ddr2_ck_n,
      sys_clk           => ddr2_clk,
      idly_clk_200      => idly_clk_200,
      sys_rst_n         => sys_rst_n,
      phy_init_done     => phy_init_done,
      rst0_tb           => rst0_tb,
      clk0_tb           => clk0_tb,
      app_af_wren       => app_af_wren,
      app_af_addr       => app_af_addr,
      app_af_cmd        => app_af_cmd,
      app_af_afull      => app_af_afull,
      app_wdf_wren      => app_wdf_wren,
      app_wdf_data      => app_wdf_data,
      app_wdf_mask_data => app_wdf_mask_data,
      app_wdf_afull     => app_wdf_afull,
      rd_data_valid     => rd_data_valid,
      rd_data_fifo_out  => rd_data_fifo_out
      );


end archi;
