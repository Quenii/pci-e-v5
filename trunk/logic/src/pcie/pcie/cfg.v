///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  cfg.v
//  /   /        Date Last Modified: June 15th, 2009
// /___/   /\    Date Created: Apr 1st, 2009
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT/FXT/TXT
// Purpose: Configuration Space Access
//
// Reference:
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2009.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps



module cfg	
	# (
		parameter	tDLY		= 0							// Simulation delay
	)
	
	(
		// Common TRN Interface
		input					trn_clk,					// Transaction Clock, Rising Edge
		input					trn_lnk_up_n,				// Transaction Link Up, Active low
		input					trn_reset_n,				// Transaction Reset, Active low
		
		// Configuration Space Access
		output					cfg_wr_en_n,				// Configuration Write Enable, Active low
		output					cfg_rd_en_n,				// Configuration Read Enable, Active low
		input					cfg_rd_wr_done_n,			// Configuration Read Write Done, Active low
		output		[3:0]		cfg_byte_en_n,				// Configuration Byte Enable, Active low
		output		[9:0]		cfg_dwaddr,					// Configuration DWORD Address
		output		[31:0]		cfg_di,						// Configuration Data In
		input		[31:0]		cfg_do						// Configuration Data Out
);




//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------





assign	#tDLY cfg_wr_en_n 	= 1'b1;
assign 	#tDLY cfg_rd_en_n	= 1'b1;
assign 	#tDLY cfg_byte_en_n	= 4'b1111;
assign 	#tDLY cfg_dwaddr	= 10'b0000000000;
assign 	#tDLY cfg_di		= 32'h00000000;







endmodule