-------------------------------------------------------------------------------
-- Title      : top
-- Project    : 
-------------------------------------------------------------------------------
-- File       : top.vhd
-- Author     :   <Administrator@GUOYONGDONG>
-- Company    : 
-- Created    : 2012-08-10
-- Last update: 2012-09-24
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-08-10  1.0      Administrator   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity top is
  port (
    clk33m_i        : in    std_logic;
    fpga_refclk_p   : in    std_logic;  -- 100MHz
    fpga_refclk_n   : in    std_logic;
    rst_n_i         : in    std_logic;
    -- TVP5158 Interface
--    cvbs_clk_i      : in    std_logic;
--    cvbs_dvo_a_i    : in    std_logic_vector(7 downto 0);
--    cvbs_dvo_b_i    : in    std_logic_vector(7 downto 0);
--    tvp5158_rst_n_o : out   std_logic;
--    tvp5158_irq_i   : in    std_logic;
--    -- DSP VPIF Interface
--    vpif_clkin0_o   : out   std_logic;
--    vpif_din_o      : out   std_logic_vector(15 downto 0);
--    -- DSP EMIF Interface
--    emif_d          : in    std_logic_vector(15 downto 0);
--    emif_a          : in    std_logic_vector(19 downto 0);
--    emif_ba         : in    std_logic_vector(1 downto 0);
--    emif_dqm_n      : in    std_logic_vector(1 downto 0);
--    emif_cs_n       : in    std_logic_vector(5 downto 2);
--    emif_r_nw       : in    std_logic;
--    emif_we_n       : in    std_logic;
--    emif_oe_n       : in    std_logic;
--    emif_wait0      : in    std_logic;
    -- PCI Express Interface
    PCIE_REFCLKP    : in    std_logic;  -- Reference Clock (differential pair) for PCI Express
    PCIE_REFCLKN    : in    std_logic;  -- Reference Clock (differential pair) for PCI Express
    pci_exp_txp     : out   std_logic_vector(3 downto 0);  -- Transmitter differential pair, Lane 0/1/2/3
    pci_exp_txn     : out   std_logic_vector(3 downto 0);  -- Transmitter differential pair, Lane 0/1/2/3
    pci_exp_rxp     : in    std_logic_vector(3 downto 0);  -- Receiver differential pair, Lane 0/1/2/3
    pci_exp_rxn     : in    std_logic_vector(3 downto 0);  -- Receiver differential pair, Lane 0/1/2/3
    -- ddr2 sdram interface
--    ddr2_dq         : inout std_logic_vector(31 downto 0);
--    ddr2_a          : out   std_logic_vector(13 downto 0);
--    ddr2_ba         : out   std_logic_vector(2 downto 0);
--    ddr2_dm         : out   std_logic_vector(3 downto 0);
--    ddr2_dqs        : inout std_logic_vector(3 downto 0);
--    ddr2_dqs_n      : inout std_logic_vector(3 downto 0);
--    ddr2_ras_n      : out   std_logic;
--    ddr2_cas_n      : out   std_logic;
--    ddr2_we_n       : out   std_logic;
--    ddr2_cs_n       : out   std_logic_vector(0 downto 0);
--    ddr2_odt        : out   std_logic_vector(0 downto 0);
--    ddr2_cke        : out   std_logic_vector(0 downto 0);
--    ddr2_ck         : out   std_logic_vector(0 downto 0);
--    ddr2_ck_n       : out   std_logic_vector(0 downto 0);
    -- LED Interface
    led_n_o         : out   std_logic_vector(5 downto 1)
    );
end top;

