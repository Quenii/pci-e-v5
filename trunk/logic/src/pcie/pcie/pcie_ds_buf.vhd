-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : pcie_ds_buf.vhd
-- Author     :   <Quenii@QUENII-NB>
-- Company    : 
-- Created    : 2014-11-30
-- Last update: 2014-11-30
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-11-30  1.0      Quenii  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity pcie_ds_buf is
  generic (
    tags : integer := 8
    );

  port (
    -- Common TRN Interface
    pcie_ds_clk : in std_logic;         -- Clock for PCI Express Downstream
    trn_clk     : in std_logic;         -- Transaction Clock; Rising Edge
    trn_reset_n : in std_logic;         -- Transaction Reset; Active low

    -- FIFO Interface for PCI Express Downstream
    fifo_rdy_pcie_ds       : in  std_logic_vector(tags-1 downto 0);  -- fifo write request
    fifo_wrreq_pcie_ds     : in  std_logic_vector(tags-1 downto 0);  -- fifo write request
    fifo_data_pcie_ds      : in  std_logic_vector(63 downto 0);  -- fifo write data
    fifo_rdreq_pcie_ds     : in  std_logic;  -- fifo read request
    fifo_q_pcie_ds         : out std_logic_vector(63 downto 0);  -- fifo write data
    fifo_empty_pcie_ds     : out std_logic;  -- fifo empty
    fifo_prog_full_pcie_ds : out std_logic   -- fifo program full
    );
end pcie_ds_buf;

architecture impl of pcie_ds_buf is

  type ARRAY_64b is array (tags-1 downto 0) of std_logic_vector(63 downto 0);

  component fifo_std_512x64_pf496
    port (
      clk       : in  std_logic;
      rst       : in  std_logic;
      din       : in  std_logic_vector(63 downto 0);
      wr_en     : in  std_logic;
      rd_en     : in  std_logic;
      dout      : out std_logic_vector(63 downto 0);
      full      : out std_logic;
      empty     : out std_logic;
      prog_full : out std_logic);
  end component;

  signal sys_reset : std_logic;
  signal rd_en     : std_logic_vector(tags-1 downto 0);
  signal dout      : ARRAY_64b;
  signal prog_full : std_logic_vector(tags-1 downto 0);
  signal empty     : std_logic_vector(tags-1 downto 0);
begin  -- impl

  sys_reset <= not trn_reset_n;

  GEN_FIFO : for i in 0 to tags-1 generate
    fifo_std_512x64_pf496_1 : fifo_std_512x64_pf496
      port map (
        clk       => trn_clk,
        rst       => sys_reset,
        din       => fifo_data_pcie_ds,
        wr_en     => fifo_wrreq_pcie_ds(i),
        rd_en     => rd_en(i),
        dout      => dout(i),
        full      => open,
        empty     => empty(i),
        prog_full => prog_full(i)
        );
  end generate GEN_FIFO;

  rd_en(0)               <= fifo_rdreq_pcie_ds;
  fifo_empty_pcie_ds     <= empty(0);
  fifo_q_pcie_ds         <= dout(0);
  fifo_prog_full_pcie_ds <= prog_full(0);
  

end impl;
