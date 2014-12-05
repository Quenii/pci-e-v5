///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  pcie_dma_wrapper.v
//  /   /        Date Last Modified: June. 15th, 2009
// /___/   /\    Date Created: Apr. 1st, 2009
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT/FXT/TXT
// Purpose: DMA user application wrapper.  Connects the RX Engine, TX engine,
//          Packet Slicer, Interrupt Controller, register file, and misc.
// Reference:
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2009.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps



module pcie_dma_wrapper 
	# (
		parameter 	tags		= 16,
		parameter	tDLY		= 0									// Simulation delay
	)
	
	(
		// Common TRN Interface
		input					trn_clk,							// Transaction Clock, Rising Edge
		input					pcie_us_clk,						// Clock for PCI Express Upstream
		input					pcie_ds_clk,						// Clock for PCI Express Downstream
		input					trn_reset_n,						// Transaction Reset#
		input					trn_lnk_up_n,						// Transaction Link Up, Active low
		input					sys_reset_n,						// System Reset# 
		
		// Transmit TRN Interface
		output					trn_tsof_n,							// Transmit Start-of-Frame (SOF), Active low
		output					trn_teof_n,							// Transmit End-of-Frame (EOF), Active low
		output					trn_tsrc_rdy_n,						// Transmit Source Ready, Active low
		input					trn_tdst_rdy_n,						// Transmit Destination Ready, Active low
		output		[7:0]		trn_trem_n,							// Transmit Data Remainder
		output		[63:0]		trn_td,								// Transmit Data
		output					trn_tsrc_dsc_n,						// Transmit Source Discontinue, Active low
		input					trn_tdst_dsc_n,						// Transmit Destination Discontinue, Active low
		input		[3:0]		trn_tbuf_av,						// Transmit Buffers Available		
		
		// Receive TRN Interface
		input					trn_rsof_n,							// Receive Start-of-Frame (SOF), Active low
		input					trn_reof_n,							// Receive End-of-Frame (EOF), Active low
		input					trn_rsrc_rdy_n,						// Receive Source Ready, Active low
		output					trn_rdst_rdy_n,						// Receive Destination Ready, Active low 
		input		[7:0] 		trn_rrem_n,							// Receive Data Remainder
		input		[63:0] 		trn_rd,								// Receive Data
		input					trn_rerrfwd_n, 						// Receive Error Forward, Active low
		input					trn_rsrc_dsc_n, 					// Receive Source Discontinue, Active low
		output					trn_rnp_ok_n, 						// Receive Non-Posted OK, Active low
		output					trn_rcpl_streaming_n, 				// Receive Completion Streaming, Active low
		input		[6:0] 		trn_rbar_hit_n, 					// Receive BAR Hit, Active low
		input		[7:0] 		trn_rfc_ph_av, 						// Receive Posted Header Flow Control Credits Available
		input		[11:0] 		trn_rfc_pd_av, 						// Receive Posted Data Flow Control Credits Available
		input		[7:0] 		trn_rfc_nph_av, 					// Receive Non-Posted Header Flow Control Credits Available
		input		[11:0] 		trn_rfc_npd_av, 					// Receive Non-Posted Data Flow Control Credits Available
		
		// Configuration Interface //
		// Configuration Space Access
		output					cfg_wr_en_n,						// Configuration Write Enable, Active low
		output					cfg_rd_en_n,						// Configuration Read Enable, Active low
		input					cfg_rd_wr_done_n,					// Configuration Read Write Done, Active low
		output		[3:0]		cfg_byte_en_n,						// Configuration Byte Enable, Active low
		output		[9:0]		cfg_dwaddr,							// Configuration DWORD Address
		output		[31:0]		cfg_di,								// Configuration Data In
		input		[31:0]		cfg_do,								// Configuration Data Out
		// Command and Status Registers
		input		[7:0]		cfg_bus_number,						// Configuration Bus Number
		input		[4:0]		cfg_device_number,					// Configuration Device Number
		input		[2:0]		cfg_function_number,				// Configuration Function Number
		input		[15:0]		cfg_status,							// Configuration Status
		input		[15:0]		cfg_command,						// Configuration Command
		input		[15:0]		cfg_dstatus,						// Configuration Device Status
		input		[15:0]		cfg_dcommand,						// Configuration Device Command
		input		[15:0]		cfg_lstatus,						// Configuration Link Status
		input		[15:0]		cfg_lcommand,						// Configuration Link Command
		output		[63:0]		cfg_dsn,							// Configuration Device Serial Number
		// Power Management
		output					cfg_pm_wake_n,						// Configuration Power Management Wake, Active low
		input		[2:0]		cfg_pcie_link_state_n,				// PCI Express Link State
		input					cfg_to_turnoff_n,					// Configuration To Turnoff
		
		// Interrupt Requests
		input		[2:0]		cfg_interrupt_mmenable,				// Configuration Interrupt Multiple Message Enable
		input					cfg_interrupt_msienable,			// Configuration Interrupt MSI Enabled
		input		[7:0]		cfg_interrupt_do,					// Configuration Interrupt Data Out
		output					cfg_interrupt_n,					// Configuration Interrupt, Active low
		input					cfg_interrupt_rdy_n,				// Configuration Interrupt Ready
		output		[7:0]		cfg_interrupt_di,					// Configuration Interrupt Data In
		output					cfg_interrupt_assert_n,				// Configuration Legacy Interrupt Assert/Deassert Select
		
		// User Application Error-Reporting
		output					cfg_err_ecrc_n,						// ECRC Error Report, Active low
		output					cfg_err_ur_n,						// Configuration Error Unsupported Request, Active low
		output					cfg_err_cpl_timeout_n,				// Configuration Error Completion Timeout, Active low
		output					cfg_err_cpl_unexpect_n,				// Configuration Error Completion Unexpected, Active low
		output					cfg_err_cpl_abort_n,				// Configuration Error Completion Aborted, Active low
		output					cfg_err_posted_n,					// Configuration Error Posted, Active low
		output					cfg_err_cor_n,						// Configuration Error Correctable Error, Active low
		output		[47:0]		cfg_err_tlp_cpl_header,				// Configuration Error TLP Completion Header
		output					cfg_err_locked_n,					// Configuration Error Locked, Active low
		input					cfg_err_cpl_rdy_n,					// Configuration Error Completion Ready
		
		output					cfg_trn_pending_n,					// User Transaction Pending
		
		// Unused 
		output					fast_train_simulation_only,			// 
		output					trn_terrfwd_n,						// 
		
		
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
		output 				fifo_overflow_pcie_ds,
		input					fifo_rdreq_pcie_ds,					// fifo read request
		output		[63:0]		fifo_q_pcie_ds,						// fifo read data
		output					fifo_empty_pcie_ds					// fifo empty
);




