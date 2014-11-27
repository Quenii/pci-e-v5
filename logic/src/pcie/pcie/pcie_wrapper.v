///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  pcie_wrapper.v
//  /   /        Date Last Modified: June 15th, 2009 
// /___/   /\    Date Created: Apr 1st, 2009
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT/FXT/TXT
// Purpose: Endpoint Block Plus DMA Initiator Top Level Wrapper.
// Reference:
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2009.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps



module pcie_wrapper
	# (
		parameter	tDLY		= 0									// Simulation delay
	)
	
	(
		// PCI Express Clock and Reset#
		input					pcie_refclk,						// Reference Clock for PCI Express GTP TILE
		input					pcie_us_clk,						// Clock for PCI Express Upstream
		input					pcie_ds_clk,						// Clock for PCI Express Downstream
		input					perstn,								// PCI Express Fundamental reset#
		input					sys_reset_n,						// System Reset# 
		output					pcie_trn_clk,						// Transaction Clock for PCI Express, Rising Edge
		output					pcie_trn_reset_n,					// Transaction Reset# for PCI Express
		output					trn_lnk_up_n,						// Transaction Link Up, Active low
		
		// PCI Express Interface
		output		[3:0]		pci_exp_txp,						// Transmitter differential pair, Lane 0/1/2/3
		output		[3:0]		pci_exp_txn,						// Transmitter differential pair, Lane 0/1/2/3
		input		[3:0]		pci_exp_rxp,						// Receiver differential pair, Lane 0/1/2/3
		input		[3:0]		pci_exp_rxn,						// Receiver differential pair, Lane 0/1/2/3
		
		// B1 Info
		output					b1_w32_w,							// 
		output		[3:0]		b1_w32_be,							// 
		output		[31:0]		b1_w32_d,							// 
		output		[31:0]		b1_w32_a,							// 
		output					b1_r32_r,							// 
		output		[3:0]		b1_r32_be,							// 
		output		[31:0]		b1_r32_a,							// 
		input		[31:0]		b1_r32_q,							// 	
		
		// Status
		input					sim_error,							// Simulator Error Indicator
		
		// Software Reset Register
		output					sw_reset_n,							// Software Reset#
		
		// User Register
		output					record_en,							// Record Enable
		output					play_en,							// Play Enable
		output					sim_en,								// simulator Enable
		
		// FIFO Interface for PCI Express Upstream
		input					fifo_wrreq_pcie_us,					// fifo write request
		input		[63:0]		fifo_data_pcie_us,					// fifo write data
		output					fifo_prog_full_pcie_us,				// fifo programmable full
		
		// FIFO Interface for PCI Express Downstream
		input					fifo_rdreq_pcie_ds,					// fifo read request
		output		[63:0]		fifo_q_pcie_ds,						// fifo read data
		output					fifo_empty_pcie_ds					// fifo empty
);





//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------



//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
// Transmit TRN Interface
wire					trn_tsof_n;					// Transmit Start-of-Frame (SOF), Active low
wire					trn_teof_n;					// Transmit End-of-Frame (EOF), Active low
wire					trn_tsrc_rdy_n;				// Transmit Source Ready, Active low
wire					trn_tdst_rdy_n;				// Transmit Destination Ready, Active low
wire		[7:0]		trn_trem_n;					// Transmit Data Remainder
wire		[63:0]		trn_td;						// Transmit Data
wire					trn_tsrc_dsc_n;				// Transmit Source Discontinue, Active low
wire					trn_tdst_dsc_n;				// Transmit Destination Discontinue, Active low
wire		[3:0]		trn_tbuf_av;				// Transmit Buffers Available		

