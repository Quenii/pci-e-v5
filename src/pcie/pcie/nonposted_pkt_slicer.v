///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  posted_pkt_slicer.v
//  /   /        Date Last Modified: June. 15th, 2009
// /___/   /\    Date Created: Apr. 1st, 2009
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT/FXT/TXT
// Purpose: Non-Posted Packet Slicer module
//
// Reference:
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2009.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps



module nonposted_pkt_slicer	
	# (
		parameter	tDLY		= 0							// Simulation delay
	)
	
	(
		// Common TRN Interface
		input					trn_clk,					// Transaction Clock, Rising Edge
		input					trn_reset_n,				// Transaction Reset, Active low
	
		// Register Output
		input		[31:0]		dmarxs,						//
		
		// Max Read
		input		[2:0]		max_rd_sz, 					//
		
		// Non-Posted Packet Slicer Information
		output		[10:0]		dmartlp_sz,					//
		output		[24:0]		dmartlp_num					//
);



//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
reg		[2:0]		max_rd_sz_r;
reg		[10:0]		dmartlp_sz_r;
reg		[24:0]		dmartlp_num_r;


//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------







always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		max_rd_sz_r <= #tDLY 0;
	end
	else
	begin
		max_rd_sz_r <= #tDLY max_rd_sz; 
	end
end


assign 	dmartlp_sz = dmartlp_sz_r;
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		dmartlp_sz_r <= #tDLY 0;
	end
	else
	begin
		case (max_rd_sz_r)
			3'b000 :
			begin
				dmartlp_sz_r <= #tDLY 11'h020;
			end
			
			3'b001 :
			begin
				dmartlp_sz_r <= #tDLY 11'h040;
			end
			
			3'b010 :
			begin
				dmartlp_sz_r <= #tDLY 11'h080;
			end
			
			3'b011 :
			begin
				dmartlp_sz_r <= #tDLY 11'h100;
			end
			
			3'b100 :
			begin
				dmartlp_sz_r <= #tDLY 11'h200;
			end
			
			3'b101 :
			begin
				dmartlp_sz_r <= #tDLY 11'h400;
			end
			
			default :
			begin
				dmartlp_sz_r <= #tDLY 0;
			end
		endcase
	end
end


assign 	dmartlp_num = dmartlp_num_r;
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		dmartlp_num_r <= #tDLY 0;
	end
	else
	begin
		case (max_rd_sz_r)
			3'b000 :
			begin
				dmartlp_num_r <= #tDLY dmarxs[31:7];
			end
			
			3'b001 :
			begin
				dmartlp_num_r <= #tDLY {1'b0, dmarxs[31:8]};
			end
			
			3'b010 :
			begin
				dmartlp_num_r <= #tDLY {2'b00, dmarxs[31:9]};
			end
			
			3'b011 :
			begin
				dmartlp_num_r <= #tDLY {3'b000, dmarxs[31:10]};
			end
			
			3'b100 :
			begin
				dmartlp_num_r <= #tDLY {4'b0000, dmarxs[31:11]};
			end
			
			3'b101 :
			begin
				dmartlp_num_r <= #tDLY {5'b00000, dmarxs[31:12]};
			end
			
			default :
			begin
				dmartlp_num_r <= #tDLY 0;
			end
		endcase
	end
end





endmodule