architecture archi of top is

  component fifo_fwft_256x16
    port (
      rst    : in  std_logic;
      wr_clk : in  std_logic;
      rd_clk : in  std_logic;
      din    : in  std_logic_vector(15 downto 0);
      wr_en  : in  std_logic;
      rd_en  : in  std_logic;
      dout   : out std_logic_vector(63 downto 0);
      full   : out std_logic;
      empty  : out std_logic);
  end component;
  component fifo_fwft_64x64
    port (
      rst    : in  std_logic;
      wr_clk : in  std_logic;
      rd_clk : in  std_logic;
      din    : in  std_logic_vector(63 downto 0);
      wr_en  : in  std_logic;
      rd_en  : in  std_logic;
      dout   : out std_logic_vector(63 downto 0);
      full   : out std_logic;
      empty  : out std_logic);
  end component;

  signal sys_clk  : std_logic;
  signal clk_200m : std_logic;
  signal i2c_clk  : std_logic;
  signal sys_rst  : std_logic;

  signal fifo1_rst : std_logic;
  signal wr_clk    : std_logic;
  signal wr_en     : std_logic;
  signal din       : std_logic_vector(15 downto 0);
  signal rd_clk    : std_logic;
  signal rd_en     : std_logic;
  signal dout      : std_logic_vector(63 downto 0);
  signal full      : std_logic;
  signal empty     : std_logic;

  signal ddr2_rst           : std_logic;
  signal ddr2_rdy           : std_logic;
  signal ddr2_fifo_clk      : std_logic;
  signal ddr2_fifo_wr_en    : std_logic;
  signal ddr2_fifo_wr_data  : std_logic_vector(63 downto 0);
  signal ddr2_fifo_full     : std_logic;
  signal ddr2_fifo_rd_en    : std_logic;
  signal ddr2_fifo_rd_data  : std_logic_vector(63 downto 0);
  signal ddr2_fifo_empty    : std_logic;
  signal ddr2_fifo_data_cnt : std_logic_vector(31 downto 0);

  signal cdc_fifo_rst     : std_logic;
  signal cdc_fifo_wr_clk  : std_logic;
  signal cdc_fifo_wr_en   : std_logic;
  signal cdc_fifo_wr_data : std_logic_vector(63 downto 0);
  signal cdc_fifo_rd_clk  : std_logic;
  signal cdc_fifo_rd_en   : std_logic;
  signal cdc_fifo_rd_data : std_logic_vector(63 downto 0);
  signal cdc_fifo_full    : std_logic;
  signal cdc_fifo_empty   : std_logic;

  signal pcie_rst_n            : std_logic;
  signal pcie_trn_clk          : std_logic;
  signal pcie_link_up_n        : std_logic;
  signal pcie_usfifo_wr_en     : std_logic;
  signal pcie_usfifo_wr_data   : std_logic_vector(63 downto 0);
  signal pcie_usfifo_prog_full : std_logic;
  signal pcie_dsfifo_rd_en     : std_logic;
  signal pcie_dsfifo_rd_data   : std_logic_vector(63 downto 0);
  signal pcie_dsfifo_empty     : std_logic;

  signal emif_d_r1    : std_logic_vector(15 downto 0);
  signal emif_d_r2    : std_logic_vector(15 downto 0);
  signal emif_a_r1    : std_logic_vector(19 downto 0);
  signal emif_a_r2    : std_logic_vector(19 downto 0);
  signal emif_cs_n_r1 : std_logic_vector(5 downto 2);
  signal emif_cs_n_r2 : std_logic_vector(5 downto 2);
  signal emif_ba_r1   : std_logic_vector(1 downto 0);
  signal emif_ba_r2   : std_logic_vector(1 downto 0);
  signal emif_r_nw_r1 : std_logic;
  signal emif_r_nw_r2 : std_logic;
  signal emif_we_n_r1 : std_logic;
  signal emif_we_n_r2 : std_logic;
  signal emif_we_n_r3 : std_logic;
  signal emif_oe_n_r1 : std_logic;
  signal emif_oe_n_r2 : std_logic;

  constant ddr2_rst_cnt_max      : integer := 40000*20;  -- 40000/40MHz = 1ms
  constant ddr2_rst_cnt_max_div2 : integer := ddr2_rst_cnt_max / 2;
  signal   ddr2_rst_cnt          : integer range 0 to ddr2_rst_cnt_max;

  constant test_cnt_max : integer := 101;
  signal   test_cnt     : integer range 0 to test_cnt_max;

  