//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
wire		[31:0]		dmawas;
wire		[31:0]		dmawad_l;
wire		[31:0]		dmawad_u;
wire		[31:0]		dmaras_l;
wire		[31:0]		dmaras_u;
wire		[31:0]		dmarad;
wire		[31:0]		dmawxs;
wire		[31:0]		dmarxs;
wire		[31:0]		lpci_intm;
wire		[31:0]		lpci_ints;
wire					dma_wabt_rq;
wire					dma_wabt_ack;
wire					dma_rabt_rq;
wire					dma_rabt_ack_0;	
wire					dma_rabt_ack_1;	
		
wire					dma_ws;
wire					dma_rs;
wire					dma_wd;
wire					dma_rd;

wire					b0_w32_w;
wire		[3:0]		b0_w32_be;
wire		[31:0]		b0_w32_d;
wire		[31:0]		b0_w32_a;
wire		[2:0]		b0_r32_tc;
wire		[1:0]		b0_r32_at;
wire		[15:0]		b0_r32_rqid;
wire		[7:0]		b0_r32_tg;	
wire					b0_r32_r;
wire		[3:0]		b0_r32_be;
wire		[31:0]		b0_r32_a;
wire		[31:0]		b0_r32_q;

wire		[2:0]		b1_r32_tc;
wire		[1:0]		b1_r32_at;
wire		[15:0]		b1_r32_rqid;
wire		[7:0]		b1_r32_tg;

