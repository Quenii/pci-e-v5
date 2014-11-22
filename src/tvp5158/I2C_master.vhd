-------------------------------------------------------------------------------
-- Title      : I2C_master
-- Project    : 
-------------------------------------------------------------------------------
-- File       : I2C_master.vhd
-- Author     :   <Administrator@GUOYONGDONG>
-- Company    : 
-- Created    : 2011-11-24
-- Last update: 2012-08-21
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-11-24  1.0      GuoYongDong     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity i2c_master is
  port (
    clk_i          : in    std_logic;   -- clk /4 = Fscl
    rst_i          : in    std_logic;
    rdy_o          : out   std_logic;   -- ready signal
    master_start_i : in    std_logic;
    dev_addr_i     : in    std_logic_vector(6 downto 0);  -- Device ID
    sub_addr_i     : in    std_logic_vector(7 downto 0);  -- sub address or register address
    data_i         : in    std_logic_vector(7 downto 0);
    wr_rdn_i       : in    std_logic;   -- '1' for write, '0' for read
    data_o         : out   std_logic_vector(7 downto 0);
    data_valid_o   : out   std_logic;
    err_o          : out   std_logic;
    scl_o          : out   std_logic;
    sda_io         : inout std_logic
    );
end i2c_master;

architecture archi of i2c_master is
  signal sda_in       : std_logic;
  signal sda_out      : std_logic;
  signal sda_en       : std_logic;
  signal clk_cnt      : integer range 0 to 3;
  signal bit_cnt      : integer range 0 to 7;
  signal trans_data   : std_logic_vector(7 downto 0);
  signal read_data    : std_logic_vector(7 downto 0);
  signal master_start : std_logic;
  signal sda_in_reg   : std_logic;

  type fsmstate is (idle, start, trans_dev_addr, recev_dev_ack, trans_reg_addr,
                    recev_reg_ack, trans_reg_data, recev_data_ack, stop, read2_start,
                    read2_dev_addr, read2_dev_ack, read2_reg_data, read2_nack);
  signal i2cstate : fsmstate;

  
