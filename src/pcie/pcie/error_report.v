///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  error_report.v
//  /   /        Date Last Modified: Oct. 5th, 2007 
// /___/   /\    Date Created: Oct. 5th, 2007
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT
// Purpose: User Application Error-Reporting
//
// Reference: 
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2008.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps



module error_report	
	# (
		parameter	tDLY		= 0							// Simulation delay
	)
	
	(
		// Common TRN Interface
		input					trn_clk,					// Transaction Clock, Rising Edge
		input					trn_lnk_up_n,				// Transaction Link Up, Active low
		input					trn_reset_n,				// Transaction Reset, Active low
		
		// User Application Error-Reporting
		output					cfg_err_ecrc_n,				// ECRC Error Report, Active low
		output					cfg_err_ur_n,				// Configuration Error Unsupported Request, Active low
		output					cfg_err_cpl_timeout_n,		// Configuration Error Completion Timeout, Active low
		output					cfg_err_cpl_unexpect_n,		// Configuration Error Completion Unexpected, Active low
		output					cfg_err_cpl_abort_n,		// Configuration Error Completion Aborted, Active low
		output					cfg_err_posted_n,			// Configuration Error Posted, Active low
		output					cfg_err_cor_n,				// Configuration Error Correctable Error, Active low
		output		[47:0]		cfg_err_tlp_cpl_header,		// Configuration Error TLP Completion Header
		output					cfg_err_locked_n,			// Configuration Error Locked, Active low
		input					cfg_err_cpl_rdy_n			// Configuration Error Completion Ready
);




//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------







assign 	cfg_err_ecrc_n 			= 1'b1;
assign 	cfg_err_ur_n			= 1'b1;
assign 	cfg_err_cpl_timeout_n	= 1'b1;
assign 	cfg_err_cpl_unexpect_n	= 1'b1;
assign 	cfg_err_cpl_abort_n		= 1'b1;
assign 	cfg_err_posted_n		= 1'b1;
assign 	cfg_err_cor_n			= 1'b1;
assign 	cfg_err_tlp_cpl_header	= 48'h000000000000;
assign 	cfg_err_locked_n		= 1'b1;






endmodule