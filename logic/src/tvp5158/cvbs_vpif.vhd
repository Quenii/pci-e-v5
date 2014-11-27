-------------------------------------------------------------------------------
-- Title      : cvbs_vpif
-- Project    : 
-------------------------------------------------------------------------------
-- File       : cvbs_vpif.vhd
-- Author     :   <Administrator@GUOYONGDONG>
-- Company    : 
-- Created    : 2012-09-24
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
-- 2012-09-24  1.0      Administrator   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity cvbs_vpif is
  port (
    rst_i           : in  std_logic;
    sys_clk_i       : in  std_logic;    -- 40MHz
    -- TVP5158 Interface
    cvbs_clk_i      : in  std_logic;
    cvbs_dvo_a_i    : in  std_logic_vector(7 downto 0);
    cvbs_dvo_b_i    : in  std_logic_vector(7 downto 0);
    tvp5158_rst_n_o : out std_logic;
    tvp5158_irq_i   : in  std_logic;
    -- DSP VPIF Interface
    vpif_clkin0_o   : out std_logic;
    vpif_din_o      : out std_logic_vector(15 downto 0)
    );
end cvbs_vpif;

architecture archi of cvbs_vpif is
  signal sys_clk        : std_logic;
  signal rst            : std_logic;
  signal tvp_rst        : std_logic;
  signal cvbs_clk_ibufg : std_logic;
  signal cvbs_clk       : std_logic;
  signal cvbs_dvo_a_r   : std_logic_vector(7 downto 0);
  signal cvbs_dvo_b_r   : std_logic_vector(7 downto 0);

  constant tvp_rst_cnt_max : integer := 40000*200;  -- 40000/40MHz = 1ms
  signal   tvp_rst_cnt     : integer range tvp_rst_cnt_max downto 0;

  attribute IOB : string;
  

begin  -- archi


  rst     <= rst_i;
  sys_clk <= sys_clk_i;


  process (sys_clk, rst)
  begin  -- process
    if rst = '1' then
      tvp_rst_cnt <= 0;
      tvp_rst     <= '1';
    elsif sys_clk'event and sys_clk = '1' then  -- rising clock edge
      if tvp_rst_cnt /= tvp_rst_cnt_max then
        tvp_rst_cnt <= tvp_rst_cnt + 1;
        tvp_rst     <= tvp_rst;
      else
        tvp_rst_cnt <= tvp_rst_cnt;
        tvp_rst     <= '0';
      end if;
    end if;
  end process;

  tvp5158_rst_n_o <= not tvp_rst;


  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  CVBS_IBUFG_INST : IBUFG
    port map (
      I => cvbs_clk_i,
      O => cvbs_clk_ibufg
      );

  CVBS_BUFG_INST : BUFG
    port map (
      I => cvbs_clk_ibufg,
      O => cvbs_clk
      );

  vpif_clkin0_o <= cvbs_clk;


  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  gen_ff1 : for i in 0 to 7 generate
    attribute IOB of u_ff_cvbs1 : label is "force";
  begin
    u_ff_cvbs1 : FDCE
      generic map (INIT => '0')
      port map (
        C   => cvbs_clk,
        D   => cvbs_dvo_a_i(i),
        Q   => cvbs_dvo_a_r(i),
        CE  => '1',
        CLR => '0'
        );
  end generate;

  gen_ff2 : for i in 0 to 7 generate
    attribute IOB of u_ff_cvbs2 : label is "force";
  begin
    u_ff_cvbs2 : FDCE
      generic map (INIT => '0')
      port map (
        C   => cvbs_clk,
        D   => cvbs_dvo_b_i(i),
        Q   => cvbs_dvo_b_r(i),
        CE  => '1',
        CLR => '0'
        );
  end generate;


  gen_ff3 : for i in 0 to 7 generate
    attribute IOB of u_ff_vpif1 : label is "force";
  begin
    u_ff_vpif1 : FDCE
      generic map (INIT => '0')
      port map (
        C   => cvbs_clk,
        D   => cvbs_dvo_a_r(i),
        Q   => vpif_din_o(i),
        CE  => '1',
        CLR => '0'
        );
  end generate;

  gen_ff4 : for i in 0 to 7 generate
    attribute IOB of u_ff_vpif2 : label is "force";
  begin
    u_ff_vpif2 : FDCE
      generic map (INIT => '0')
      port map (
        C   => cvbs_clk,
        D   => cvbs_dvo_b_r(i),
        Q   => vpif_din_o(i+8),
        CE  => '1',
        CLR => '0'
        );
  end generate;

  

end archi;
