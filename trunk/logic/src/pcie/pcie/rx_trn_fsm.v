///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  rx_trn_fsm.v
//  /   /        Date Last Modified: June. 15th, 2009 
// /___/   /\    Date Created: Apr. 1st, 2009
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT/FXT/TXT
// Purpose: Receive TRN FSM. This module interfaces to the Block Plus RX 
// TRN and receives packtets including Posted, Non-Posted and Completion
// form the TRN interface. 
// Reference:
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2009.
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps


/************** TLP Header Type and Format Field Encodings **************/
`define	IORd_FMT_TYPE		7'b00_00010
`define IOWr_FMT_TYPE  		7'b10_00010
`define MRd32_FMT_TYPE 		7'b00_00000
`define MWr32_FMT_TYPE 		7'b10_00000
`define MRd64_FMT_TYPE 		7'b01_00000
`define MWr64_FMT_TYPE 		7'b11_00000
`define Cpl_FMT_TYPE 		7'b00_01010
`define CplD_FMT_TYPE 		7'b10_01010
/************** TLP Header Type and Format Field Encodings **************/



module rx_trn_fsm 
	# (
		parameter	tags		= 8,		//when changes tags to other value, check for 
		parameter	tags_width		= 3,		//when changes tags to other value, check for 
												//	fifo_rdy_r[0] <= #tDLY (fifo_ack_pcie_ds[0] == 1'b1) ? 1'b0 : fifo_rdy_r[0];
		parameter	tDLY		= 0								// Simulation delay
	)
	
	(
		// Common TRN Interface
		input					trn_clk,						// Transaction Clock, Rising Edge
		input					trn_lnk_up_n,					// Transaction Link Up, Active low
		input					trn_reset_n,					// Transaction Reset, Active low
		
		// Receive TRN Interface
		input					trn_rsof_n,						// Receive Start-of-Frame (SOF), Active low
		input					trn_reof_n,						// Receive End-of-Frame (EOF), Active low
		input					trn_rsrc_rdy_n,					// Receive Source Ready, Active low
		output					trn_rdst_rdy_n,					// Receive Destination Ready, Active low 
		input		[7:0] 		trn_rrem_n,						// Receive Data Remainder
		input		[63:0] 		trn_rd,							// Receive Data
		input					trn_rerrfwd_n, 					// Receive Error Forward, Active low
		input					trn_rsrc_dsc_n, 				// Receive Source Discontinue, Active low
		output				trn_rnp_ok_n, 					// Receive Non-Posted OK, Active low
		output				trn_rcpl_streaming_n, 			// Receive Completion Streaming, Active low
		input		[6:0] 	trn_rbar_hit_n, 				// Receive BAR Hit, Active low
		input		[7:0] 	trn_rfc_ph_av, 					// Receive Posted Header Flow Control Credits Available
		input		[11:0] 	trn_rfc_pd_av, 					// Receive Posted Data Flow Control Credits Available
		input		[7:0] 	trn_rfc_nph_av, 				// Receive Non-Posted Header Flow Control Credits Available
		input		[11:0] 	trn_rfc_npd_av, 				// Receive Non-Posted Data Flow Control Credits Available
		
		// DMA Control and Status Register
		input		[31:0]	dmarxs,							//
		input					dma_rabt_rq,					//
		output				dma_rabt_ack,					//
		input					dma_rs,							//
		output				dma_rd,							//
		
		// B0 Info
		output					b0_w32_w,						//
		output		[3:0]		b0_w32_be,						//
		output		[31:0]	b0_w32_d,						//
		output		[31:0]	b0_w32_a,						//
		output		[2:0]		b0_r32_tc,						//
		output		[1:0]		b0_r32_at,						//
		output		[15:0]	b0_r32_rqid,					//
		output		[7:0]		b0_r32_tg,						//
		output					b0_r32_r,						//
		output		[3:0]		b0_r32_be,						//
		output		[31:0]	b0_r32_a,						//
		
		// B1 Info
		output					b1_w32_w,						//
		output		[3:0]		b1_w32_be,						//
		output		[31:0]	b1_w32_d,						//
		output		[31:0]	b1_w32_a,						//
		output		[2:0]		b1_r32_tc,						//
		output		[1:0]		b1_r32_at,						//
		output		[15:0]	b1_r32_rqid,					//
		output		[7:0]		b1_r32_tg,						//
		output					b1_r32_r,						//
		output		[3:0]		b1_r32_be,						//
		output		[31:0]	b1_r32_a,						//
		
		// FIFO Interface for PCI Express Downstream
		input		[tags-1:0]		fifo_ack_pcie_ds,
		output		[tags-1:0]		fifo_rdy_pcie_ds,		//coresponding to tags in tx module
		output		[tags-1:0]		fifo_wrreq_pcie_ds,				// fifo write request
		output		[63:0]	fifo_data_pcie_ds,				// fifo write data
		
		// B0 Arb
		output					b0_cpld_rq,						//
		input					b0_cpld_ack,					//
		
		// B1 Arb
		output					b1_cpld_rq,						//
		input					b1_cpld_ack						//
);




