///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  sim_src.v
//  /   /        Date Last Modified: Oct. 5th, 2007 
// /___/   /\    Date Created: Oct. 5th, 2007
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT
// Purpose: Data Source for Simulator.   
//
// Reference:  
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2008.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps



module sim_src	
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
		input					fifo_prog_full_sim_ds		// fifo programmable full
);



//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
reg					sim_en_r;
reg					sim_en_r2;
reg					record_en_r;
reg					record_en_r2;
		
reg					fifo_wrreq_sim_ds_r;
reg		[63:0]		fifo_data_sim_ds_r;
reg					fifo_prog_full_sim_ds_r;

reg		[7:0]		reset_dly_cnt;
reg					reset_dly_done;

reg		[30:0]		cnt31b;


//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------




assign 	fifo_wrreq_sim_ds = fifo_wrreq_sim_ds_r;
assign 	fifo_data_sim_ds  = fifo_data_sim_ds_r;
		
		


//---------------------------------------------------------------------
// Input Register
//---------------------------------------------------------------------
always@(posedge sys_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		sim_en_r <= #tDLY 1'b0;
		sim_en_r2 <= #tDLY 1'b0;
		record_en_r <= #tDLY 1'b0;
		record_en_r2 <= #tDLY 1'b0;

		fifo_prog_full_sim_ds_r <= #tDLY 1'b1;
	end
	else
	begin
		sim_en_r <= #tDLY sim_en;
		sim_en_r2 <= #tDLY sim_en_r;
		record_en_r <= #tDLY record_en;
		record_en_r2 <= #tDLY record_en_r;
		
		fifo_prog_full_sim_ds_r <= #tDLY fifo_prog_full_sim_ds;
	end
end



always@(posedge sys_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		reset_dly_cnt <= #tDLY 0;
		reset_dly_done <= #tDLY 1'b0;
	end
	else
	begin
		if (reset_dly_cnt == 127)
		begin
			reset_dly_done <= #tDLY 1'b1;
		end
		
		if (sim_en_r2 && record_en_r2)
		begin
			reset_dly_cnt <= #tDLY reset_dly_cnt + 1'b1;
		end
	end
end


always@(posedge sys_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		cnt31b <= #tDLY 0;
		
		fifo_wrreq_sim_ds_r <= #tDLY 1'b0;
		fifo_data_sim_ds_r <= #tDLY 64'h0000000000000000;
	end
	else
	begin
		if (reset_dly_done && (!fifo_prog_full_sim_ds_r))
		begin
			cnt31b <= #tDLY cnt31b + 1'b1;
			
			fifo_wrreq_sim_ds_r <= #tDLY 1'b1;
			fifo_data_sim_ds_r <= #tDLY {cnt31b, 1'b1, cnt31b, 1'b0};
		end 
		else
		begin
			fifo_wrreq_sim_ds_r <= #tDLY 1'b0;
		end
	end
end




endmodule