begin  -- archi

  
  led_n_o(1)          <= pcie_link_up_n;
  led_n_o(2)          <= sys_rst;
  
  clk_rst_inst : entity work.clk_rst_pro
    port map (
      rst_i      => not rst_n_i,
      clk33m_i   => clk33m_i,
      clk_p_i    => fpga_refclk_p,
      clk_n_i    => fpga_refclk_n,
      sys_clk_o  => sys_clk,            -- 40MHz
      clk_200m_o => clk_200m,           -- 200MHz
      i2c_clk_o  => i2c_clk,            -- 1MHz
      sys_rst_o  => sys_rst
      );


 -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  fifo1_rst <= sys_rst or (not ddr2_rdy);

  fifo_inst1 : fifo_fwft_256x16
    port map (
      rst    => fifo1_rst,
      wr_clk => clk_200m,
      wr_en  => wr_en,
      din    => din,
      rd_clk => rd_clk,
      rd_en  => rd_en,
      dout   => dout,
      full   => full,
      empty  => empty
      );

  rd_clk            <= ddr2_fifo_clk;
  rd_en             <= (not empty) and (not ddr2_fifo_full);
  ddr2_fifo_wr_en   <= rd_en;
  ddr2_fifo_wr_data <= dout(15 downto 0) & dout(31 downto 16) &
                       dout(47 downto 32) & dout(63 downto 48);

  
  process (clk_200m, fifo1_rst)
  begin  -- process
    if fifo1_rst = '1' then             -- asynchronous reset (active low)
      led_n_o(5) <= '1';
    elsif clk_200m'event and clk_200m = '1' then  -- rising clock edge
      if full = '1' then
        led_n_o(5) <= '0';
      end if;
    end if;
  end process;


  -----------------------------------------------------------------------------
  -- test ddr2 sdram
  -----------------------------------------------------------------------------

  --process (ddr2_fifo_clk, sys_rst)
  --begin  -- process
  --  if sys_rst = '1' then
  --    test_cnt          <= 0;
  --    ddr2_fifo_wr_en   <= '0';
  --    ddr2_fifo_wr_data <= (others => '0');
  --  elsif rising_edge(ddr2_fifo_clk) then
  --    if ddr2_rdy = '1' then
  --      if test_cnt = test_cnt_max then
  --        test_cnt          <= test_cnt;
  --        ddr2_fifo_wr_en   <= '0';
  --        ddr2_fifo_wr_data <= (others => '0');
  --      else
  --        test_cnt          <= test_cnt + 1;
  --        ddr2_fifo_wr_en   <= '1';
  --        ddr2_fifo_wr_data <= ddr2_fifo_wr_data + '1';
  --      end if;
  --    end if;
  --  end if;
  --end process;

  --ddr2_fifo_rd_en <= (not ddr2_fifo_empty) when test_cnt = test_cnt_max else '0';

  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  process (sys_clk, sys_rst)
  begin  -- process
    if sys_rst = '1' then               -- asynchronous reset (active low)
      ddr2_rst     <= '1';
      ddr2_rst_cnt <= 0;
    elsif sys_clk'event and sys_clk = '1' then  -- rising clock edge
      if ddr2_rst_cnt = ddr2_rst_cnt_max then
        ddr2_rst_cnt <= ddr2_rst_cnt;
        ddr2_rst     <= '0';
      elsif ddr2_rst_cnt_max_div2 < ddr2_rst_cnt and ddr2_rst_cnt < ddr2_rst_cnt_max then
        ddr2_rst_cnt <= ddr2_rst_cnt + 1;
        ddr2_rst     <= '1';
      elsif ddr2_rst_cnt <= ddr2_rst_cnt_max_div2 then
        ddr2_rst_cnt <= ddr2_rst_cnt + 1;
        ddr2_rst     <= '0';
      end if;
    end if;
  end process;

  --ddr2_rst <= sys_rst;