//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
reg		[3:0]		ep_rx_state;
reg					b0_arb_state;
reg					b1_arb_state;

reg					trn_lnk_up_n_r;

reg					b0_w32_w_r;
reg		[3:0]		b0_w32_be_r;
reg		[31:0]		b0_w32_a_r;
reg		[31:0]		b0_w32_d_r;
reg					b0_r32_r_r;
reg		[3:0]		b0_r32_be_i;
reg		[3:0]		b0_r32_be_r;
reg		[31:0]		b0_r32_a_r;
reg		[2:0]		b0_r32_tc_i;
reg		[1:0]		b0_r32_at_i;
reg		[15:0]		b0_r32_rqid_i;
reg		[7:0]		b0_r32_tg_i;
reg		[2:0]		b0_r32_tc_r;
reg		[1:0]		b0_r32_at_r;
reg		[15:0]		b0_r32_rqid_r;	
reg		[7:0]		b0_r32_tg_r;

reg					b1_w32_w_r;
reg		[3:0]		b1_w32_be_r;
reg		[31:0]		b1_w32_a_r;
reg		[31:0]		b1_w32_d_r;
reg					b1_r32_r_r;				
reg		[3:0]		b1_r32_be_i;				
reg		[3:0]		b1_r32_be_r;		
reg		[31:0]		b1_r32_a_r;				
reg		[2:0]		b1_r32_tc_i;				
reg		[1:0]		b1_r32_at_i;				
reg		[15:0]		b1_r32_rqid_i;			
reg		[7:0]		b1_r32_tg_i;				
reg		[2:0]		b1_r32_tc_r;				
reg		[1:0]		b1_r32_at_r;				
reg		[15:0]		b1_r32_rqid_r;			
reg		[7:0]		b1_r32_tg_r;	

reg					b0_cpld_ar;
reg					b0_cpld_rq_r;
reg					b0_cpld_rdy_n;

reg					b1_cpld_ar;
reg					b1_cpld_rq_r;
reg					b1_cpld_rdy_n;

reg		[tags-1:0]	fifo_rdy_r;
reg		[tags-1:0]	fifo_w_r;
reg		[63:0]		fifo_d_r;

reg		[31:0]		cpld_dl;
reg		[10:0]		cpld_tlen;
reg					dma_rr_si;
reg		[29:0]		dma_rr_s;
reg					dma_rd_r;
reg					dma_rabt_ack_r;

reg					trn_rdst_rdy_n_r;
reg					trn_rnp_ok_n_r;
reg					trn_rcpl_streaming_n_r;

reg [9:0]	cpld_len;
reg [11:0]  cpld_remain_bytes;
integer index;


//---------------------------------------------------------------------
// EP_RX_FSM state variable assignments (sequential coded) 
//---------------------------------------------------------------------
localparam 	ep_rx_s0	= 4'b0000;
localparam 	ep_rx_s1 	= 4'b0001;
localparam 	ep_rx_s2 	= 4'b0010;
localparam 	ep_rx_s3 	= 4'b0011;
localparam 	ep_rx_s4 	= 4'b0100;
localparam 	ep_rx_s5 	= 4'b0101;
localparam 	ep_rx_s6 	= 4'b0110;
localparam 	ep_rx_s7 	= 4'b0111;
localparam 	ep_rx_s8	= 4'b1000;
localparam 	ep_rx_s9	= 4'b1001; // down stream fifo write;
localparam 	ep_rx_sa	= 4'b1010;

//---------------------------------------------------------------------
// B0_ARB_FSM state variable assignments (sequential coded) 
//---------------------------------------------------------------------
localparam 	b0_arb_s0	= 1'b0;
localparam 	b0_arb_s1 	= 1'b1;

//---------------------------------------------------------------------
// B1_ARB_FSM state variable assignments (sequential coded) 
//---------------------------------------------------------------------
localparam 	b1_arb_s0	= 1'b0;
localparam 	b1_arb_s1 	= 1'b1;






assign 	trn_rdst_rdy_n 			= trn_rdst_rdy_n_r;
assign 	trn_rnp_ok_n 			= trn_rnp_ok_n_r;
assign 	trn_rcpl_streaming_n 	= trn_rcpl_streaming_n_r;
		
assign 	dma_rd 					= dma_rd_r;
assign	dma_rabt_ack			= dma_rabt_ack_r;
		
assign 	b0_w32_w 				= b0_w32_w_r;
assign 	b0_w32_be 				= b0_w32_be_r;
assign 	b0_w32_d 				= b0_w32_d_r;
assign 	b0_w32_a 				= b0_w32_a_r;
assign 	b0_r32_tc 				= b0_r32_tc_r;
assign 	b0_r32_at 				= b0_r32_at_r;
assign 	b0_r32_rqid 			= b0_r32_rqid_r;
assign 	b0_r32_tg 				= b0_r32_tg_r;
assign 	b0_r32_r 				= b0_r32_r_r;
assign 	b0_r32_be 				= b0_r32_be_r;
assign 	b0_r32_a 				= b0_r32_a_r;
		