wire		[tags-1:0]	fifo_ack_pcie_ds;
wire		[tags-1:0]	fifo_rdy_pcie_ds;
wire		[tags-1:0]	fifo_wrreq_pcie_ds;
wire		[63:0]		fifo_data_pcie_ds;
wire					fifo_prog_full_pcie_ds;

wire					b0_cpld_rq;
wire					b0_cpld_ack;

wire					b1_cpld_rq;
wire					b1_cpld_ack;
	
wire		[10:0]		dmawtlp_sz;
wire		[24:0]		dmawtlp_num;

wire		[10:0]		dmartlp_sz;
wire		[24:0]		dmartlp_num;

wire					fifo_rst_pcie_us;		
wire					fifo_rdreq_pcie_us;
wire		[63:0]		fifo_q_pcie_us;
wire					fifo_empty_pcie_us;
wire		[9:0]		fifo_dcnt_pcie_us;




assign 	#tDLY fifo_rst_pcie_us = (!sys_reset_n) || (!record_en);

assign 	#tDLY fast_train_simulation_only = 1'b0;
assign 	#tDLY trn_terrfwd_n = 1'b1;

assign 	#tDLY cfg_trn_pending_n = 1'b1;


assign 	#tDLY cfg_dsn = 64'h0123456789abcdef;




// Receive TRN FSM
rx_trn_fsm 
	# (
		.tags							(tags),
		.tDLY							(tDLY)
	)
	
	rx_trn_fsm_inst
	(
		// Common TRN Interface
		.trn_clk						(trn_clk),
		.trn_lnk_up_n					(trn_lnk_up_n),
		.trn_reset_n					(trn_reset_n),
		
		// Receive TRN Interface
		.trn_rsof_n						(trn_rsof_n),
		.trn_reof_n						(trn_reof_n),
		.trn_rsrc_rdy_n					(trn_rsrc_rdy_n),
		.trn_rdst_rdy_n					(trn_rdst_rdy_n),
		.trn_rrem_n						(trn_rrem_n),
		.trn_rd							(trn_rd),
		.trn_rerrfwd_n					(trn_rerrfwd_n),
		.trn_rsrc_dsc_n					(trn_rsrc_dsc_n),
		.trn_rnp_ok_n					(trn_rnp_ok_n),
		.trn_rcpl_streaming_n			(trn_rcpl_streaming_n),
		.trn_rbar_hit_n					(trn_rbar_hit_n),
		.trn_rfc_ph_av					(trn_rfc_ph_av),
		.trn_rfc_pd_av					(trn_rfc_pd_av),
		.trn_rfc_nph_av					(trn_rfc_nph_av),
		.trn_rfc_npd_av					(trn_rfc_npd_av),
		
		// DMA Control and Status Register
		.dmarxs							(dmarxs),
		.dma_rabt_rq					(dma_rabt_rq),
		.dma_rabt_ack					(dma_rabt_ack_1),
		.dma_rs							(dma_rs),
		.dma_rd							(dma_rd),
		
		// B0 Info
		.b0_w32_w						(b0_w32_w),
		.b0_w32_be						(b0_w32_be),
		.b0_w32_d						(b0_w32_d),
		.b0_w32_a						(b0_w32_a),
		.b0_r32_tc						(b0_r32_tc),
		.b0_r32_at						(b0_r32_at),
		.b0_r32_rqid					(b0_r32_rqid),
		.b0_r32_tg						(b0_r32_tg),
		.b0_r32_r						(b0_r32_r),
		.b0_r32_be						(b0_r32_be),
		.b0_r32_a						(b0_r32_a),
		
		// B1 Info
		.b1_w32_w						(b1_w32_w),
		.b1_w32_be						(b1_w32_be),
		.b1_w32_d						(b1_w32_d),
		.b1_w32_a						(b1_w32_a),
		.b1_r32_tc						(b1_r32_tc),
		.b1_r32_at						(b1_r32_at),
		.b1_r32_rqid					(b1_r32_rqid),
		.b1_r32_tg						(b1_r32_tg),
		.b1_r32_r						(b1_r32_r),
		.b1_r32_be						(b1_r32_be),
		.b1_r32_a						(b1_r32_a),
		
		// FIFO Interface for PCI Express Downstream
		.fifo_ack_pcie_ds				(fifo_ack_pcie_ds),
		.fifo_rdy_pcie_ds				(fifo_rdy_pcie_ds),
		.fifo_wrreq_pcie_ds			(fifo_wrreq_pcie_ds),
		.fifo_data_pcie_ds			(fifo_data_pcie_ds),
		.fifo_prog_full_pcie_ds		(fifo_prog_full_pcie_ds),
		
		// B0 Arb
		.b0_cpld_rq						(b0_cpld_rq),
		.b0_cpld_ack					(b0_cpld_ack),
			
		// B1 Arb
		.b1_cpld_rq						(b1_cpld_rq),
		.b1_cpld_ack					(b1_cpld_ack)
	);


