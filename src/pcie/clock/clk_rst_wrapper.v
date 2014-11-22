///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  clk_rst_wrapper.v
//  /   /        Date Last Modified: May 15th, 2008 
// /___/   /\    Date Created: Apr 1st, 2008
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT
// Purpose: Clock and Reset Top Level Wrapper.
// Reference:  
// Revision History:
//   Rev 1.0 - First created, ZhangMengjie, Apr. 1 2008.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps



module clk_rst_wrapper (
	// PCI Express Connector Socket Clock and Reset#
	input					PCIE_REFCLKP,			// Reference Clock (differential pair) for PCI Express
	input					PCIE_REFCLKN,			// Reference Clock (differential pair) for PCI Express
	input					PERSTN,					// PCI Express Fundamental reset

	// Software Reset#
	input					sw_reset_n,				// Software Reset# 
	
	// Transaction Reset# for PCI Express
	input					pcie_trn_reset_n,		// Transaction Reset# for PCI Express
	
	// Reference Clock for PCI Express
	output					pcie_refclk,			// Reference Clock for PCI Express GTP TILE

	// Reset#
	output					hw_reset_n,				// Hardware Reset#,
	output					sys_reset_n				// System Reset#
);




//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
// Clock and Reset





// Reset Distribution
assign	hw_reset_n = PERSTN;
assign	sys_reset_n = PERSTN && sw_reset_n && pcie_trn_reset_n;




// PCI Express Reference Clock (differential pair)
IBUFDS pcie_refclk_ibuf (
	.O(pcie_refclk), 
	.I(PCIE_REFCLKP), 
	.IB(PCIE_REFCLKN)
);





endmodule