///////////////////////////////////////////////////////////////////////////////
//  2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  pcie_us_buf.v
//  /   /        Date Last Modified: June. 15th, 2009
// /___/   /\    Date Created: Apr. 1st, 2009
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT/FXT/TXT
// Purpose: PCI Express Upstream Buffer.
// Reference:
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2009.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps


//module fifo_fwft_512x64_pf496 (
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




module pcie_us_buf 
	# (
		parameter	tDLY		= 0							// Simulation delay
	)
	
	(
		// Common TRN Interface
		input					pcie_us_clk,				// Clock for PCI Express Upstream
		input					trn_clk,					// Transaction Clock, Rising Edge
		input					trn_reset_n,				// Transaction Reset, Active low
		input					fifo_rst_pcie_us,
		
		// FIFO Interface for PCI Express Upstream
		input					fifo_wrreq_pcie_us,			// fifo write request
		input		[63:0]		fifo_data_pcie_us,			// fifo write data
		input					fifo_rdreq_pcie_us,			// fifo read request
		output		[63:0]		fifo_q_pcie_us,				// fifo write data
		output					fifo_empty_pcie_us,			// fifo empty
		output					fifo_prog_full_pcie_us,		// fifo program full
		output		[9:0]		fifo_dcnt_pcie_us		// fifo data count
);



wire	sys_reset;


assign	sys_reset = !trn_reset_n;




fifo_fwft_512x64_pf496 pcie_us_fifo_inst (
	.rst		(sys_reset),
	.clk		(trn_clk),
	
	.wr_en		(fifo_wrreq_pcie_us),
	.din		(fifo_data_pcie_us),
	.rd_en		(fifo_rdreq_pcie_us),
	.dout		(fifo_q_pcie_us),
	.prog_full	(fifo_prog_full_pcie_us),
	.empty		(fifo_empty_pcie_us),
	.full		(),
	.data_count		(fifo_dcnt_pcie_us)
);





endmodule