// PCI Express Downstream Buffer
pcie_ds_buf 
	# (
		.tags					(tags)
	)
	
	pcie_ds_buf_inst
	(
		// Common TRN Interface
		.pcie_ds_clk			(pcie_ds_clk),
		.trn_clk				(trn_clk),
		.trn_reset_n			(sys_reset_n),
		
		// FIFO Interface for PCI Express Downstream
		.overflow_o(fifo_overflow_pcie_ds),
		.fifo_ack_pcie_ds		(fifo_ack_pcie_ds),
		.fifo_rdy_pcie_ds		(fifo_rdy_pcie_ds),
		.fifo_wrreq_pcie_ds		(fifo_wrreq_pcie_ds),
		.fifo_data_pcie_ds		(fifo_data_pcie_ds),
		.fifo_rdreq_pcie_ds		(fifo_rdreq_pcie_ds),
		.fifo_q_pcie_ds			(fifo_q_pcie_ds),
		.fifo_empty_pcie_ds		(fifo_empty_pcie_ds),
		.fifo_prog_full_pcie_ds	(fifo_prog_full_pcie_ds)
	);


// DMA Control and Status register file
dma_reg_file 
	# (
		.tDLY								(tDLY)
	)
	
	dma_reg_file_inst
	(
		// Common TRN Interface
		.trn_clk							(trn_clk),
		.trn_reset_n						(trn_reset_n),
		.trn_lnk_up_n						(trn_lnk_up_n),
		.sys_reset_n						(sys_reset_n),
		
		// PCI Express Configuration
		.cfg_link_speed						(cfg_lstatus[3:0]),
		.cfg_link_width						(cfg_lstatus[9:4]),
		.cfg_common_clock					(cfg_lstatus[12]),
		.cfg_io_space_en					(cfg_command[0]),
		.cfg_mem_space_en					(cfg_command[1]),
		.cfg_bus_master_en					(cfg_command[2]),
		.cfg_intr_dis						(cfg_command[10]),
		.cfg_pcie_link_state_n				(cfg_pcie_link_state_n),
		.cfg_interrupt_msienable			(cfg_interrupt_msienable),
		.cfg_interrupt_mmenable				(cfg_interrupt_mmenable),
		.cfg_max_payload_size				(cfg_dcommand[7:5]),
		.cfg_max_read_req_size				(cfg_dcommand[14:12]),
		.cfg_relaxed_ordering_en			(cfg_dcommand[4]),
		.cfg_extended_tag_en				(cfg_dcommand[8]),
		.cfg_aspm_ctrl						(cfg_lcommand[1:0]),
		
		// B0 Info 
		.b0_w32_w							(b0_w32_w),
		.b0_w32_be							(b0_w32_be),
		.b0_w32_a							(b0_w32_a),
		.b0_w32_d							(b0_w32_d),
		.b0_r32_r							(b0_r32_r),
		.b0_r32_be							(b0_r32_be),
		.b0_r32_a							(b0_r32_a),
		.b0_r32_q							(b0_r32_q),
		
		// Status
		.sim_error							(sim_error),
		.fifo_prog_full_pcie_ds				(fifo_prog_full_pcie_ds),
		
		// Software Reset Register
		.sw_reset_n							(sw_reset_n),
		
		// User Register
		.record_en							(record_en),
		.play_en							(play_en),
		.sim_en								(sim_en),
		
		// DMA Control and Status Register
		.dmawas								(dmawas),
		.dmawad_l							(dmawad_l),
		.dmawad_u							(dmawad_u),
		.dmaras_l							(dmaras_l),
		.dmaras_u							(dmaras_u),
		.dmarad								(dmarad),
		.dmawxs								(dmawxs),
		.dmarxs								(dmarxs),
		.lpci_intm							(lpci_intm),
		.lpci_ints							(lpci_ints),
		.dma_wabt_rq						(dma_wabt_rq),
		.dma_wabt_ack						(dma_wabt_ack),
		.dma_rabt_rq						(dma_rabt_rq),
		.dma_rabt_ack_0						(dma_rabt_ack_0),
		.dma_rabt_ack_1						(dma_rabt_ack_1),
		.dma_ws								(dma_ws),
		.dma_rs								(dma_rs),
		.dma_wd								(dma_wd),
		.dma_rd								(dma_rd),
		.fifo_dcnt_pcie_us            (fifo_dcnt_pcie_us)
	);


