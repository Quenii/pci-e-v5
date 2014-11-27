///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  sim_wrapper.v
//  /   /        Date Last Modified: Oct. 5th, 2007 
// /___/   /\    Date Created: Oct. 5th, 2007
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT
// Purpose: Simulator Top Level wrapper.   
//
// Reference:  
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2008.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps



module sim_wrapper	
	# (
		parameter	tDLY		= 0							// Simulation delay
	)
	
	(
		// System Clock and Reset#
		input					sys_clk,					// System Clock, Rising Edge
		input					sys_reset_n,				// System Reset#
		
		// Control
		input					sim_en,						// Simulator Enable
		input					record_en,					// Record Enable
		
		// FIFO Interface for Simulator Downstream
		output					fifo_wrreq_sim_ds,			// fifo write request
		output		[63:0]		fifo_data_sim_ds,			// fifo write data
		input					fifo_prog_full_sim_ds,		// fifo program full
		
		// FIFO Interface for Simulator Upstream
		output					fifo_rdreq_sim_us,			// fifo read request
		input		[63:0]		fifo_q_sim_us,				// fifo read data
		input					fifo_empty_sim_us,			// fifo empty
		
		// Error Indicator
		output					error
);

		
		

// Data Source for Simulator
sim_src	
	# (
		.tDLY					(tDLY)
	)
	
	sim_src_inst
	(
		// System Clock and Reset#
		.sys_clk				(sys_clk),
		.sys_reset_n			(sys_reset_n),
		
		// Control
		.sim_en					(sim_en),
		.record_en				(record_en),
		
		// FIFO Interface for Simulator Downstream
		.fifo_wrreq_sim_ds		(fifo_wrreq_sim_ds),
		.fifo_data_sim_ds		(fifo_data_sim_ds),
		.fifo_prog_full_sim_ds	(fifo_prog_full_sim_ds)
	);



// Data Sink for Simulator
sim_sink	
	# (
		.tDLY				(tDLY)
	)
	
	sim_sink_inst
	(
		// System Clock and Reset#
		.sys_clk			(sys_clk),
		.sys_reset_n		(sys_reset_n),
		
		// FIFO Interface for Simulator Upstream
		.fifo_rdreq_sim_us	(fifo_rdreq_sim_us),
		.fifo_q_sim_us		(fifo_q_sim_us),
		.fifo_empty_sim_us	(fifo_empty_sim_us),
		
		// Error Indicator
		.error				(error)
	);



endmodule