// Receive TRN Interface
wire					trn_rsof_n;					// Receive Start-of-Frame (SOF), Active low
wire					trn_reof_n;					// Receive End-of-Frame (EOF), Active low
wire					trn_rsrc_rdy_n;				// Receive Source Ready, Active low
wire					trn_rdst_rdy_n;				// Receive Destination Ready, Active low 
wire		[7:0] 		trn_rrem_n;					// Receive Data Remainder
wire		[63:0] 		trn_rd;						// Receive Data
wire					trn_rerrfwd_n; 				// Receive Error Forward, Active low
wire					trn_rsrc_dsc_n; 			// Receive Source Discontinue, Active low
wire					trn_rnp_ok_n; 				// Receive Non-Posted OK, Active low
wire					trn_rcpl_streaming_n; 		// Receive Completion Streaming, Active low
wire		[6:0] 		trn_rbar_hit_n; 			// Receive BAR Hit, Active low
wire		[7:0] 		trn_rfc_ph_av; 				// Receive Posted Header Flow Control Credits Available
wire		[11:0] 		trn_rfc_pd_av; 				// Receive Posted Data Flow Control Credits Available
wire		[7:0] 		trn_rfc_nph_av; 			// Receive Non-Posted Header Flow Control Credits Available
wire		[11:0] 		trn_rfc_npd_av; 			// Receive Non-Posted Data Flow Control Credits Available

// Configuration Interface //
// Configuration Space Access
wire					cfg_wr_en_n;				// Configuration Write Enable, Active low
wire					cfg_rd_en_n;				// Configuration Read Enable, Active low
wire					cfg_rd_wr_done_n;			// Configuration Read Write Done, Active low
wire		[3:0]		cfg_byte_en_n;				// Configuration Byte Enable, Active low
wire		[9:0]		cfg_dwaddr;					// Configuration DWORD Address
wire		[31:0]		cfg_di;						// Configuration Data In
wire		[31:0]		cfg_do;						// Configuration Data Out
// Command and Status Registers
wire		[7:0]		cfg_bus_number;				// Configuration Bus Number
wire		[4:0]		cfg_device_number;			// Configuration Device Number
wire		[2:0]		cfg_function_number;		// Configuration Function Number
wire		[15:0]		cfg_status;					// Configuration Status
wire		[15:0]		cfg_command;				// Configuration Command
wire		[15:0]		cfg_dstatus;				// Configuration Device Status
wire		[15:0]		cfg_dcommand;				// Configuration Device Command
wire		[15:0]		cfg_lstatus;				// Configuration Link Status
wire		[15:0]		cfg_lcommand;				// Configuration Link Command
wire		[63:0]		cfg_dsn;					// Configuration Device Serial Number
// Power Management
wire					cfg_pm_wake_n;				// Configuration Power Management Wake, Active low
wire		[2:0]		cfg_pcie_link_state_n;		// PCI Express Link State
wire					cfg_to_turnoff_n;			// Configuration To Turnoff

// Interrupt Requests
wire		[2:0]		cfg_interrupt_mmenable;		// Configuration Interrupt Multiple Message Enable
wire					cfg_interrupt_msienable;	// Configuration Interrupt MSI Enabled
wire		[7:0]		cfg_interrupt_do;			// Configuration Interrupt Data Out
wire					cfg_interrupt_n;			// Configuration Interrupt, Active low
wire					cfg_interrupt_rdy_n;		// Configuration Interrupt Ready
wire		[7:0]		cfg_interrupt_di;			// Configuration Interrupt Data In
wire					cfg_interrupt_assert_n;		// Configuration Legacy Interrupt Assert/Deassert Select

// User Application Error-Reporting
wire					cfg_err_ecrc_n;				// ECRC Error Report, Active low
wire					cfg_err_ur_n;				// Configuration Error Unsupported Request, Active low
wire					cfg_err_cpl_timeout_n;		// Configuration Error Completion Timeout, Active low
wire					cfg_err_cpl_unexpect_n;		// Configuration Error Completion Unexpected, Active low
wire					cfg_err_cpl_abort_n;		// Configuration Error Completion Aborted, Active low
wire					cfg_err_posted_n;			// Configuration Error Posted, Active low
wire					cfg_err_cor_n;				// Configuration Error Correctable Error, Active low
wire		[47:0]		cfg_err_tlp_cpl_header;		// Configuration Error TLP Completion Header
wire					cfg_err_locked_n;			// Configuration Error Locked, Active low
wire					cfg_err_cpl_rdy_n;			// Configuration Error Completion Ready