// Posted Packet Slicer
posted_pkt_slicer	
	# (
		.tDLY				(tDLY)
	)
	
	posted_pkt_slicer_inst
	(
		// Common TRN Interface
		.trn_clk			(trn_clk),
		.trn_reset_n		(trn_reset_n),
	
		// Register Output
		.dmawxs				(dmawxs),
		
		// Max Payload
		.max_pld_sz			(cfg_dcommand[7:5]),
		
		// Posted Packet Slicer Information
		.dmawtlp_sz			(dmawtlp_sz),
		.dmawtlp_num		(dmawtlp_num)
	);


// Non-Posted Packet Slicer
nonposted_pkt_slicer	
	# (
		.tDLY				(tDLY)
	)
	
	nonposted_pkt_slicer_inst
	(
		// Common TRN Interface
		.trn_clk			(trn_clk),
		.trn_reset_n		(trn_reset_n),
	
		// Register Output
		.dmarxs				(dmarxs),
		
		// Max Read
		.max_rd_sz			(cfg_dcommand[14:12]),
		
		// Non-Posted Packet Slicer Information
		.dmartlp_sz			(dmartlp_sz),
		.dmartlp_num		(dmartlp_num)
	);



// Transmit TRN FSM
tx_trn_fsm 
	# (
		.tags						(tags),
		.tDLY						(tDLY)
	)
	
	tx_trn_fsm_inst
	(
		// Common TRN Interface
		.trn_clk					(trn_clk),
		.trn_lnk_up_n				(trn_lnk_up_n),
		.trn_reset_n				(trn_reset_n),
		
		// DMA Control and Status Register
		.dmawad_l					(dmawad_l),
		.dmawad_u					(dmawad_u),
		.dmaras_l					(dmaras_l),
		.dmaras_u					(dmaras_u),
		.dma_wabt_rq				(dma_wabt_rq),
		.dma_wabt_ack				(dma_wabt_ack),
		.dma_rabt_rq				(dma_rabt_rq),
		.dma_rabt_ack				(dma_rabt_ack_0),
		.dma_ws						(dma_ws),
		.dma_wd						(dma_wd),
		.dma_rs						(dma_rs),
		.dma_rd						(dma_rd),
		
		// Posted Packet Slicer Information
		.dmawtlp_sz					(dmawtlp_sz),
		.dmawtlp_num				(dmawtlp_num),
		
		// Non-Posted Packet Slicer Information
		.dmartlp_sz					(dmartlp_sz),
		.dmartlp_num				(dmartlp_num),
		
		// Command and Status Registers
		.cfg_bus_number				(cfg_bus_number),
		.cfg_device_number			(cfg_device_number),
		.cfg_function_number		(cfg_function_number),
		.cfg_relaxed_ordering_en	(cfg_dcommand[4]),
		.cfg_extended_tag_en		(cfg_dcommand[8]),
		.cfg_bus_master_en			(cfg_command[2]),
		
		// FIFO(FWFT) Interface for PCI Express Upstream
		.fifo_rdreq_pcie_us			(fifo_rdreq_pcie_us),
		.fifo_q_pcie_us				(fifo_q_pcie_us),
		.fifo_empty_pcie_us			(fifo_empty_pcie_us),
		.fifo_prog_full_pcie_ds	(1'b0),
		// B0 Arb
		.b0_cpld_rq					(b0_cpld_rq),
		.b0_cpld_ack				(b0_cpld_ack),
		
		// B0 Info
		.b0_r32_tc					(b0_r32_tc),
		.b0_r32_at					(b0_r32_at),
		.b0_r32_rqid				(b0_r32_rqid),
		.b0_r32_tg					(b0_r32_tg),
		.b0_r32_be					(b0_r32_be),
		.b0_r32_a					(b0_r32_a),
		.b0_r32_q					(b0_r32_q),
		
		// B1 Arb
		.b1_cpld_rq					(b1_cpld_rq),
		.b1_cpld_ack				(b1_cpld_ack),
		
		// B1 Info
		.b1_r32_tc					(b1_r32_tc),
		.b1_r32_at					(b1_r32_at),
		.b1_r32_rqid				(b1_r32_rqid),
		.b1_r32_tg					(b1_r32_tg),
		.b1_r32_be					(b1_r32_be),
		.b1_r32_a					(b1_r32_a),
		.b1_r32_q					(b1_r32_q),
		
		// Transmit TRN Interface
		.trn_tsof_n					(trn_tsof_n),
		.trn_teof_n					(trn_teof_n),
		.trn_tsrc_rdy_n				(trn_tsrc_rdy_n),
		.trn_tdst_rdy_n				(trn_tdst_rdy_n),
		.trn_trem_n					(trn_trem_n),
		.trn_td						(trn_td),
		.trn_tsrc_dsc_n				(trn_tsrc_dsc_n),
		.trn_tdst_dsc_n				(trn_tdst_dsc_n),
		.trn_tbuf_av				(trn_tbuf_av)
	);


// PCI Express Upstream Buffer
pcie_us_buf 
	# (
		.tDLY					(tDLY)
	)
	
	pcie_us_buf_inst
	(
		// Common TRN Interface
		.pcie_us_clk			(pcie_us_clk),
		.trn_clk				(trn_clk),
		.trn_reset_n			(sys_reset_n),
		.fifo_rst_pcie_us		(fifo_rst_pcie_us),
		
		// FIFO Interface for PCI Express Upstream
		.fifo_wrreq_pcie_us		(fifo_wrreq_pcie_us),
		.fifo_data_pcie_us		(fifo_data_pcie_us),
		.fifo_rdreq_pcie_us		(fifo_rdreq_pcie_us),
		.fifo_q_pcie_us			(fifo_q_pcie_us),
		.fifo_empty_pcie_us		(fifo_empty_pcie_us),
		.fifo_prog_full_pcie_us	(fifo_prog_full_pcie_us),
		.fifo_dcnt_pcie_us      (fifo_dcnt_pcie_us)
	);
	

