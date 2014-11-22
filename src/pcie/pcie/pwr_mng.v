///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  pwr_mng.v
//  /   /        Date Last Modified: Oct. 5th, 2007 
// /___/   /\    Date Created: Oct. 5th, 2007
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT
// Purpose: Power Management
//
// Reference:
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2008.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps



module pwr_mng	
	# (
		parameter	tDLY		= 0							// Simulation delay
	)
	
	(
		// Common TRN Interface
		input					trn_clk,					// Transaction Clock, Rising Edge
		input					trn_lnk_up_n,				// Transaction Link Up, Active low
		input					trn_reset_n,				// Transaction Reset, Active low
		
		// Power Management
		output					cfg_pm_wake_n,				// Configuration Power Management Wake, Active low
		input		[2:0]		cfg_pcie_link_state_n,		// PCI Express Link State
		input					cfg_to_turnoff_n			// Configuration To Turnoff
);




//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------






assign 	cfg_pm_wake_n 	= 1'b1;







endmodule