--  ddr2_sdram_wrapper_inst : entity work.ddr2_sdram_wrapper
--    port map (
--      sys_rst       => ddr2_rst,
--      fifo_clk      => ddr2_fifo_clk,
--      fifo_wr_en    => ddr2_fifo_wr_en,
--      fifo_wr_data  => ddr2_fifo_wr_data,
--      fifo_full     => ddr2_fifo_full,
--      fifo_rd_en    => ddr2_fifo_rd_en,
--      fifo_rd_data  => ddr2_fifo_rd_data,
--      fifo_empty    => ddr2_fifo_empty,
--      fifo_data_cnt => ddr2_fifo_data_cnt,
--      ddr2_clk      => clk_200m,
--      idly_clk_200  => clk_200m,
--      rdy           => ddr2_rdy,
--      ddr2_dq       => ddr2_dq,
--      ddr2_a        => ddr2_a,
--      ddr2_ba       => ddr2_ba,
--      ddr2_dm       => ddr2_dm,
--      ddr2_dqs      => ddr2_dqs,
--      ddr2_dqs_n    => ddr2_dqs_n,
--      ddr2_ras_n    => ddr2_ras_n,
--      ddr2_cas_n    => ddr2_cas_n,
--      ddr2_we_n     => ddr2_we_n,
--      ddr2_cs_n     => ddr2_cs_n,
--      ddr2_odt      => ddr2_odt,
--      ddr2_cke      => ddr2_cke,
--      ddr2_ck       => ddr2_ck,
--      ddr2_ck_n     => ddr2_ck_n
--      );




  cdc_fifo_rst     <= sys_rst;
  cdc_fifo_wr_clk  <= sys_clk; -- ddr2_fifo_clk;
  ddr2_fifo_rd_en  <= (not ddr2_fifo_empty) and (not cdc_fifo_full);
  cdc_fifo_wr_en   <= not cdc_fifo_full;
--  cdc_fifo_wr_data <= ddr2_fifo_rd_data;
  process (cdc_fifo_wr_clk, cdc_fifo_rst)
  begin
    if (cdc_fifo_rst = '1') then
      cdc_fifo_wr_data <= (others => '0');
    elsif (rising_edge(cdc_fifo_wr_clk)) then
		if cdc_fifo_wr_en = '1' then
			cdc_fifo_wr_data <= cdc_fifo_wr_data + '1';
		end if;
    end if;
  end process;

  fifo_inst2 : fifo_fwft_64x64
    port map (
      rst    => cdc_fifo_rst,
      wr_clk => cdc_fifo_wr_clk,
      wr_en  => cdc_fifo_wr_en,
      din    => cdc_fifo_wr_data,
      rd_clk => cdc_fifo_rd_clk,
      rd_en  => cdc_fifo_rd_en,
      dout   => cdc_fifo_rd_data,
      full   => cdc_fifo_full,
      empty  => cdc_fifo_empty
      );

  cdc_fifo_rd_clk     <= pcie_trn_clk;
  cdc_fifo_rd_en      <= (not cdc_fifo_empty) and (not pcie_usfifo_prog_full);
  pcie_usfifo_wr_en   <= cdc_fifo_rd_en;
  pcie_usfifo_wr_data <= cdc_fifo_rd_data;




  pcie_rst_n <= not sys_rst;

  pcie_dma_top_inst : entity work.pcie_dma_top
    port map(
      PCIE_REFCLKP           => PCIE_REFCLKP,
      PCIE_REFCLKN           => PCIE_REFCLKN,
      pci_exp_txp            => pci_exp_txp,
      pci_exp_txn            => pci_exp_txn,
      pci_exp_rxp            => pci_exp_rxp,
      pci_exp_rxn            => pci_exp_rxn,
      PERSTN                 => pcie_rst_n,
      USER_LED0              => pcie_link_up_n,
      USER_LED1              => led_n_o(3),
      USER_LED2              => led_n_o(4),
      pcie_trn_clk           => pcie_trn_clk,
      fifo_wrreq_pcie_us     => pcie_usfifo_wr_en,
      fifo_data_pcie_us      => pcie_usfifo_wr_data,
      fifo_prog_full_pcie_us => pcie_usfifo_prog_full,
      fifo_rdreq_pcie_ds     => '0',
      fifo_q_pcie_ds         => open,
      fifo_empty_pcie_ds     => open,
      record_en              => open
      );


end archi;