// Interrupt Controller
intr_ctrl	
	# (
		.tDLY						(tDLY)
	)
	
	intr_ctrl_inst
	(
		// Common TRN Interface
		.trn_clk					(trn_clk),
		.trn_lnk_up_n				(trn_lnk_up_n),
		.trn_reset_n				(sys_reset_n),
		
		// Interrupt Disable
		.cfg_intr_dis				(cfg_command[10]),
		
		// DMA Control and Status Register
		.lpci_intm					(lpci_intm),
		.lpci_ints					(lpci_ints),
		.dma_wd						(dma_wd),
		.dma_rd						(dma_rd),
		
		// Interrupt Requests
		.cfg_interrupt_mmenable		(cfg_interrupt_mmenable),
		.cfg_interrupt_msienable	(cfg_interrupt_msienable),
		.cfg_interrupt_do			(cfg_interrupt_do),
		.cfg_interrupt_n			(cfg_interrupt_n),
		.cfg_interrupt_rdy_n		(cfg_interrupt_rdy_n),
		.cfg_interrupt_di			(cfg_interrupt_di),
		.cfg_interrupt_assert_n		(cfg_interrupt_assert_n)
	);


// Configuration Space Access
cfg	
	# (
		.tDLY				(tDLY)
	)
	
	cfg_inst
	(
		// Common TRN Interface
		.trn_clk			(trn_clk),
		.trn_lnk_up_n		(trn_lnk_up_n),
		.trn_reset_n		(trn_reset_n),
		
		// Configuration Space Access
		.cfg_wr_en_n		(cfg_wr_en_n),
		.cfg_rd_en_n		(cfg_rd_en_n),
		.cfg_rd_wr_done_n	(cfg_rd_wr_done_n),
		.cfg_byte_en_n		(cfg_byte_en_n),
		.cfg_dwaddr			(cfg_dwaddr),
		.cfg_di				(cfg_di),
		.cfg_do				(cfg_do)
	);


