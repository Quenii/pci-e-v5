-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : clk_rst_wrapper.vhd
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
library UNISIM;
use UNISIM.Vcomponents.all;

entity clk_rst_wrapper is
  port (
--      PCIE_REFCLKP      : IN STD_LOGIC;
--      PCIE_REFCLKN      : IN STD_LOGIC;
--      pcie_refclk       : OUT STD_LOGIC;
    PERSTN           : in std_logic;
    sw_reset_n       : in std_logic;
    pcie_trn_reset_n : in std_logic;

    hw_reset_n  : out std_logic;
    sys_reset_n : out std_logic
    );
end entity clk_rst_wrapper;

architecture trans of clk_rst_wrapper is

  -- Declare intermediate signals for referenced outputs
  signal pcie_refclk_xhdl0 : std_logic;
begin
  -- Drive referenced outputs
--   pcie_refclk <= PCIE_REFCLK_I;
  
  hw_reset_n  <= PERSTN;
  sys_reset_n <= (PERSTN and sw_reset_n and pcie_trn_reset_n);

--   
--   
--   pcie_refclk_ibuf : IBUFDS
--      PORT MAP (
--         o   => pcie_refclk_xhdl0,
--         i   => PCIE_REFCLKP,
--         ib  => PCIE_REFCLKN
--      );
  
end architecture trans;






