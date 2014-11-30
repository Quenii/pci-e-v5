----------------------------------------------------------------------------------------------
--
-- Generated by X-HDL Verilog Translator - Version 2.0.0 Feb. 1, 2011
-- ?? ??? 28 2014 09:46:45
--
--      Input file      : 
--      Component name  : pcie_dma_top
--      Author          : 
--      Company         : 
--
--      Description     : 
--
--
----------------------------------------------------------------------------------------------

LIBRARY ieee;
   USE ieee.std_logic_1164.all;


ENTITY pcie_dma_top IS
   GENERIC (
      tDLY                    : INTEGER := 0
   );
   PORT (
      
      PCIE_REFCLKP            : IN STD_LOGIC;
      PCIE_REFCLKN            : IN STD_LOGIC;
      PERSTN                  : IN STD_LOGIC;
      
      USER_LED               : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      
      pci_exp_txp             : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      pci_exp_txn             : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      pci_exp_rxp             : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      pci_exp_rxn             : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      
      pcie_trn_clk            : OUT STD_LOGIC;
      fifo_wrreq_pcie_us      : IN STD_LOGIC;
      fifo_data_pcie_us       : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      fifo_prog_full_pcie_us  : OUT STD_LOGIC;
      fifo_rdreq_pcie_ds      : IN STD_LOGIC;
      fifo_q_pcie_ds          : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      fifo_empty_pcie_ds      : OUT STD_LOGIC;
      
      record_en               : OUT STD_LOGIC
   );
END ENTITY pcie_dma_top;

ARCHITECTURE trans OF pcie_dma_top IS
 
component pcie_wrapper IS
   GENERIC (
      tDLY                    : INTEGER := 0
   );
   PORT (
      
      pcie_refclk             : IN STD_LOGIC;
      pcie_us_clk             : IN STD_LOGIC;
      pcie_ds_clk             : IN STD_LOGIC;
      perstn                  : IN STD_LOGIC;
      sys_reset_n             : IN STD_LOGIC;
      pcie_trn_clk            : OUT STD_LOGIC;
      pcie_trn_reset_n        : OUT STD_LOGIC;
      trn_lnk_up_n            : OUT STD_LOGIC;
      
      pci_exp_txp             : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      pci_exp_txn             : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      pci_exp_rxp             : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      pci_exp_rxn             : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      
      b1_w32_w                : OUT STD_LOGIC;
      b1_w32_be               : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      b1_w32_d                : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      b1_w32_a                : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      b1_r32_r                : OUT STD_LOGIC;
      b1_r32_be               : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      b1_r32_a                : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      b1_r32_q                : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      
      sim_error               : IN STD_LOGIC;
      
      sw_reset_n              : OUT STD_LOGIC;
      
      record_en               : OUT STD_LOGIC;
      play_en                 : OUT STD_LOGIC;
      sim_en                  : OUT STD_LOGIC;
      
      fifo_wrreq_pcie_us      : IN STD_LOGIC;
      fifo_data_pcie_us       : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      fifo_prog_full_pcie_us  : OUT STD_LOGIC;
      
      fifo_rdreq_pcie_ds      : IN STD_LOGIC;
      fifo_q_pcie_ds          : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      fifo_empty_pcie_ds      : OUT STD_LOGIC
   );
END component;
 
   SIGNAL hw_reset_n                   : STD_LOGIC;
   SIGNAL sys_reset_n                  : STD_LOGIC;
   
   SIGNAL pcie_refclk                  : STD_LOGIC;
   SIGNAL pcie_trn_reset_n             : STD_LOGIC;
   SIGNAL trn_lnk_up_n                 : STD_LOGIC;
   
   SIGNAL sim_error                    : STD_LOGIC;
   
   SIGNAL sw_reset_n                   : STD_LOGIC;
   
   SIGNAL play_en                      : STD_LOGIC;
   SIGNAL sim_en                       : STD_LOGIC;
   
   -- Declare intermediate signals for referenced outputs
   SIGNAL pci_exp_txp_xhdl4            : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL pci_exp_txn_xhdl3            : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL pcie_trn_clk_xhdl5           : STD_LOGIC;
   SIGNAL fifo_prog_full_pcie_us_xhdl1 : STD_LOGIC;
   SIGNAL fifo_q_pcie_ds_xhdl2         : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL fifo_empty_pcie_ds_xhdl0     : STD_LOGIC;
   SIGNAL record_en_xhdl6              : STD_LOGIC;