// User Application Error-Reporting
error_report	
	# (
		.tDLY					(tDLY)
	)
	
	error_report_inst
	(
		// Common TRN Interface
		.trn_clk				(trn_clk),
		.trn_lnk_up_n			(trn_lnk_up_n),
		.trn_reset_n			(trn_reset_n),
		
		// User Application Error-Reporting
		.cfg_err_ecrc_n			(cfg_err_ecrc_n),
		.cfg_err_ur_n			(cfg_err_ur_n),
		.cfg_err_cpl_timeout_n	(cfg_err_cpl_timeout_n),
		.cfg_err_cpl_unexpect_n	(cfg_err_cpl_unexpect_n),
		.cfg_err_cpl_abort_n	(cfg_err_cpl_abort_n),
		.cfg_err_posted_n		(cfg_err_posted_n),
		.cfg_err_cor_n			(cfg_err_cor_n),
		.cfg_err_tlp_cpl_header	(cfg_err_tlp_cpl_header),
		.cfg_err_locked_n		(cfg_err_locked_n),
		.cfg_err_cpl_rdy_n		(cfg_err_cpl_rdy_n)
	);


// Power Management
pwr_mng	
	# (
		.tDLY					(tDLY)
	)
	
	pwr_mng_inst
	(
		// Common TRN Interface
		.trn_clk				(trn_clk),
		.trn_lnk_up_n			(trn_lnk_up_n),
		.trn_reset_n			(trn_reset_n),
		
		// Power Management
		.cfg_pm_wake_n			(cfg_pm_wake_n),
		.cfg_pcie_link_state_n	(cfg_pcie_link_state_n),
		.cfg_to_turnoff_n		(cfg_to_turnoff_n)
	);


	

endmodule