assign 	b1_w32_w 				= b1_w32_w_r;
assign 	b1_w32_be 				= b1_w32_be_r;
assign 	b1_w32_d 				= b1_w32_d_r;
assign 	b1_w32_a 				= b1_w32_a_r;
assign 	b1_r32_tc 				= b1_r32_tc_r;
assign 	b1_r32_at 				= b1_r32_at_r;
assign 	b1_r32_rqid				= b1_r32_rqid_r;
assign 	b1_r32_tg 				= b1_r32_tg_r;
assign	b1_r32_r 				= b1_r32_r_r;
assign 	b1_r32_be 				= b1_r32_be_r;
assign 	b1_r32_a 				= b1_r32_a_r;

assign 	fifo_rdy_pcie_ds 	= fifo_rdy_r;
assign 	fifo_wrreq_pcie_ds 	= fifo_w_r;
assign 	fifo_data_pcie_ds 	= fifo_d_r;
		
assign 	b0_cpld_rq 				= b0_cpld_rq_r;	
assign 	b1_cpld_rq 				= b1_cpld_rq_r;				
		




//---------------------------------------------------------------------
// Input Register
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		trn_lnk_up_n_r <= #tDLY 1'b1;
	end
	else
	begin
		trn_lnk_up_n_r <= #tDLY trn_lnk_up_n;
	end
end



//---------------------------------------------------------------------
// EP_RX_FSM Finite State Machine(one process)
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		ep_rx_state <= #tDLY ep_rx_s0;
		
		trn_rdst_rdy_n_r <= #tDLY 1'b0;
		
		b0_w32_w_r <= #tDLY 1'b0;
		b0_w32_be_r <= #tDLY 0;
		b0_w32_d_r <= #tDLY 0;
		b0_w32_a_r <= #tDLY 0;
		b0_r32_r_r <= #tDLY 1'b0;
		b0_r32_be_i <= #tDLY 0;
		b0_r32_be_r <= #tDLY 0;
		b0_r32_a_r <= #tDLY 0;
		b0_r32_tc_i <= #tDLY 0;
		b0_r32_at_i <= #tDLY 0;
		b0_r32_rqid_i <= #tDLY 0;
		b0_r32_tg_i <= #tDLY 0;
		b0_r32_tc_r <= #tDLY 0;
		b0_r32_at_r <= #tDLY 0;
		b0_r32_rqid_r <= #tDLY 0;
		b0_r32_tg_r <= #tDLY 0;
		b0_cpld_ar <= #tDLY 1'b0;
		
		b1_w32_w_r <= #tDLY 1'b0;
		b1_w32_be_r <= #tDLY 0;
		b1_w32_d_r <= #tDLY 0;
		b1_w32_a_r <= #tDLY 0;
		b1_r32_r_r <= #tDLY 1'b0;
		b1_r32_be_i <= #tDLY 0;
		b1_r32_be_r <= #tDLY 0;
		b1_r32_a_r <= #tDLY 0;
		b1_r32_tc_i <= #tDLY 0;
		b1_r32_at_i <= #tDLY 0;
		b1_r32_rqid_i <= #tDLY 0;
		b1_r32_tg_i <= #tDLY 0;
		b1_r32_tc_r <= #tDLY 0;
		b1_r32_at_r <= #tDLY 0;
		b1_r32_rqid_r <= #tDLY 0;
		b1_r32_tg_r <= #tDLY 0;
		b1_cpld_ar <= #tDLY 1'b0;
		