wire					cfg_trn_pending_n;			// User Transaction Pending

// Unused 
wire					fast_train_simulation_only;	// 
wire					trn_terrfwd_n;				// 






// Endpoint Block Plus Version 1.13 module
endpoint_blk_plus_v1_13 ep (
	// System Interface Signals
	.sys_reset_n				(perstn),
	.sys_clk					(pcie_refclk),
	.refclkout					(),
	
	// PCI Express Interface
	.pci_exp_txp				(pci_exp_txp),
	.pci_exp_txn				(pci_exp_txn),
	.pci_exp_rxn				(pci_exp_rxn),
	.pci_exp_rxp				(pci_exp_rxp),
	
	// Common TRN Interface
	.trn_clk					(pcie_trn_clk),
	.trn_lnk_up_n				(trn_lnk_up_n),
	.trn_reset_n				(pcie_trn_reset_n),
	
	// Transmit TRN Interface
	.trn_tsof_n					(trn_tsof_n),
	.trn_teof_n					(trn_teof_n),
	.trn_tsrc_rdy_n				(trn_tsrc_rdy_n),
	.trn_tdst_rdy_n				(trn_tdst_rdy_n),
	.trn_trem_n					(trn_trem_n),
	.trn_td						(trn_td),
	.trn_tsrc_dsc_n				(trn_tsrc_dsc_n),
	.trn_tdst_dsc_n				(trn_tdst_dsc_n),
	.trn_tbuf_av				(trn_tbuf_av),
	
	// Receive TRN Interface
	.trn_rsof_n					(trn_rsof_n),
	.trn_reof_n					(trn_reof_n),
	.trn_rsrc_rdy_n				(trn_rsrc_rdy_n),
	.trn_rdst_rdy_n				(trn_rdst_rdy_n),
	.trn_rrem_n					(trn_rrem_n),
	.trn_rd						(trn_rd),
	.trn_rerrfwd_n				(trn_rerrfwd_n),
	.trn_rsrc_dsc_n				(trn_rsrc_dsc_n),
	.trn_rnp_ok_n				(trn_rnp_ok_n),
	.trn_rcpl_streaming_n		(trn_rcpl_streaming_n),
	.trn_rbar_hit_n				(trn_rbar_hit_n),
	.trn_rfc_ph_av				(trn_rfc_ph_av),
	.trn_rfc_pd_av				(trn_rfc_pd_av),
	.trn_rfc_nph_av				(trn_rfc_nph_av),
	.trn_rfc_npd_av				(trn_rfc_npd_av),
	
	// Configuration Interface //
	// Configuration Space Access
	.cfg_wr_en_n				(cfg_wr_en_n),
	.cfg_rd_en_n				(cfg_rd_en_n),
	.cfg_rd_wr_done_n			(cfg_rd_wr_done_n),
	.cfg_byte_en_n				(cfg_byte_en_n),
	.cfg_dwaddr					(cfg_dwaddr),
	.cfg_di						(cfg_di),
	.cfg_do						(cfg_do),
	// Command and Status Registers
	.cfg_bus_number				(cfg_bus_number),
	.cfg_device_number			(cfg_device_number),
	.cfg_function_number		(cfg_function_number),
	.cfg_status					(cfg_status),
	.cfg_command				(cfg_command),
	.cfg_dstatus				(cfg_dstatus),
	.cfg_dcommand				(cfg_dcommand),
	.cfg_lstatus				(cfg_lstatus),
	.cfg_lcommand				(cfg_lcommand),
	.cfg_dsn					(cfg_dsn),
	// Power Management
	.cfg_pm_wake_n				(cfg_pm_wake_n),
	.cfg_pcie_link_state_n		(cfg_pcie_link_state_n),
	.cfg_to_turnoff_n			(cfg_to_turnoff_n),
	
	// Interrupt Requests
	.cfg_interrupt_mmenable		(cfg_interrupt_mmenable),
	.cfg_interrupt_msienable	(cfg_interrupt_msienable),
	.cfg_interrupt_do			(cfg_interrupt_do),
	.cfg_interrupt_n			(cfg_interrupt_n),
	.cfg_interrupt_rdy_n		(cfg_interrupt_rdy_n),
	.cfg_interrupt_di			(cfg_interrupt_di),
	.cfg_interrupt_assert_n		(cfg_interrupt_assert_n),
	
	// User Application Error-Reporting
	.cfg_err_ecrc_n				(cfg_err_ecrc_n),
	.cfg_err_ur_n				(cfg_err_ur_n),
	.cfg_err_cpl_timeout_n		(cfg_err_cpl_timeout_n),
	.cfg_err_cpl_unexpect_n		(cfg_err_cpl_unexpect_n),
	.cfg_err_cpl_abort_n		(cfg_err_cpl_abort_n),
	.cfg_err_posted_n			(cfg_err_posted_n),
	.cfg_err_cor_n				(cfg_err_cor_n),
	.cfg_err_tlp_cpl_header		(cfg_err_tlp_cpl_header),
	.cfg_err_locked_n			(cfg_err_locked_n),
	.cfg_err_cpl_rdy_n			(cfg_err_cpl_rdy_n),
	
	.cfg_trn_pending_n			(cfg_trn_pending_n),
	
	// Unused 
	.fast_train_simulation_only	(fast_train_simulation_only), 
	.trn_terrfwd_n				(trn_terrfwd_n)
);



