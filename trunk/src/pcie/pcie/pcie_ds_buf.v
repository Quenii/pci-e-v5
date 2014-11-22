///////////////////////////////////////////////////////////////////////////////
//  2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  pcie_ds_buf.v
//  /   /        Date Last Modified: June. 15th, 2009
// /___/   /\    Date Created: Apr. 1st, 2009
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT/FXT/TXT
// Purpose: PCI Express Downstream Buffer.
// Reference:
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2009.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps


//module fifo_std_512x64_pf496 (
//	input			rst,
//	input			clk,
//	input	[63:0]	din,
//	input			wr_en,
//	input			rd_en,
//	output	[63:0]	dout,
//	output			full,
//	output			empty,
//	output			prog_full
//);
//endmodule




module pcie_ds_buf 
	# (
		parameter	tDLY		= 0							// Simulation delay
	)
	
	(
		// Common TRN Interface
		input					pcie_ds_clk,				// Clock for PCI Express Downstream
		input					trn_clk,					// Transaction Clock, Rising Edge
		input					trn_reset_n,				// Transaction Reset, Active low
		
		// FIFO Interface for PCI Express Downstream
		input					fifo_wrreq_pcie_ds,			// fifo write request
		input		[63:0]		fifo_data_pcie_ds,			// fifo write data
		input					fifo_rdreq_pcie_ds,			// fifo read request
		output		[63:0]		fifo_q_pcie_ds,				// fifo write data
		output					fifo_empty_pcie_ds,			// fifo empty
		output					fifo_prog_full_pcie_ds		// fifo program full
);



wire	sys_reset;


assign	sys_reset = !trn_reset_n;



fifo_std_512x64_pf496 pcie_ds_fifo_inst (
	.rst		(sys_reset),
	.clk		(trn_clk),
	
	.wr_en		(fifo_wrreq_pcie_ds),
	.din		(fifo_data_pcie_ds),
	.rd_en		(fifo_rdreq_pcie_ds),
	.dout		(fifo_q_pcie_ds),
	.prog_full	(fifo_prog_full_pcie_ds),
	.empty		(fifo_empty_pcie_ds),
	.full		()
);





endmodule