-------------------------------------------------------------------------------
-- Title      : tvp5158
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tvp5158.vhd
-- Author     :   <Administrator@GUOYONGDONG>
-- Company    : 
-- Created    : 2012-08-21
-- Last update: 2012-09-21
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-08-21  1.0      Administrator   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.Vcomponents.all;

entity tvp5158 is
  port (
    rst_i           : in    std_logic;
    -- i2c interface
    i2c_clk_i       : in    std_logic;  -- 1MHz
    i2c_scl_o       : out   std_logic;
    i2c_sda_io      : inout std_logic;
    -- video interface
    tvp5158_rst_n_o : out   std_logic;
    tvp5158_irq_i   : in    std_logic;
    config_done_o   : out   std_logic
    );
end tvp5158;

architecture archi of tvp5158 is
  component i2c_master
    port (
      clk_i          : in    std_logic;
      rst_i          : in    std_logic;
      rdy_o          : out   std_logic;
      master_start_i : in    std_logic;
      dev_addr_i     : in    std_logic_vector(6 downto 0);
      sub_addr_i     : in    std_logic_vector(7 downto 0);
      data_i         : in    std_logic_vector(7 downto 0);
      wr_rdn_i       : in    std_logic;
      data_o         : out   std_logic_vector(7 downto 0);
      data_valid_o   : out   std_logic;
      err_o          : out   std_logic;
      scl_o          : out   std_logic;
      sda_io         : inout std_logic);
  end component;

  type   fsmstate is (s0, s1, sw1, sw2, sw3, sw4, sw5, sw6, s2, s3, s4, s5, s6);
  signal state : fsmstate;

  signal tvp5158_config_done : std_logic;
  signal i2c_clk             : std_logic;
  signal i2c_rdy             : std_logic;
  signal i2c_start           : std_logic;
  signal dev_addr            : std_logic_vector(6 downto 0);
  signal sub_addr            : std_logic_vector(7 downto 0);
  signal data_in             : std_logic_vector(7 downto 0);
  signal wr_rdn              : std_logic;
  signal data_out            : std_logic_vector(7 downto 0);
  signal data_valid          : std_logic;
  signal i2c_err             : std_logic;
  signal rd_data1            : std_logic_vector(7 downto 0);
  signal rd_data2            : std_logic_vector(7 downto 0);

  attribute KEEP                        : string;
  attribute KEEP of rd_data1            : signal is "TRUE";
  attribute KEEP of rd_data2            : signal is "TRUE";
  attribute KEEP of tvp5158_config_done : signal is "TRUE";

  
begin  -- archi


  tvp5158_rst_n_o <= not rst_i;
  i2c_clk         <= i2c_clk_i;
  config_done_o   <= tvp5158_config_done;


  -----------------------------------------------------------------------------
  --tvp5158 configuration
  -----------------------------------------------------------------------------

  process (i2c_clk, rst_i)
  begin  -- process
    if rst_i = '1' then                 -- asynchronous reset (active low)
      dev_addr            <= (others => '0');
      sub_addr            <= (others => '0');
      wr_rdn              <= '0';
      i2c_start           <= '0';
      state               <= s0;
      rd_data1            <= (others => '0');
      rd_data2            <= (others => '0');
      tvp5158_config_done <= '0';
    elsif i2c_clk'event and i2c_clk = '1' then  -- rising clock edge
      case state is
        when s0 =>
          if i2c_rdy = '1' then
            dev_addr  <= "1011111";     --TVP5158
            sub_addr  <= x"B0";
            data_in   <= x"00";
            wr_rdn    <= '1';
            i2c_start <= '1';
            state     <= s1;
          else
            state <= s0;
          end if;
        when s1 =>
          i2c_start <= '0';
          state     <= sw1;

        when sw1 =>
          if i2c_rdy = '1' then
            dev_addr  <= "1011111";     --TVP5158
            sub_addr  <= x"B1";
            data_in   <= x"16";
            wr_rdn    <= '1';
            i2c_start <= '1';
            state     <= sw2;
          else
            state <= sw1;
          end if;
        when sw2 =>
          i2c_start <= '0';
          state     <= sw3;
          
        when sw3 =>
          if i2c_rdy = '1' then
            dev_addr  <= "1011111";     --TVP5158
            sub_addr  <= x"B2";
            data_in   <= x"25";
            wr_rdn    <= '1';
            i2c_start <= '1';
            state     <= sw4;
          else
            state <= sw3;
          end if;
        when sw4 =>
          i2c_start <= '0';
          state     <= sw5;
          
        when sw5 =>
          if i2c_rdy = '1' then
            dev_addr  <= "1011111";     --TVP5158
            sub_addr  <= x"B3";
            data_in   <= x"E4";
            wr_rdn    <= '1';
            i2c_start <= '1';
            state     <= sw6;
          else
            state <= sw5;
          end if;
        when sw6 =>
          i2c_start <= '0';
          state     <= s2;
          
        when s2 =>
          if i2c_rdy = '1' then
            dev_addr  <= "1011111";     --TVP5158
            sub_addr  <= x"08";
            wr_rdn    <= '0';
            i2c_start <= '1';
            state     <= s3;
          else
            state <= s2;
          end if;
          
        when s3 =>
          i2c_start <= '0';
          if data_valid = '1' then
            rd_data1 <= data_out;
            state    <= s4;
          else
            state <= s3;
          end if;

        when s4 =>
          if i2c_rdy = '1' then
            dev_addr  <= "1011111";     --TVP5158
            sub_addr  <= x"09";
            wr_rdn    <= '0';
            i2c_start <= '1';
            state     <= s5;
          else
            state <= s4;
          end if;

        when s5 =>
          i2c_start <= '0';
          if data_valid = '1' then
            rd_data2 <= data_out;
            state    <= s6;
          else
            state <= s5;
          end if;

        when s6 =>
          tvp5158_config_done <= '1';
          state               <= s6;
          
        when others =>
          state <= s0;
      end case;
    end if;
  end process;



  i2c_master_inst : i2c_master
    port map (
      clk_i          => i2c_clk,
      rst_i          => rst_i,
      rdy_o          => i2c_rdy,
      master_start_i => i2c_start,
      dev_addr_i     => dev_addr,
      sub_addr_i     => sub_addr,
      data_i         => data_in,
      wr_rdn_i       => wr_rdn,
      data_o         => data_out,
      data_valid_o   => data_valid,
      err_o          => i2c_err,
      scl_o          => i2c_scl_o,
      sda_io         => i2c_sda_io
      );


end archi;