// PCI Express DMA user application wrapper
pcie_dma_wrapper 
	# (
		.tDLY								(tDLY)
	)
	
	pcie_dma_wrapper_inst
	(
		// Common TRN Interface
		.trn_clk							(pcie_trn_clk),
		.pcie_us_clk						(pcie_us_clk),
		.pcie_ds_clk						(pcie_ds_clk),
		.trn_reset_n						(pcie_trn_reset_n),
		.trn_lnk_up_n						(trn_lnk_up_n),
		.sys_reset_n						(sys_reset_n),
		
		// Transmit TRN Interface
		.trn_tsof_n							(trn_tsof_n),
		.trn_teof_n							(trn_teof_n),
		.trn_tsrc_rdy_n						(trn_tsrc_rdy_n),
		.trn_tdst_rdy_n						(trn_tdst_rdy_n),
		.trn_trem_n							(trn_trem_n),
		.trn_td								(trn_td),
		.trn_tsrc_dsc_n						(trn_tsrc_dsc_n),
		.trn_tdst_dsc_n						(trn_tdst_dsc_n),
		.trn_tbuf_av						(trn_tbuf_av),		
		
		// Receive TRN Interface
		.trn_rsof_n							(trn_rsof_n),
		.trn_reof_n							(trn_reof_n),
		.trn_rsrc_rdy_n						(trn_rsrc_rdy_n),
		.trn_rdst_rdy_n						(trn_rdst_rdy_n),
		.trn_rrem_n							(trn_rrem_n),
		.trn_rd								(trn_rd),
		.trn_rerrfwd_n						(trn_rerrfwd_n),
		.trn_rsrc_dsc_n						(trn_rsrc_dsc_n),
		.trn_rnp_ok_n						(trn_rnp_ok_n),
		.trn_rcpl_streaming_n				(trn_rcpl_streaming_n),
		.trn_rbar_hit_n						(trn_rbar_hit_n),
		.trn_rfc_ph_av						(trn_rfc_ph_av),
		.trn_rfc_pd_av						(trn_rfc_pd_av),
		.trn_rfc_nph_av						(trn_rfc_nph_av),
		.trn_rfc_npd_av						(trn_rfc_npd_av),
		
		// Configuration Interface //
		// Configuration Space Access
		.cfg_wr_en_n						(cfg_wr_en_n),
		.cfg_rd_en_n						(cfg_rd_en_n),
		.cfg_rd_wr_done_n					(cfg_rd_wr_done_n),
		.cfg_byte_en_n						(cfg_byte_en_n),
		.cfg_dwaddr							(cfg_dwaddr),
		.cfg_di								(cfg_di),
		.cfg_do								(cfg_do),
		// Command and Status Registers
		.cfg_bus_number						(cfg_bus_number),
		.cfg_device_number					(cfg_device_number),
		.cfg_function_number				(cfg_function_number),
		.cfg_status							(cfg_status),
		.cfg_command						(cfg_command),
		.cfg_dstatus						(cfg_dstatus),
		.cfg_dcommand						(cfg_dcommand),
		.cfg_lstatus						(cfg_lstatus),
		.cfg_lcommand						(cfg_lcommand),
		.cfg_dsn							(cfg_dsn),
		// Power Management
		.cfg_pm_wake_n						(cfg_pm_wake_n),
		.cfg_pcie_link_state_n				(cfg_pcie_link_state_n),
		.cfg_to_turnoff_n					(cfg_to_turnoff_n),
		
		// Interrupt Requests
		.cfg_interrupt_mmenable				(cfg_interrupt_mmenable),
		.cfg_interrupt_msienable			(cfg_interrupt_msienable),
		.cfg_interrupt_do					(cfg_interrupt_do),
		.cfg_interrupt_n					(cfg_interrupt_n),
		.cfg_interrupt_rdy_n				(cfg_interrupt_rdy_n),
		.cfg_interrupt_di					(cfg_interrupt_di),
		.cfg_interrupt_assert_n				(cfg_interrupt_assert_n),
		
		// User Application Error-Reporting
		.cfg_err_ecrc_n						(cfg_err_ecrc_n),
		.cfg_err_ur_n						(cfg_err_ur_n),
		.cfg_err_cpl_timeout_n				(cfg_err_cpl_timeout_n),
		.cfg_err_cpl_unexpect_n				(cfg_err_cpl_unexpect_n),
		.cfg_err_cpl_abort_n				(cfg_err_cpl_abort_n),
		.cfg_err_posted_n					(cfg_err_posted_n),
		.cfg_err_cor_n						(cfg_err_cor_n),
		.cfg_err_tlp_cpl_header				(cfg_err_tlp_cpl_header),
		.cfg_err_locked_n					(cfg_err_locked_n),
		.cfg_err_cpl_rdy_n					(cfg_err_cpl_rdy_n),
		
		.cfg_trn_pending_n					(cfg_trn_pending_n),
		
		// Unused 
		.fast_train_simulation_only			(fast_train_simulation_only), 
		.trn_terrfwd_n						(trn_terrfwd_n), 
		
		
		// B1 Info
		.b1_w32_w							(b1_w32_w),
		.b1_w32_be							(b1_w32_be),
		.b1_w32_d							(b1_w32_d),
		.b1_w32_a							(b1_w32_a),
		.b1_r32_r							(b1_r32_r),
		.b1_r32_be							(b1_r32_be),
		.b1_r32_a							(b1_r32_a),
		.b1_r32_q							(b1_r32_q),
		
		// Status
		.sim_error							(sim_error),
		
		// Software Reset Register
		.sw_reset_n							(sw_reset_n),
		
		// User Register
		.record_en							(record_en),
		.play_en							(play_en),
		.sim_en								(sim_en),
		
		// FIFO Interface for PCI Express Upstream
		.fifo_wrreq_pcie_us					(fifo_wrreq_pcie_us),
		.fifo_data_pcie_us					(fifo_data_pcie_us),
		.fifo_prog_full_pcie_us				(fifo_prog_full_pcie_us),
		
		// FIFO Interface for PCI Express Downstream
		.fifo_rdreq_pcie_ds					(fifo_rdreq_pcie_ds),
		.fifo_q_pcie_ds						(fifo_q_pcie_ds),
		.fifo_empty_pcie_ds					(fifo_empty_pcie_ds)
	);




endmodule

