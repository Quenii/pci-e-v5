-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : endpoint_blk_plus_v1_13.vhd
-- Author     :   <Quenii@QUENII-NB>
-- Company    : 
-- Created    : 2014-11-28
-- Last update: 2014-11-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-11-28  1.0      Quenii  Created
-------------------------------------------------------------------------------



entity endpoint_blk_plus_v1_13 is
--  generic(
--    C_XDEVICE := "xc5vlx50t",
--    USE_V5FXT := 0,
--    PCI_EXP_LINK_WIDTH := 4,
--    PCI_EXP_INT_FREQ := 1,
--    PCI_EXP_REF_FREQ := 0,
--    PCI_EXP_TRN_DATA_WIDTH := 64,
--    PCI_EXP_TRN_REM_WIDTH := 8,
--    PCI_EXP_TRN_BUF_AV_WIDTH := 4,
--    PCI_EXP_BAR_HIT_WIDTH := 7,
--    PCI_EXP_FC_HDR_WIDTH := 8,
--    PCI_EXP_FC_DATA_WIDTH := 12,
--    PCI_EXP_CFG_DATA_WIDTH := 32,
--    PCI_EXP_CFG_ADDR_WIDTH := 10,
--    PCI_EXP_CFG_CPLHDR_WIDTH := 48,
--    PCI_EXP_CFG_BUSNUM_WIDTH := 8,
--    PCI_EXP_CFG_DEVNUM_WIDTH := 5,
--    PCI_EXP_CFG_FUNNUM_WIDTH := 3,
--    PCI_EXP_CFG_CAP_WIDTH := 16,
--    PCI_EXP_CFG_WIDTH := 1024,

--    VEN_ID_temp := 32'h000010EE,
--    DEV_ID_temp := 32'h00000007,
--    VEN_ID := VEN_ID_temp[15               : 0],
--    DEV_ID := DEV_ID_temp[15               : 0],
--    REV_ID := 8'h00,
--    CLASS_CODE := 24'h118000,
--    BAR0 := 32'hFFFFE000,
--    BAR1 := 32'hFFE00000,
--    BAR2 := 32'h00000000,
--    BAR3 := 32'h00000000,
--    BAR4 := 32'h00000000,
--    BAR5 := 32'h00000000,
--    CARDBUS_CIS_PTR := 32'h00000000,
--    SUBSYS_VEN_ID_temp := 32'h000010EE,
--    SUBSYS_ID_temp := 32'h00000007,
--    SUBSYS_VEN_ID := SUBSYS_VEN_ID_temp[15 : 0],
--    SUBSYS_ID := SUBSYS_ID_temp[15         : 0],
--    XROM_BAR := 32'hFFF00001,

--    INTR_MSG_NUM := 5'b00000,
--    SLT_IMPL := 0,
--    DEV_PORT_TYPE := 4'b0000,
--    CAP_VER := 4'h1,

--    CAPT_SLT_PWR_LIM_SC := 2'b00,
--    CAPT_SLT_PWR_LIM_VA := 8'h00,
--    PWR_INDI_PRSNT := 0,
--    ATTN_INDI_PRSNT := 0,
--    ATTN_BUTN_PRSNT := 0,
--    EP_L1_ACCPT_LAT := 3'b110,
--    EP_L0s_ACCPT_LAT := 3'b110,
--    EXT_TAG_FLD_SUP := 1,
--    PHANTM_FUNC_SUP := 2'b01,
--    MPS := 3'b010,

--    L1_EXIT_LAT := 3'b111,
--    L0s_EXIT_LAT := 3'b111,
--    ASPM_SUP := 2'b01,
--    MAX_LNK_WDT := 6'b100,
--    MAX_LNK_SPD := 4'b1,

--    ACK_TO := 16'h0204,
--    RPLY_TO := 16'h060d,

--    MSI := 4'b0101,

--    PCI_CONFIG_SPACE_ACCESS := 0,
--    EXT_CONFIG_SPACE_ACCESS := 0,

--    TRM_TLP_DGST_ECRC := 1,
--    FRCE_NOSCRMBL := 0,
--    TWO_PLM_ATOCFGR := 0,

--    PME_SUP := 5'h0,
--    D2_SUP := 0,
--    D1_SUP := 0,
--    AUX_CT := 3'b000,
--    DSI := 0,
--    PME_CLK := 0,
--    PM_CAP_VER := 3'b010,

--    PWR_CON_D0_STATE := 8'h0,
--    CON_SCL_FCTR_D0_STATE := 8'h0,
--    PWR_CON_D1_STATE := 8'h0,
--    CON_SCL_FCTR_D1_STATE := 8'h0,
--    PWR_CON_D2_STATE := 8'h0,
--    CON_SCL_FCTR_D2_STATE := 8'h0,
--    PWR_CON_D3_STATE := 8'h0,
--    CON_SCL_FCTR_D3_STATE := 8'h0,

--    PWR_DIS_D0_STATE := 8'h0,
--    DIS_SCL_FCTR_D0_STATE := 8'h0,
--    PWR_DIS_D1_STATE := 8'h0,
--    DIS_SCL_FCTR_D1_STATE := 8'h0,
--    PWR_DIS_D2_STATE := 8'h0,
--    DIS_SCL_FCTR_D2_STATE := 8'h0,
--    PWR_DIS_D3_STATE := 8'h0,
--    DIS_SCL_FCTR_D3_STATE := 8'h0,

--    CAL_BLK_DISABLE := 0,
--    SWAP_A_B_PAIRS := 0,

--    INFINITECOMPLETIONS := "TRUE",
--    VC0_CREDITS_PH := 8,
--    VC0_CREDITS_NPH := 8,
--    CPL_STREAMING_PRIORITIZE_P_NP := 0,

--    SLOT_CLK := "TRUE",

--    TX_DIFF_BOOST := "TRUE",
--    TXDIFFCTRL := 3'b010,
--    TXBUFDIFFCTRL := 3'b010,
--    TXPREEMPHASIS := 3'b110,
--    GT_Debug_Ports := 0,
--    GTDEBUGPORTS := 0

--    );
  port (

    -- PCI Express Fabric Interface
    pci_exp_txp : out std_logic_vector(PCI_EXP_LINK_WIDTH-1 downto 0);
    pci_exp_txn : out std_logic_vector(PCI_EXP_LINK_WIDTH-1 downto 0);
    pci_exp_rxp : in  std_logic_vector(PCI_EXP_LINK_WIDTH-1 downto 0);
    pci_exp_rxn : in  std_logic_vector(PCI_EXP_LINK_WIDTH-1 downto 0);



    -- Transaction std_logic_vector(TRN) Interface
    trn_clk      : out std_logic;
    trn_reset_n  : out std_logic;
    trn_lnk_up_n : out std_logic;

    -- Tx
    trn_td         : in  std_logic_vector(PCI_EXP_TRN_DATA_WIDTH-1 downto 0);
    trn_trem_n     : in  std_logic_vector(PCI_EXP_TRN_REM_WIDTH-1 downto 0);
    trn_tsof_n     : in  std_logic;
    trn_teof_n     : in  std_logic;
    trn_tsrc_rdy_n : in  std_logic;
    trn_tdst_rdy_n : out std_logic;
    trn_tdst_dsc_n : out std_logic;
    trn_tsrc_dsc_n : in  std_logic;
    trn_terrfwd_n  : in  std_logic;
    trn_tbuf_av    : out std_logic_vector(PCI_EXP_TRN_BUF_AV_WIDTH-1 downto 0);


    -- Rx
    trn_rd               : out std_logic_vector(PCI_EXP_TRN_DATA_WIDTH-1 downto 0);
    trn_rrem_n           : out std_logic_vector(PCI_EXP_TRN_REM_WIDTH-1 downto 0);
    trn_rsof_n           : out std_logic;
    trn_reof_n           : out std_logic;
    trn_rsrc_rdy_n       : out std_logic;
    trn_rsrc_dsc_n       : out std_logic;
    trn_rdst_rdy_n       : in  std_logic;
    trn_rerrfwd_n        : out std_logic;
    trn_rnp_ok_n         : in  std_logic;
    trn_rbar_hit_n       : out std_logic_vector(PCI_EXP_BAR_HIT_WIDTH-1 downto 0);
    trn_rfc_nph_av       : out std_logic_vector(PCI_EXP_FC_HDR_WIDTH-1 downto 0);
    trn_rfc_npd_av       : out std_logic_vector(PCI_EXP_FC_DATA_WIDTH-1 downto 0);
    trn_rfc_ph_av        : out std_logic_vector(PCI_EXP_FC_HDR_WIDTH-1 downto 0);
    trn_rfc_pd_av        : out std_logic_vector(PCI_EXP_FC_DATA_WIDTH-1 downto 0);
    trn_rcpl_streaming_n : in  std_logic;


    -- Host std_logic_vector(CFG) Interface
    cfg_do                 : out std_logic_vector(PCI_EXP_CFG_DATA_WIDTH-1 downto 0);
    cfg_rd_wr_done_n       : out std_logic;
    cfg_di                 : in  std_logic_vector(PCI_EXP_CFG_DATA_WIDTH-1 downto 0);
    cfg_byte_en_n          : in  std_logic_vector(PCI_EXP_CFG_DATA_WIDTH/8-1 downto 0);
    cfg_dwaddr             : in  std_logic_vector(PCI_EXP_CFG_ADDR_WIDTH-1 downto 0);
    cfg_wr_en_n            : in  std_logic;
    cfg_rd_en_n            : in  std_logic;
    cfg_err_cor_n          : in  std_logic;
    cfg_err_ur_n           : in  std_logic;
    cfg_err_ecrc_n         : in  std_logic;
    cfg_err_cpl_timeout_n  : in  std_logic;
    cfg_err_cpl_abort_n    : in  std_logic;
    cfg_err_cpl_unexpect_n : in  std_logic;
    cfg_err_posted_n       : in  std_logic;
    cfg_err_tlp_cpl_header : in  std_logic_vector(PCI_EXP_CFG_CPLHDR_WIDTH-1 downto 0);

    cfg_err_cpl_rdy_n          : out std_logic;
    cfg_err_locked_n           : in  std_logic;
    cfg_interrupt_n            : in  std_logic;
    cfg_interrupt_rdy_n        : out std_logic;
    cfg_interrupt_assert_n     : in  std_logic;
    cfg_interrupt_di           : in  std_logic_vector(7 downto 0);
    cfg_interrupt_do           : out std_logic_vector(7 downto 0);
    cfg_interrupt_mmenable     : out std_logic_vector(2 downto 0);
    cfg_interrupt_msienable    : out std_logic;
    cfg_to_turnoff_n           : out std_logic;
    cfg_pm_wake_n              : in  std_logic;
    cfg_pcie_link_state_n      : out std_logic_vector(2 downto 0);
    cfg_trn_pending_n          : in  std_logic;
    cfg_bus_number             : out std_logic_vector(PCI_EXP_CFG_BUSNUM_WIDTH-1 downto 0);
    cfg_device_number          : out std_logic_vector(PCI_EXP_CFG_DEVNUM_WIDTH-1 downto 0);
    cfg_function_number        : out std_logic_vector(PCI_EXP_CFG_FUNNUM_WIDTH-1 downto 0);
    cfg_dsn                    : in  std_logic_vector(63 downto 0);
    cfg_status                 : out std_logic_vector(PCI_EXP_CFG_CAP_WIDTH-1 downto 0);
    cfg_command                : out std_logic_vector(PCI_EXP_CFG_CAP_WIDTH-1 downto 0);
    cfg_dstatus                : out std_logic_vector(PCI_EXP_CFG_CAP_WIDTH-1 downto 0);
    cfg_dcommand               : out std_logic_vector(PCI_EXP_CFG_CAP_WIDTH-1 downto 0);
    cfg_lstatus                : out std_logic_vector(PCI_EXP_CFG_CAP_WIDTH-1 downto 0);
    cfg_lcommand               : out std_logic_vector(PCI_EXP_CFG_CAP_WIDTH-1 downto 0);
    fast_train_simulation_only : in  std_logic;

    -- System (SYS) Interface
    sys_clk     : in  std_logic;
    refclkout   : out std_logic;
    sys_reset_n : in  std_logic
    );  
end endpoint_blk_plus_v1_13;
