///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  sim_sink.v
//  /   /        Date Last Modified: Oct. 5th, 2007 
// /___/   /\    Date Created: Oct. 5th, 2007
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT
// Purpose: Data Sink for Simulator.   
//
// Reference:  
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2008.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps



module sim_sink	
	# (
		parameter	tDLY		= 0							// Simulation delay
	)
	
	(
		// System Clock and Reset#
		input					sys_clk,					// System Clock, Rising Edge
		input					sys_reset_n,				// System Reset#
		
		// FIFO Interface for Simulator Upstream
		output					fifo_rdreq_sim_us,			// fifo read request
		input		[63:0]		fifo_q_sim_us,				// fifo read data
		input					fifo_empty_sim_us,			// fifo empty
		
		// Error Indicator
		output					error
);



//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
reg					fifo_rdreq_sim_us_r;
reg					data_vld;

reg		[30:0]		cnt31b;
reg		[63:0]		data;

reg					error_r;


//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
wire				fifo_rdreq_sim_us_i;


assign 	#tDLY error = error_r;

assign 	#tDLY fifo_rdreq_sim_us_i = !fifo_empty_sim_us;

assign 	#tDLY fifo_rdreq_sim_us = fifo_rdreq_sim_us_i;


always@(posedge sys_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		fifo_rdreq_sim_us_r <= 1'b0;		
		
		data_vld <= 1'b0;
		
		data <= 0;
	end
	else
	begin
		fifo_rdreq_sim_us_r <= fifo_rdreq_sim_us_i;
		
		data_vld <= fifo_rdreq_sim_us_r;
		data <= fifo_q_sim_us;
	end
end


always@(posedge sys_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		cnt31b <= 0;	
		
		error_r <= 1'b0;	
	end
	else
	begin
		if (data_vld)
		begin
			if (({cnt31b, 1'b0} == data[31:0]) && ({cnt31b, 1'b1} == data[63:32]))
			begin
				error_r <= 1'b0;
			end
			else
			begin
				error_r <= 1'b1;
			end
			
			cnt31b <= cnt31b + 1'b1;
		end
	end
end




endmodule