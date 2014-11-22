///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  pcie_dma_top.v
//  /   /        Date Last Modified: May 15th, 2008 
// /___/   /\    Date Created: Apr 1st, 2008
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT
// Purpose: Endpoint Block Plus to FIFO DMA Initiator Top Level Wrapper.
// Reference:
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2008.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps



module pcie_dma_top 
	# (
		parameter	tDLY		= 0					// Simulation delay
	)
	
	(
		// PCI Express Connector Socket Clock and Reset#
		input					PCIE_REFCLKP,		// Reference Clock (differential pair) for PCI Express
		input					PCIE_REFCLKN,		// Reference Clock (differential pair) for PCI Express
		input					PERSTN,				// PCI Express Fundamental reset
		
		// LED Out
		output					USER_LED0,			// PCI Express Link Indicator
		output					USER_LED1,			// Record or Play Indicator
		output					USER_LED2,			// Error Indicator
		
		// PCI Express Interface
		output		[3:0]		pci_exp_txp,		// Transmitter differential pair, Lane 0/1/2/3
		output		[3:0]		pci_exp_txn,		// Transmitter differential pair, Lane 0/1/2/3
		input		[3:0]		pci_exp_rxp,		// Receiver differential pair, Lane 0/1/2/3
		input		[3:0]		pci_exp_rxn,		// Receiver differential pair, Lane 0/1/2/3
		
		// clock for FIFO Interface
		output                  pcie_trn_clk,
		// FIFO Interface for PCI Express Upstream
		input					fifo_wrreq_pcie_us,					// fifo write request
		input		[63:0]		fifo_data_pcie_us,					// fifo write data
		output					fifo_prog_full_pcie_us,				// fifo programmable full		
		// FIFO Interface for PCI Express Downstream
		input					fifo_rdreq_pcie_ds,					// fifo read request
		output		[63:0]		fifo_q_pcie_ds,						// fifo read data
		output					fifo_empty_pcie_ds,					// fifo empty
		
		output					record_en							// Record Enable
);




//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
wire					hw_reset_n;
wire					sys_reset_n;

wire					pcie_refclk;
//wire					pcie_trn_clk;
wire					pcie_trn_reset_n;
wire					trn_lnk_up_n;

wire					sim_error;

wire					sw_reset_n;

//wire					record_en;
wire					play_en;
wire					sim_en;

//wire					fifo_wrreq_pcie_us;
//wire		[63:0]		fifo_data_pcie_us;
//wire					fifo_prog_full_pcie_us;
//
//wire					fifo_rdreq_pcie_ds;
//wire		[63:0]		fifo_q_pcie_ds;
//wire					fifo_empty_pcie_ds;



// Indicator
// PCI Express Link Indicator
assign	USER_LED0 = trn_lnk_up_n;

// Record or Play Indicator
assign	USER_LED1 = !(record_en || play_en);

// Error Indicator
assign	USER_LED2 = !sim_error;




// Clock and Reset Top Level Wrapper
clk_rst_wrapper clk_rst_wrapper_inst (
	// PCI Express Connector Socket Clock and Reset#
	.PCIE_REFCLKP				(PCIE_REFCLKP),
	.PCIE_REFCLKN				(PCIE_REFCLKN),
	.PERSTN						(PERSTN),

	// Software Reset#
	.sw_reset_n					(sw_reset_n), 
	
	// Transaction Reset# for PCI Express
	.pcie_trn_reset_n			(pcie_trn_reset_n),
	
	// Reference Clock for PCI Express
	.pcie_refclk				(pcie_refclk),
	
	// Reset#
	.hw_reset_n					(hw_reset_n),
	.sys_reset_n				(sys_reset_n)
);




// Endpoint Block Plus DMA Initiator Top Level Wrapper
pcie_wrapper
	# (
		.tDLY								(tDLY)
	)
	
	pcie_wrapper_inst
	(
		// PCI Express Clock and Reset#
		.pcie_refclk						(pcie_refclk),
		.pcie_us_clk						(pcie_trn_clk),
		.pcie_ds_clk						(pcie_trn_clk),
		.perstn								(PERSTN),
		.sys_reset_n						(sys_reset_n),
		.pcie_trn_clk						(pcie_trn_clk),
		.pcie_trn_reset_n					(pcie_trn_reset_n),
		.trn_lnk_up_n						(trn_lnk_up_n),
		
		// PCI Express Interface
		.pci_exp_txp						(pci_exp_txp),
		.pci_exp_txn						(pci_exp_txn),
		.pci_exp_rxp						(pci_exp_rxp),
		.pci_exp_rxn						(pci_exp_rxn),
		
		// BAR1 Info
		.b1_w32_w							(),
		.b1_w32_be							(),
		.b1_w32_d							(),
		.b1_w32_a							(),
		.b1_r32_r							(),
		.b1_r32_be							(),
		.b1_r32_a							(),
		.b1_r32_q							(32'h00000000),
		
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


	

// Simulator Top Level wrapper
//sim_wrapper	
//	# (
//		.tDLY					(tDLY)
//	)
//	
//	sim_wrapper_inst
//	(
//		// System Clock and Reset#
//		.sys_clk				(pcie_trn_clk),
//		.sys_reset_n			(sys_reset_n),
//		
//		// Control
//		.sim_en					(sim_en),
//		.record_en				(record_en),
//		
//		// FIFO Interface for Simulator Downstream
//		.fifo_wrreq_sim_ds		(),
//		.fifo_data_sim_ds		(),
//		.fifo_prog_full_sim_ds	(1'b0),
//		
//		// FIFO Interface for Simulator Upstream
//		.fifo_rdreq_sim_us		(),
//		.fifo_q_sim_us			(64'h0000000000000000),
//		.fifo_empty_sim_us		(1'b1),
//		
//		// Error Indicator
//		.error					(sim_error)
//	);

	
	
	
	

endmodule