BEGIN
   -- Drive referenced outputs
   pci_exp_txp <= pci_exp_txp_xhdl4;
   pci_exp_txn <= pci_exp_txn_xhdl3;
   pcie_trn_clk <= pcie_trn_clk_xhdl5;
   fifo_prog_full_pcie_us <= fifo_prog_full_pcie_us_xhdl1;
   fifo_q_pcie_ds <= fifo_q_pcie_ds_xhdl2;
   fifo_empty_pcie_ds <= fifo_empty_pcie_ds_xhdl0;
   record_en <= record_en_xhdl6;
   
   USER_LED(0) <= trn_lnk_up_n;
   
   USER_LED(1) <= (NOT((record_en_xhdl6 OR play_en)));
   
   USER_LED(2) <= NOT(sim_error);
   
   
   
   clk_rst_wrapper_inst : entity work.clk_rst_wrapper
      PORT MAP (
         pcie_refclkp      => PCIE_REFCLKP,
         pcie_refclkn      => PCIE_REFCLKN,
         perstn            => PERSTN,
         
         sw_reset_n        => sw_reset_n,
         
         pcie_trn_reset_n  => pcie_trn_reset_n,
         
         pcie_refclk       => pcie_refclk,
         
         hw_reset_n        => hw_reset_n,
         sys_reset_n       => sys_reset_n
      );
   
   
   
   pcie_wrapper_inst : pcie_wrapper
      GENERIC MAP (
         tdly  => (tDLY)
      )
      PORT MAP (
         pcie_refclk             => pcie_refclk,
         pcie_us_clk             => pcie_trn_clk_xhdl5,
         pcie_ds_clk             => pcie_trn_clk_xhdl5,
         perstn                  => PERSTN,
         sys_reset_n             => sys_reset_n,
         pcie_trn_clk            => pcie_trn_clk_xhdl5,
         pcie_trn_reset_n        => pcie_trn_reset_n,
         trn_lnk_up_n            => trn_lnk_up_n,
         
         pci_exp_txp             => pci_exp_txp_xhdl4,
         pci_exp_txn             => pci_exp_txn_xhdl3,
         pci_exp_rxp             => pci_exp_rxp,
         pci_exp_rxn             => pci_exp_rxn,
         b1_w32_w                => open,
         b1_w32_be               => open,
         b1_w32_d                => open,
         b1_w32_a                => open,
         b1_r32_r                => open,
         b1_r32_be               => open,
         b1_r32_a                => open,
         b1_r32_q                => "00000000000000000000000000000000",
         
         sim_error               => sim_error,
         
         sw_reset_n              => sw_reset_n,
         
         record_en               => record_en_xhdl6,
         play_en                 => play_en,
         sim_en                  => sim_en,
         
         fifo_wrreq_pcie_us      => fifo_wrreq_pcie_us,
         fifo_data_pcie_us       => fifo_data_pcie_us,
         fifo_prog_full_pcie_us  => fifo_prog_full_pcie_us_xhdl1,
         
         fifo_rdreq_pcie_ds      => fifo_rdreq_pcie_ds,
         fifo_q_pcie_ds          => fifo_q_pcie_ds_xhdl2,
         fifo_empty_pcie_ds      => fifo_empty_pcie_ds_xhdl0
      );
   
END ARCHITECTURE trans;