//		fifo_rdy_r <= #tDLY { tags {1'b0} };
		fifo_w_r <= #tDLY { tags {1'b0} };
		fifo_d_r <= #tDLY 64'h0000000000000000;
		index <= #tDLY 0;
		
		cpld_dl <= #tDLY 0;
		cpld_tlen <= #tDLY 0; 
		dma_rr_si <= #tDLY 1'b0;
		dma_rd_r <= #tDLY 1'b0;
		dma_rabt_ack_r <= #tDLY 1'b0;
	end
	else
	begin
		case (ep_rx_state)
			ep_rx_s0 :					 
			begin							
				if ((!trn_lnk_up_n_r) || (!dma_rabt_rq))	// Transaction link-up is asserted when the core and the connected upstream link partner port...	 
				begin											// ...are ready and able to exchange data packets
					ep_rx_state <= #tDLY ep_rx_s1;
				end
				
				if (dma_rabt_rq)
				begin
					dma_rabt_ack_r <= #tDLY 1'b1; 
				end
				else
				begin
					dma_rabt_ack_r <= #tDLY 1'b0; 
				end
				
				trn_rdst_rdy_n_r <= #tDLY 1'b0;
				
				b0_w32_w_r <= #tDLY 1'b0;
				b0_w32_be_r <= #tDLY 0;
				b0_w32_d_r <= #tDLY 0;
				b0_w32_a_r <= #tDLY 0;
				b0_r32_r_r <= #tDLY 1'b0;
				b0_r32_be_i <= #tDLY 0;
				b0_r32_be_r <= #tDLY 0;
				b0_r32_a_r <= #tDLY 0;
				b0_r32_tc_i <= #tDLY 0;
				b0_r32_at_i <= #tDLY 0;
				b0_r32_rqid_i <= #tDLY 0;
				b0_r32_tg_i <= #tDLY 0;
				b0_r32_tc_r <= #tDLY 0;
				b0_r32_at_r <= #tDLY 0;
				b0_r32_rqid_r <= #tDLY 0;
				b0_r32_tg_r <= #tDLY 0;
				b0_cpld_ar <= #tDLY 1'b0;
				
				b1_w32_w_r <= #tDLY 1'b0;
				b1_w32_be_r <= #tDLY 0;
				b1_w32_d_r <= #tDLY 0;
				b1_w32_a_r <= #tDLY 0;
				b1_r32_r_r <= #tDLY 1'b0;
				b1_r32_be_i <= #tDLY 0;
				b1_r32_be_r <= #tDLY 0;
				b1_r32_a_r <= #tDLY 0;
				b1_r32_tc_i <= #tDLY 0;
				b1_r32_at_r <= #tDLY 0;
				b1_r32_rqid_i <= #tDLY 0;
				b1_r32_tg_i <= #tDLY 0;
				b1_r32_tc_r <= #tDLY 0;
				b1_r32_at_r <= #tDLY 0;
				b1_r32_rqid_r <= #tDLY 0;
				b1_r32_tg_r <= #tDLY 0;
				b1_cpld_ar <= #tDLY 1'b0;
				
				fifo_w_r <= #tDLY { tags {1'b0} };//tags'b00000000;

				cpld_dl <= #tDLY 0;
				cpld_tlen <= #tDLY 0; 
				dma_rr_si <= #tDLY 1'b0;
				dma_rd_r <= #tDLY 1'b0;
			end
			
			ep_rx_s1 :
			begin
				if (!dma_rabt_rq)
				begin
					if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
					begin						// ...when communication with the link partner is lost due to errors on the transmission channel
						ep_rx_state <= #tDLY ep_rx_s0;
						
						trn_rdst_rdy_n_r <= #tDLY 1'b0;
					end
					else if ((!trn_rsof_n) && (!trn_rsrc_rdy_n) && (!trn_rdst_rdy_n))
					begin
						//CplD, thus downstream DMA
						if ((trn_rd[62:56] == `CplD_FMT_TYPE) && (trn_rd[15:13] == 3'b000) && trn_rerrfwd_n && dma_rs)
						begin
							ep_rx_state <= #tDLY ep_rx_s8;
							
							cpld_len <= #tDLY trn_rd[41:32];
							cpld_remain_bytes <= #tDLY trn_rd[11:0];
							
							cpld_tlen <= #tDLY (trn_rd[41:32] == 0) ? 11'h400 : {1'b0, trn_rd[41:32]}; 
							dma_rr_si <= #tDLY 1'b1;
						end
						else if (!trn_rbar_hit_n[0])
						begin
							if (trn_rd[62:56] == `MWr32_FMT_TYPE)
							begin
								if ((trn_rd[41:32] == 10'b0000000001) && trn_rerrfwd_n)	// Memory Write TLP of lengths larger than one DWORD...
								begin													// ...are not processed correctly and this TLP is discarded
									ep_rx_state <= #tDLY ep_rx_s2;
									
									b0_w32_be_r <= #tDLY trn_rd[3:0];
								end
								
								trn_rdst_rdy_n_r <= #tDLY 1'b0;
							end
							else if (trn_rd[62:56] == `MRd32_FMT_TYPE)
							begin
								if ((trn_rd[41:32] == 10'b0000000001) && trn_rerrfwd_n)	// Memory Read TLP of lengths larger than one DWORD...
								begin												   	// ...are not processed correctly and this TLP is discarded
									ep_rx_state <= #tDLY ep_rx_s3;
									
									b0_r32_tc_i <= #tDLY trn_rd[54:52];
									b0_r32_at_i <= #tDLY trn_rd[45:44];
									b0_r32_rqid_i <= #tDLY trn_rd[31:16];
									b0_r32_tg_i <= #tDLY trn_rd[15:8];
									b0_r32_be_i <= #tDLY trn_rd[3:0];
									
									if (!b0_cpld_rdy_n)
									begin
										trn_rdst_rdy_n_r <= #tDLY 1'b0;
									end
									else
									begin
										trn_rdst_rdy_n_r <= #tDLY 1'b1;
									end
								end
								else
								begin
									trn_rdst_rdy_n_r <= #tDLY 1'b0;
								end
							end
							else
							begin
								trn_rdst_rdy_n_r <= #tDLY 1'b0;
							end
						end
						else if (!trn_rbar_hit_n[1]) 
						begin
							if (trn_rd[62:56] == `MWr32_FMT_TYPE)
							begin
								if ((trn_rd[41:32] == 10'b0000000001) && trn_rerrfwd_n)	// Memory Write TLP of lengths larger than one DWORD...
								begin													// ...are not processed correctly and this TLP is discarded
									ep_rx_state <= #tDLY ep_rx_s5;
									
									b1_w32_be_r <= #tDLY trn_rd[3:0];
								end
								
								trn_rdst_rdy_n_r <= #tDLY 1'b0;
							end
							else if (trn_rd[62:56] == `MRd32_FMT_TYPE)
							begin
								if ((trn_rd[41:32] == 10'b0000000001) && trn_rerrfwd_n)	// Memory Read TLP of lengths larger than one DWORD...
								begin												   	// ...are not processed correctly and this TLP is discarded
									ep_rx_state <= #tDLY ep_rx_s6;
									
									b1_r32_tc_i <= #tDLY trn_rd[54:52];
									b1_r32_at_i <= #tDLY trn_rd[45:44];
									b1_r32_rqid_i <= #tDLY trn_rd[31:16];
									b1_r32_tg_i <= #tDLY trn_rd[15:8];
									b1_r32_be_i <= #tDLY trn_rd[3:0];
									
									if (!b1_cpld_rdy_n)
									begin
										trn_rdst_rdy_n_r <= #tDLY 1'b0;
									end
									else
									begin
										trn_rdst_rdy_n_r <= #tDLY 1'b1;
									end
								end
								else
								begin
									trn_rdst_rdy_n_r <= #tDLY 1'b0;
								end
							end
							else
							begin
								trn_rdst_rdy_n_r <= #tDLY 1'b0;
							end
						end
						else
						begin
							trn_rdst_rdy_n_r <= #tDLY 1'b0;
						end
					end
					else
					begin
						trn_rdst_rdy_n_r <= #tDLY 1'b0;
					end 
				end
				else
				begin
					trn_rdst_rdy_n_r <= #tDLY 1'b0;
				end
				
				if (dma_rabt_rq)
				begin
					dma_rabt_ack_r <= #tDLY 1'b1; 
				end
				else
				begin
					dma_rabt_ack_r <= #tDLY 1'b0; 
				end
				
				b0_w32_w_r <= #tDLY 1'b0;
				b1_w32_w_r <= #tDLY 1'b0;
				
				fifo_w_r <= #tDLY { tags {1'b0} };//tags'b00000000;
			end
			
			ep_rx_s2 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_rx_state <= #tDLY ep_rx_s0;
				end
				else if ((!trn_reof_n) && (!trn_rsrc_rdy_n) && (!trn_rdst_rdy_n))
				begin
					ep_rx_state <= #tDLY ep_rx_s1;
					
					b0_w32_w_r <= #tDLY 1'b1;
					b0_w32_d_r <= #tDLY {trn_rd[7:0], trn_rd[15:8], trn_rd[23:16], trn_rd[31:24]};
					b0_w32_a_r <= #tDLY trn_rd[63:32];
				end
				
				trn_rdst_rdy_n_r <= #tDLY 1'b0;
			end
				
			ep_rx_s3 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_rx_state <= #tDLY ep_rx_s0;
					
					trn_rdst_rdy_n_r <= #tDLY 1'b0;
				end
				else if ((!trn_reof_n) && (!trn_rsrc_rdy_n) && (!trn_rdst_rdy_n))
				begin
					ep_rx_state <= #tDLY ep_rx_s4;
					
					b0_cpld_ar <= #tDLY 1'b1;
					b0_r32_r_r <= #tDLY 1'b1; 
					b0_r32_a_r <= #tDLY trn_rd[63:32];
					
					trn_rdst_rdy_n_r <= #tDLY 1'b1;
				end
				else
				begin
					if (!b0_cpld_rdy_n)
					begin
						trn_rdst_rdy_n_r <= #tDLY 1'b0;
					end
					else
					begin
						trn_rdst_rdy_n_r <= #tDLY 1'b1;
					end
				end
			end
			
			ep_rx_s4 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_rx_state <= #tDLY ep_rx_s0;
				end
				else
				begin
					ep_rx_state <= #tDLY ep_rx_s1;
				end
				
				trn_rdst_rdy_n_r <= #tDLY 1'b0;
				
				b0_r32_r_r <= #tDLY 1'b0;
				b0_cpld_ar <= #tDLY 1'b0;
				b0_r32_tc_r <= #tDLY b0_r32_tc_i;
				b0_r32_at_r <= #tDLY b0_r32_at_i;
				b0_r32_rqid_r <= #tDLY b0_r32_rqid_i;
				b0_r32_tg_r <= #tDLY b0_r32_tg_i;
				b0_r32_be_r <= #tDLY b0_r32_be_i;
			end
			
			ep_rx_s5 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_rx_state <= #tDLY ep_rx_s0;
				end
				else if ((!trn_reof_n) && (!trn_rsrc_rdy_n) && (!trn_rdst_rdy_n))
				begin
					ep_rx_state <= #tDLY ep_rx_s1;
					
					b1_w32_w_r <= #tDLY 1'b1;
					b1_w32_d_r <= #tDLY {trn_rd[7:0], trn_rd[15:8], trn_rd[23:16], trn_rd[31:24]};
					b1_w32_a_r <= #tDLY trn_rd[63:32];
				end
				
				trn_rdst_rdy_n_r <= #tDLY 1'b0;
			end
			
			ep_rx_s6 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_rx_state <= #tDLY ep_rx_s0;
					
					trn_rdst_rdy_n_r <= #tDLY 1'b0;
				end
				else if ((!trn_reof_n) && (!trn_rsrc_rdy_n) && (!trn_rdst_rdy_n))
				begin
					ep_rx_state <= #tDLY ep_rx_s7;
					
					b1_cpld_ar <= #tDLY 1'b1;
					b1_r32_r_r <= #tDLY 1'b1;
					b1_r32_a_r <= #tDLY trn_rd[63:32];
					
					trn_rdst_rdy_n_r <= #tDLY 1'b1;
				end
				else
				begin
					if (!b1_cpld_rdy_n)
					begin
						trn_rdst_rdy_n_r <= #tDLY 1'b0;
					end
					else
					begin
						trn_rdst_rdy_n_r <= #tDLY 1'b1;
					end
				end
			end
			
			ep_rx_s7 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_rx_state <= #tDLY ep_rx_s0;
				end
				else
				begin
					ep_rx_state <= #tDLY ep_rx_s1;
				end
				
				trn_rdst_rdy_n_r <= #tDLY 1'b0;
				
				b1_r32_r_r <= #tDLY 1'b0;
				b1_cpld_ar <= #tDLY 1'b0;
				b1_r32_tc_r <= #tDLY b1_r32_tc_i;
				b1_r32_at_r <= #tDLY b1_r32_at_i;
				b1_r32_rqid_r <= #tDLY b1_r32_rqid_i;
				b1_r32_tg_r <= #tDLY b1_r32_tg_i;
				b1_r32_be_r <= #tDLY b1_r32_be_i;
			end
			
			ep_rx_s8 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_rx_state <= #tDLY ep_rx_s0;
				end
				else if ((!trn_rsrc_rdy_n) && (!trn_rdst_rdy_n))
				begin
					ep_rx_state <= #tDLY ep_rx_s9;
					
					index <= #tDLY trn_rd[40+tags_width-1:40];
					cpld_dl <= #tDLY {trn_rd[7:0], trn_rd[15:8], trn_rd[23:16], trn_rd[31:24]};
				end
				
				trn_rdst_rdy_n_r <= #tDLY 1'b0;
				
				dma_rr_si <= #tDLY 1'b0;
			end
			
			// down stream fifo write;			
			ep_rx_s9 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_rx_state <= #tDLY ep_rx_s0;
				end
				else if ((!trn_reof_n) && (!trn_rsrc_rdy_n) && (!trn_rdst_rdy_n))
				begin
					if (dma_rr_s >= dmarxs[31:2])
					begin
						ep_rx_state <= #tDLY ep_rx_sa; 
						
						trn_rdst_rdy_n_r <= #tDLY 1'b1;
						
						dma_rd_r <= #tDLY 1'b1;
					end
					else
					begin
						ep_rx_state <= #tDLY ep_rx_s1; 
					
						trn_rdst_rdy_n_r <= #tDLY 1'b0;
					end
				end
				else
				begin
					trn_rdst_rdy_n_r <= #tDLY 1'b0;
				end
				
				if ((!trn_rsrc_rdy_n) && (!trn_rdst_rdy_n))
				begin
					fifo_w_r[index] <= #tDLY 1'b1; //to be modified according to tags;
					fifo_d_r <= #tDLY {trn_rd[39:32], trn_rd[47:40], trn_rd[55:48], trn_rd[63:56], cpld_dl};
					
					cpld_dl <= #tDLY {trn_rd[7:0], trn_rd[15:8], trn_rd[23:16], trn_rd[31:24]};
				end
				else
				begin
					fifo_w_r <= #tDLY { tags {1'b0} };//tags'b00000000;
				end
			end
			
			ep_rx_sa :
			begin
				ep_rx_state <= #tDLY ep_rx_s1; 
					
				trn_rdst_rdy_n_r <= #tDLY 1'b0;
				
				dma_rd_r <= #tDLY 1'b0;
				
				fifo_w_r <= #tDLY { tags {1'b0} };//tags'b00000000;
			end
			
			default :
			begin
				ep_rx_state <= #tDLY 'bx;
		
				trn_rdst_rdy_n_r <= #tDLY 1'bx;
				
				b0_w32_w_r <= #tDLY 1'bx;
				b0_w32_be_r <= #tDLY 'bx;
				b0_w32_d_r <= #tDLY 'bx;
				b0_w32_a_r <= #tDLY 'bx;
				b0_r32_r_r <= #tDLY 1'bx;
				b0_r32_be_i <= #tDLY 'bx;
				b0_r32_be_r <= #tDLY 'bx;
				b0_r32_a_r <= #tDLY 'bx;
				b0_r32_tc_i <= #tDLY 'bx;
				b0_r32_at_i <= #tDLY 'bx;
				b0_r32_rqid_i <= #tDLY 'bx;
				b0_r32_tg_i <= #tDLY 'bx;
				b0_r32_tc_r <= #tDLY 'bx;
				b0_r32_at_r <= #tDLY 'bx;
				b0_r32_rqid_r <= #tDLY 'bx;
				b0_r32_tg_r <= #tDLY 'bx;
				
				b1_w32_w_r <= #tDLY 1'bx;
				b1_w32_be_r <= #tDLY 'bx;
				b1_w32_d_r <= #tDLY 'bx;
				b1_w32_a_r <= #tDLY 'bx;
				b1_r32_r_r <= #tDLY 1'bx;
				b1_r32_be_i <= #tDLY 'bx;
				b1_r32_be_r <= #tDLY 'bx;
				b1_r32_a_r <= #tDLY 'bx;
				b1_r32_tc_i <= #tDLY 'bx;
				b1_r32_at_r <= #tDLY 'bx;
				b1_r32_rqid_i <= #tDLY 'bx;
				b1_r32_tg_i <= #tDLY 'bx;
				b1_r32_tc_r <= #tDLY 'bx;
				b1_r32_at_r <= #tDLY 'bx;
				b1_r32_rqid_r <= #tDLY 'bx;
				b1_r32_tg_r <= #tDLY 'bx;
				
				fifo_w_r <= #tDLY { tags {1'bx} };//tags'bxxxxxxxx;
				fifo_d_r <= #tDLY 64'hxxxxxxxxxxxxxxxx;
				
				cpld_dl <= #tDLY 'bx;
				cpld_tlen <= #tDLY 'bx; 
				dma_rr_si <= #tDLY 1'bx;
				dma_rd_r <= #tDLY 1'bx;
				dma_rabt_ack_r <= #tDLY 1'bx;
			end
		endcase
	end
end


//---------------------------------------------------------------------
// dma_rr_s Accumulator
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
        dma_rr_s <= #tDLY 0;
	end
	else
	begin
		if (trn_lnk_up_n_r || (ep_rx_state == ep_rx_s0) || (ep_rx_state == ep_rx_sa) || ((ep_rx_state == ep_rx_s1) && dma_rabt_rq))
		begin
			dma_rr_s <= #tDLY 0;
		end
		else if (dma_rr_si)
		begin
	       	dma_rr_s <= #tDLY dma_rr_s + {19'h00000, cpld_tlen};
		end
	end
end

always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		fifo_rdy_r <= #tDLY { tags {1'b0} };
	end
	else
	begin
		if ((ep_rx_state == ep_rx_s9) && (cpld_len == cpld_remain_bytes[11:2]))
		begin
			fifo_rdy_r[index] <= #tDLY 1'b1;
		end
		else 
		begin 
			fifo_rdy_r[0] <= #tDLY (fifo_ack_pcie_ds[0] == 1'b1) ? 1'b0 : fifo_rdy_r[0];
			fifo_rdy_r[1] <= #tDLY (fifo_ack_pcie_ds[1] == 1'b1) ? 1'b0 : fifo_rdy_r[1];
			fifo_rdy_r[2] <= #tDLY (fifo_ack_pcie_ds[2] == 1'b1) ? 1'b0 : fifo_rdy_r[2];
			fifo_rdy_r[3] <= #tDLY (fifo_ack_pcie_ds[3] == 1'b1) ? 1'b0 : fifo_rdy_r[3];
			fifo_rdy_r[4] <= #tDLY (fifo_ack_pcie_ds[4] == 1'b1) ? 1'b0 : fifo_rdy_r[4];
			fifo_rdy_r[5] <= #tDLY (fifo_ack_pcie_ds[5] == 1'b1) ? 1'b0 : fifo_rdy_r[5];
			fifo_rdy_r[6] <= #tDLY (fifo_ack_pcie_ds[6] == 1'b1) ? 1'b0 : fifo_rdy_r[6];
			fifo_rdy_r[7] <= #tDLY (fifo_ack_pcie_ds[7] == 1'b1) ? 1'b0 : fifo_rdy_r[7];
			fifo_rdy_r[8] <= #tDLY (fifo_ack_pcie_ds[8] == 1'b1) ? 1'b0 : fifo_rdy_r[8];
			fifo_rdy_r[9] <= #tDLY (fifo_ack_pcie_ds[9] == 1'b1) ? 1'b0 : fifo_rdy_r[9];
			fifo_rdy_r[10] <= #tDLY (fifo_ack_pcie_ds[10] == 1'b1) ? 1'b0 : fifo_rdy_r[10];
			fifo_rdy_r[11] <= #tDLY (fifo_ack_pcie_ds[11] == 1'b1) ? 1'b0 : fifo_rdy_r[11];
			fifo_rdy_r[12] <= #tDLY (fifo_ack_pcie_ds[12] == 1'b1) ? 1'b0 : fifo_rdy_r[12];
			fifo_rdy_r[13] <= #tDLY (fifo_ack_pcie_ds[13] == 1'b1) ? 1'b0 : fifo_rdy_r[13];
			fifo_rdy_r[14] <= #tDLY (fifo_ack_pcie_ds[14] == 1'b1) ? 1'b0 : fifo_rdy_r[14];
			fifo_rdy_r[15] <= #tDLY (fifo_ack_pcie_ds[15] == 1'b1) ? 1'b0 : fifo_rdy_r[15];
		end	
	end
end
//				if (cpld_len == cpld_remain_bytes[11:2])
//				begin
//					fifo_rdy_r[index] <= #tDLY 1'b1;
//				end
//				else if(fifo_ack_pcie_ds[index] == 1'b1)
//				begin
//					fifo_rdy_r[index] <= #tDLY 1'b0;
//				end

//---------------------------------------------------------------------
// B0_ARB_FSM Finite State Machine(one process)
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		b0_arb_state <= #tDLY b0_arb_s0;
		
		b0_cpld_rq_r <= #tDLY 1'b0;
		
		b0_cpld_rdy_n <= #tDLY 1'b0; 
	end
	else
	begin
		case (b0_arb_state)
			b0_arb_s0 :
			begin
				if (b0_cpld_ar)
				begin
					b0_arb_state <= #tDLY b0_arb_s1;
					
					b0_cpld_rq_r <= #tDLY 1'b1;
					
					b0_cpld_rdy_n <= #tDLY 1'b1; 
				end
			end
				
			b0_arb_s1 :
			begin
				if (trn_lnk_up_n_r || b0_cpld_ack)	// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin									// ...when communication with the link partner is lost due to errors on the transmission channel
					b0_arb_state <= #tDLY b0_arb_s0;
					
					b0_cpld_rq_r <= #tDLY 1'b0;
					
					b0_cpld_rdy_n <= #tDLY 1'b0;
				end
			end
			
			default :
			begin
				b0_arb_state <= #tDLY 'bx;
		
				b0_cpld_rq_r <= #tDLY 1'bx;
				
				b0_cpld_rdy_n <= #tDLY 1'bx;
			end
		endcase
	end
end


//---------------------------------------------------------------------
// B1_ARB_FSM Finite State Machine(one process)
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		b1_arb_state <= #tDLY b1_arb_s0;
		
		b1_cpld_rq_r <= #tDLY 1'b0;
		
		b1_cpld_rdy_n <= #tDLY 1'b0; 
	end
	else
	begin
		case (b1_arb_state)
			b1_arb_s0 :
			begin
				if (b1_cpld_ar)
				begin
					b1_arb_state <= #tDLY b1_arb_s1;
					
					b1_cpld_rq_r <= #tDLY 1'b1;
					
					b1_cpld_rdy_n <= #tDLY 1'b1; 
				end
			end
				
			b1_arb_s1 :
			begin
				if (trn_lnk_up_n_r || b1_cpld_ack)	// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin									// ...when communication with the link partner is lost due to errors on the transmission channel
					b1_arb_state <= #tDLY b1_arb_s0;
					
					b1_cpld_rq_r <= #tDLY 1'b0;
					
					b1_cpld_rdy_n <= #tDLY 1'b0;
				end
			end
			
			default :
			begin
				b1_arb_state <= #tDLY 'bx;
		
				b1_cpld_rq_r <= #tDLY 1'bx;
				
				b1_cpld_rdy_n <= #tDLY 1'bx;
			end
		endcase
	end
end



//---------------------------------------------------------------------
// Receive Completion Streaming trn_rcpl_streaming_n
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
	trn_rcpl_streaming_n_r <= #tDLY 1'b1;
	end
	else
	begin
		if (trn_lnk_up_n_r || (ep_rx_state == ep_rx_s0) || dma_rd_r || ((ep_rx_state == ep_rx_s1) && dma_rabt_rq))
		begin
			trn_rcpl_streaming_n_r <= #tDLY 1'b1;
		end
		else if (dma_rs)
		begin
			trn_rcpl_streaming_n_r <= #tDLY 1'b0;
		end
	end
end


//---------------------------------------------------------------------
// Receive Non-Posted OK trn_rnp_ok_n
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		trn_rnp_ok_n_r <= #tDLY 1'b0;
	end
	else
	begin
		trn_rnp_ok_n_r <= #tDLY 1'b0;
	end
end


endmodule