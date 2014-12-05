-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : pcie_dma_top.vhd
-- Author     :   <Administrator@EXTREME-PC>
-- Company    : 
-- Created    : 2014-12-05
-- Last update: 2014-12-05
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-12-05  1.0      Administrator	Created
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;


entity pcie_dma_top is
  generic (
    tDLY : integer := 0
    );
  port (
    PCIE_REFCLK : in std_logic;

--      PCIE_REFCLKP            : IN STD_LOGIC;
--      PCIE_REFCLKN            : IN STD_LOGIC;
    PERSTN : in std_logic;

    USER_LED : out std_logic_vector(2 downto 0);

    pci_exp_txp : out std_logic_vector(3 downto 0);
    pci_exp_txn : out std_logic_vector(3 downto 0);
    pci_exp_rxp : in  std_logic_vector(3 downto 0);
    pci_exp_rxn : in  std_logic_vector(3 downto 0);

    pcie_trn_clk           : out std_logic;
    fifo_wrreq_pcie_us     : in  std_logic;
    fifo_data_pcie_us      : in  std_logic_vector(63 downto 0);
    fifo_prog_full_pcie_us : out std_logic; 
    fifo_overflow_pcie_ds  : out std_logic;
    fifo_rdreq_pcie_ds     : in  std_logic;
    fifo_q_pcie_ds         : out std_logic_vector(63 downto 0);
    fifo_empty_pcie_ds     : out std_logic;

    record_en : out std_logic
    );
end entity pcie_dma_top;

architecture trans of pcie_dma_top is
  
  component pcie_wrapper is
    generic (
      tDLY : integer := 0
      );
    port (

      pcie_refclk      : in  std_logic;
      pcie_us_clk      : in  std_logic;
      pcie_ds_clk      : in  std_logic;
      perstn           : in  std_logic;
      sys_reset_n      : in  std_logic;
      pcie_trn_clk     : out std_logic;
      pcie_trn_reset_n : out std_logic;
      trn_lnk_up_n     : out std_logic;

      pci_exp_txp : out std_logic_vector(3 downto 0);
      pci_exp_txn : out std_logic_vector(3 downto 0);
      pci_exp_rxp : in  std_logic_vector(3 downto 0);
      pci_exp_rxn : in  std_logic_vector(3 downto 0);

      b1_w32_w  : out std_logic;
      b1_w32_be : out std_logic_vector(3 downto 0);
      b1_w32_d  : out std_logic_vector(31 downto 0);
      b1_w32_a  : out std_logic_vector(31 downto 0);
      b1_r32_r  : out std_logic;
      b1_r32_be : out std_logic_vector(3 downto 0);
      b1_r32_a  : out std_logic_vector(31 downto 0);
      b1_r32_q  : in  std_logic_vector(31 downto 0);

      sim_error : in std_logic;

      sw_reset_n : out std_logic;

      record_en : out std_logic;
      play_en   : out std_logic;
      sim_en    : out std_logic;

      fifo_wrreq_pcie_us     : in  std_logic;
      fifo_data_pcie_us      : in  std_logic_vector(63 downto 0);
      fifo_prog_full_pcie_us : out std_logic;
      
      fifo_overflow_pcie_ds  : out std_logic;
      fifo_rdreq_pcie_ds     : in  std_logic;
      fifo_q_pcie_ds         : out std_logic_vector(63 downto 0);
      fifo_empty_pcie_ds     : out std_logic
      );
  end component; 
    
    signal hw_reset_n : std_logic;
  signal sys_reset_n : std_logic;

--   SIGNAL pcie_refclk                  : STD_LOGIC;
  signal pcie_trn_reset_n : std_logic;
  signal trn_lnk_up_n     : std_logic;

  signal sim_error : std_logic;

  signal sw_reset_n : std_logic;

  signal play_en : std_logic;
  signal sim_en  : std_logic;

  -- Declare intermediate signals for referenced outputs
  signal pci_exp_txp_xhdl4            : std_logic_vector(3 downto 0);
  signal pci_exp_txn_xhdl3            : std_logic_vector(3 downto 0);
  signal pcie_trn_clk_xhdl5           : std_logic;
  signal fifo_prog_full_pcie_us_xhdl1 : std_logic;
  signal fifo_q_pcie_ds_xhdl2         : std_logic_vector(63 downto 0);
  signal fifo_empty_pcie_ds_xhdl0     : std_logic;
  signal record_en_xhdl6              : std_logic;
begin
  -- Drive referenced outputs
  pci_exp_txp            <= pci_exp_txp_xhdl4;
  pci_exp_txn            <= pci_exp_txn_xhdl3;
--   pcie_trn_clk <= pcie_trn_clk_xhdl5;
  fifo_prog_full_pcie_us <= fifo_prog_full_pcie_us_xhdl1;
  fifo_q_pcie_ds         <= fifo_q_pcie_ds_xhdl2;
  fifo_empty_pcie_ds     <= fifo_empty_pcie_ds_xhdl0;
  record_en              <= record_en_xhdl6;

  USER_LED(0) <= trn_lnk_up_n;

  USER_LED(1) <= (not((record_en_xhdl6 or play_en)));

  USER_LED(2) <= not(sim_error);



  clk_rst_wrapper_inst : entity work.clk_rst_wrapper
    port map (
--         pcie_refclkp      => PCIE_REFCLKP,
--         pcie_refclkn      => PCIE_REFCLKN,
      perstn => PERSTN,

      sw_reset_n => sw_reset_n,

      pcie_trn_reset_n => pcie_trn_reset_n,

--         pcie_refclk       => pcie_refclk,

      hw_reset_n  => hw_reset_n,
      sys_reset_n => sys_reset_n
      );



  pcie_wrapper_inst : pcie_wrapper
    generic map (
      tdly => (tDLY)
      )
    port map (
      pcie_refclk      => pcie_refclk,
      pcie_us_clk      => pcie_trn_clk_xhdl5,
      pcie_ds_clk      => pcie_trn_clk_xhdl5,
      perstn           => PERSTN,
      sys_reset_n      => sys_reset_n,
      pcie_trn_clk     => pcie_trn_clk_xhdl5,
      pcie_trn_reset_n => pcie_trn_reset_n,
      trn_lnk_up_n     => trn_lnk_up_n,

      pci_exp_txp => pci_exp_txp_xhdl4,
      pci_exp_txn => pci_exp_txn_xhdl3,
      pci_exp_rxp => pci_exp_rxp,
      pci_exp_rxn => pci_exp_rxn,
      b1_w32_w    => open,
      b1_w32_be   => open,
      b1_w32_d    => open,
      b1_w32_a    => open,
      b1_r32_r    => open,
      b1_r32_be   => open,
      b1_r32_a    => open,
      b1_r32_q    => "00000000000000000000000000000000",

      sim_error => sim_error,

      sw_reset_n => sw_reset_n,

      record_en => record_en_xhdl6,
      play_en   => play_en,
      sim_en    => sim_en,

      fifo_wrreq_pcie_us     => fifo_wrreq_pcie_us,
      fifo_data_pcie_us      => fifo_data_pcie_us,
      fifo_prog_full_pcie_us => fifo_prog_full_pcie_us_xhdl1,
      fifo_overflow_pcie_ds  => fifo_overflow_pcie_ds,
      fifo_rdreq_pcie_ds     => fifo_rdreq_pcie_ds,
      fifo_q_pcie_ds         => fifo_q_pcie_ds_xhdl2,
      fifo_empty_pcie_ds     => fifo_empty_pcie_ds_xhdl0
      );

end architecture trans;