begin  -- archi
  

  master_start <= master_start_i;

  sda_io <= sda_out when sda_en = '1' else 'Z';
  sda_in <= sda_io;


  process (clk_i, rst_i)
  begin  -- process
    if rst_i = '1' then                     -- asynchronous reset (active high)
      i2cstate     <= idle;
      scl_o        <= '1';
      sda_out      <= '1';
      sda_en       <= '0';
      rdy_o        <= '0';
      err_o        <= '0';
      trans_data   <= (others => '0');
      clk_cnt      <= 0;
      bit_cnt      <= 0;
      sda_in_reg   <= '0';
      data_valid_o <= '0';
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      case i2cstate is
        when idle =>
          scl_o        <= '1';
          sda_out      <= '1';
          sda_en       <= '0';
          rdy_o        <= '1';
          clk_cnt      <= 0;
          bit_cnt      <= 0;
          data_valid_o <= '0';
          if master_start = '1' then
            rdy_o    <= '0';
            i2cstate <= start;
          else
            i2cstate <= idle;
          end if;
          
        when start =>
          err_o <= '0';
          if clk_cnt = 0 then
            scl_o    <= '1';
            sda_out  <= '0';
            sda_en   <= '1';
            clk_cnt  <= clk_cnt + 1;
            i2cstate <= start;
          else
            scl_o      <= '0';
            sda_out    <= '0';
            sda_en     <= '1';
            clk_cnt    <= 0;
            trans_data <= dev_addr_i & '0';  -- Device ID and write
            i2cstate   <= trans_dev_addr;
          end if;

        when trans_dev_addr =>
          if clk_cnt = 0 then
            scl_o      <= '0';
            sda_out    <= trans_data(7);
            sda_en     <= '1';
            trans_data <= trans_data(6 downto 0) & '0';
            clk_cnt    <= clk_cnt + 1;
          elsif clk_cnt = 1 or clk_cnt = 2 then
            scl_o   <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 3 then
            scl_o   <= '0';
            clk_cnt <= 0;
            if bit_cnt = 7 then
              bit_cnt  <= 0;
              sda_en   <= '0';
              i2cstate <= recev_dev_ack;
            else
              i2cstate <= trans_dev_addr;
              bit_cnt  <= bit_cnt + 1;
            end if;
          end if;

        when recev_dev_ack =>
          sda_en <= '0';
          if clk_cnt = 0 then
            scl_o   <= '0';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 1 then
            scl_o   <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 2 then
            scl_o      <= '1';
            clk_cnt    <= clk_cnt + 1;
            sda_in_reg <= sda_in;
          elsif clk_cnt = 3 then
            scl_o   <= '0';
            clk_cnt <= 0;
            if sda_in_reg = '0' then     -- ack active             
              err_o      <= '0';
              trans_data <= sub_addr_i;  -- register address
              i2cstate   <= trans_reg_addr;
            else
              err_o    <= '1';
              i2cstate <= idle;
            end if;
          end if;
          
        when trans_reg_addr =>
          if clk_cnt = 0 then
            scl_o      <= '0';
            sda_out    <= trans_data(7);
            sda_en     <= '1';
            trans_data <= trans_data(6 downto 0) & '0';
            clk_cnt    <= clk_cnt + 1;
          elsif clk_cnt = 1 or clk_cnt = 2 then
            scl_o   <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 3 then
            scl_o   <= '0';
            clk_cnt <= 0;
            if bit_cnt = 7 then
              bit_cnt  <= 0;
              sda_en   <= '0';
              i2cstate <= recev_reg_ack;
            else
              i2cstate <= trans_reg_addr;
              bit_cnt  <= bit_cnt + 1;
            end if;
          end if;

        when recev_reg_ack =>
          sda_en <= '0';
          if clk_cnt = 0 then
            scl_o   <= '0';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 1 then
            scl_o   <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 2 then
            scl_o      <= '1';
            clk_cnt    <= clk_cnt + 1;
            sda_in_reg <= sda_in;
          elsif clk_cnt = 3 then
            scl_o   <= '0';
            clk_cnt <= 0;
            if sda_in_reg = '0' then    -- ack active              
              err_o <= '0';
              if wr_rdn_i = '1' then    -- i2c write
                trans_data <= data_i;   -- register data
                i2cstate   <= trans_reg_data;
              else
                i2cstate <= read2_start;
              end if;
            else
              err_o    <= '1';
              i2cstate <= idle;
            end if;
          end if;
          
        when trans_reg_data =>
          if clk_cnt = 0 then
            scl_o      <= '0';
            sda_out    <= trans_data(7);
            sda_en     <= '1';
            trans_data <= trans_data(6 downto 0) & '0';
            clk_cnt    <= clk_cnt + 1;
          elsif clk_cnt = 1 or clk_cnt = 2 then
            scl_o   <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 3 then
            scl_o   <= '0';
            clk_cnt <= 0;
            if bit_cnt = 7 then
              bit_cnt  <= 0;
              sda_en   <= '0';
              i2cstate <= recev_data_ack;
            else
              i2cstate <= trans_reg_data;
              bit_cnt  <= bit_cnt + 1;
            end if;
          end if;

        when recev_data_ack =>
          sda_en <= '0';
          if clk_cnt = 0 then
            scl_o   <= '0';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 1 then
            scl_o   <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 2 then
            scl_o      <= '1';
            clk_cnt    <= clk_cnt + 1;
            sda_in_reg <= sda_in;
          elsif clk_cnt = 3 then
            scl_o   <= '0';
            clk_cnt <= 0;
            if sda_in_reg = '0' then    -- ack active
              i2cstate <= stop;
              err_o    <= '0';
            else
              i2cstate <= idle;
              err_o    <= '1';
            end if;
          end if;

        when stop =>
          if clk_cnt = 0 then
            scl_o   <= '0';
            sda_out <= '0';
            sda_en  <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 1 then
            scl_o   <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 2 then
            scl_o    <= '1';
            sda_out  <= '1';
            sda_en   <= '1';
            clk_cnt  <= 0;
            i2cstate <= idle;
          end if;

        when read2_start =>
          if clk_cnt = 0 then
            scl_o   <= '0';
            sda_out <= '1';
            sda_en  <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 1 then
            scl_o   <= '1';
            sda_out <= '1';
            sda_en  <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 2 then
            scl_o   <= '1';
            sda_out <= '0';
            sda_en  <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 3 then
            scl_o      <= '0';
            sda_out    <= '0';
            sda_en     <= '1';
            clk_cnt    <= 0;
            trans_data <= dev_addr_i & '1';  -- Device ID and read
            i2cstate   <= read2_dev_addr;
          end if;

        when read2_dev_addr =>
          if clk_cnt = 0 then
            scl_o      <= '0';
            sda_out    <= trans_data(7);
            sda_en     <= '1';
            trans_data <= trans_data(6 downto 0) & '0';
            clk_cnt    <= clk_cnt + 1;
          elsif clk_cnt = 1 or clk_cnt = 2 then
            scl_o   <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 3 then
            scl_o   <= '0';
            clk_cnt <= 0;
            if bit_cnt = 7 then
              bit_cnt  <= 0;
              sda_en   <= '0';
              i2cstate <= read2_dev_ack;
            else
              i2cstate <= read2_dev_addr;
              bit_cnt  <= bit_cnt + 1;
            end if;
          end if;

        when read2_dev_ack =>
          sda_en <= '0';
          if clk_cnt = 0 then
            scl_o   <= '0';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 1 then
            scl_o   <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 2 then
            scl_o      <= '1';
            clk_cnt    <= clk_cnt + 1;
            sda_in_reg <= sda_in;
          elsif clk_cnt = 3 then
            scl_o   <= '0';
            clk_cnt <= 0;
            if sda_in_reg = '0' then    -- ack active             
              err_o    <= '0';
              i2cstate <= read2_reg_data;
            else
              err_o    <= '1';
              i2cstate <= idle;
            end if;
          end if;

        when read2_reg_data =>
          sda_en <= '0';
          if clk_cnt = 0 then
            scl_o   <= '0';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 1 then
            scl_o   <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 2 then
            scl_o     <= '1';
            clk_cnt   <= clk_cnt + 1;
            read_data <= read_data(6 downto 0) & sda_in;
          elsif clk_cnt = 3 then
            scl_o   <= '0';
            clk_cnt <= 0;
            if bit_cnt = 7 then
              bit_cnt      <= 0;
              data_o       <= read_data;
              data_valid_o <= '1';
              i2cstate     <= read2_nack;
            else
              bit_cnt  <= bit_cnt + 1;
              i2cstate <= read2_reg_data;
            end if;
          end if;

        when read2_nack =>
          if clk_cnt = 0 then
            scl_o   <= '0';
            sda_out <= '1';
            sda_en  <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 1 or clk_cnt = 2 then
            scl_o   <= '1';
            sda_out <= '1';
            sda_en  <= '1';
            clk_cnt <= clk_cnt + 1;
          elsif clk_cnt = 3 then
            scl_o    <= '0';
            sda_out  <= '1';
            sda_en   <= '1';
            clk_cnt  <= 0;
            i2cstate <= stop;
          end if;
          
        when others =>
          i2cstate <= idle;
      end case;
    end if;
  end process;

  
end archi;
