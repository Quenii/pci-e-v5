///////////////////////////////////////////////////////////////////////////////
//  2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  tx_trn_fsm.v
//  /   /        Date Last Modified: June. 15th, 2009 
// /___/   /\    Date Created: Apr. 1st, 2009
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT/FXT/TXT
// Purpose: Transmit TRN State Machine module.  Interfaces to the Endpoint
// Block Plus and transmits packtets including Posted, Non-Posted and 
// Completion out of the TRN interface.  Drains the packets out of FIFOs.
// Reference:
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2009.
///////////////////////////////////////////////////////////////////////////////
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



module tx_trn_fsm 
	# (
		parameter	tDLY		= 0							// Simulation delay
	)
	
	(
		// Common TRN Interface
		input					trn_clk,					// Transaction Clock, Rising Edge
		input					trn_lnk_up_n,				// Transaction Link Up, Active low
		input					trn_reset_n,				// Transaction Reset, Active low
		
		// DMA Control and Status Register
		input		[31:0]		dmawad_l,					//
		input		[31:0]		dmawad_u,					//
		input		[31:0]		dmaras_l,					//
		input		[31:0]		dmaras_u,					//
				
		input					dma_wabt_rq,				//
		output					dma_wabt_ack,				//
		input					dma_rabt_rq,				//
		output					dma_rabt_ack,				//
		input					dma_ws,						//
		output					dma_wd,						//
		input					dma_rs,						//
		input					dma_rd,						//
		
		// Posted Packet Slicer Information
		input		[10:0]		dmawtlp_sz,					//
		input		[24:0]		dmawtlp_num,				//
		
		// Non-Posted Packet Slicer Information
		input		[10:0]		dmartlp_sz,					//
		input		[24:0]		dmartlp_num,				//
		
		// Command and Status Registers
		input		[7:0]		cfg_bus_number,				// Configuration Bus Number
		input		[4:0]		cfg_device_number,			// Configuration Device Number
		input		[2:0]		cfg_function_number,		// Configuration Function Number
		input					cfg_relaxed_ordering_en,	// Enable Relaxed Ordering
		input					cfg_extended_tag_en,		// Extended Tag Field Enable 
		input					cfg_bus_master_en,			// Bus Master Enable
		
		// FIFO Interface for PCI Express Upstream
		output					fifo_rdreq_pcie_us,			// fifo read request
		input		[63:0]		fifo_q_pcie_us,				// fifo read data
		input					fifo_empty_pcie_us,			// fifo empty
		
		// B0 Arb
		input					b0_cpld_rq,					//
		output					b0_cpld_ack,				//
		
		// B0 Info
		input		[2:0]		b0_r32_tc,					//
		input		[1:0]		b0_r32_at,					//
		input		[15:0]		b0_r32_rqid,				//
		input		[7:0]		b0_r32_tg,					//
		input		[3:0]		b0_r32_be,					//
		input		[31:0]		b0_r32_a,					//
		input		[31:0]		b0_r32_q,					//
		
		// B1 Arb
		input					b1_cpld_rq,					//
		output					b1_cpld_ack,				//
		
		// B1 Info
		input		[2:0]		b1_r32_tc,					//
		input		[1:0]		b1_r32_at,					//
		input		[15:0]		b1_r32_rqid,				//
		input		[7:0]		b1_r32_tg,					//
		input		[3:0]		b1_r32_be,					//
		input		[31:0]		b1_r32_a,					//
		input		[31:0]		b1_r32_q,					//
		
		// Transmit TRN Interface
		output					trn_tsof_n,					// Transmit Start-of-Frame (SOF), Active low
		output					trn_teof_n,					// Transmit End-of-Frame (EOF), Active low
		output					trn_tsrc_rdy_n,				// Transmit Source Ready, Active low
		input					trn_tdst_rdy_n,				// Transmit Destination Ready, Active low
		output		[7:0]		trn_trem_n,					// Transmit Data Remainder
		output		[63:0]		trn_td,						// Transmit Data
		output					trn_tsrc_dsc_n,				// Transmit Source Discontinue, Active low
		input					trn_tdst_dsc_n,				// Transmit Destination Discontinue, Active low
		input		[3:0]		trn_tbuf_av					// Transmit Buffers Available
);






//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
reg		[4:0]		ep_tx_state;

reg		[8:0]		dmaw_ts_qws2;
reg		[31:0]		dmawad_l_r;			
reg		[8:0]		pst_qw_cnt;
reg		[24:0]		tx_psttlp_cnt;
reg					sw;
reg					fifo_r_en;
reg		[31:0]		fifo_q_u;
reg					psttlp_n1;
reg					tx_psttlpcpl;
reg					dmawd_r;
reg					dmawa_ack_r;
reg					dmara_ack_r;

reg		[31:0]		dmaras_l_r;
reg		[24:0]		tx_npsttlp_cnt;
reg		[7:0]		npsttlp_tg;
reg					tx_npsttlp_cpl;
reg					tx_npsttlp_cpl_lev;
reg					npsttlp_n1;

reg					rnd_rob_inc;
reg		[1:0]		rnd_rob_cnt;

reg		[7:0]		cfg_bus_number_r;
reg		[4:0]		cfg_device_number_r;
reg		[2:0]		cfg_function_number_r;
reg					cfg_relaxed_ordering_en_r;
reg					cfg_extended_tag_en_r; 
reg					cfg_bus_master_en_r;

reg					trn_tsof_n_r;
reg					trn_teof_n_r;
reg					trn_tsrc_rdy_n_r;
reg		[7:0]		trn_trem_n_r;
reg		[63:0]		trn_td_r;	
reg					trn_tsrc_dsc_n_r;

reg					npst_tb_av;
reg					pst_tb_av;
reg					cpl_tb_av;

reg		[11:0]		b0_r32_bc;
reg		[6:0]		b0_r32_a_l;
reg		[11:0]		b1_r32_bc;
reg		[6:0]		b1_r32_a_l;
reg					b0_cpld_ack_r;
reg					b1_cpld_ack_r;

reg					trn_lnk_up_n_r;



//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------
wire				fifo_r_i;

wire				npsttlp_ord;

wire	[15:0]		rqid;
wire	[15:0]		cplid;



//---------------------------------------------------------------------
// EP_TX_FSM state variable assignments (sequential coded) 
//---------------------------------------------------------------------
localparam 	ep_tx_s0	= 5'b00000;
localparam 	ep_tx_s1 	= 5'b00001;
localparam 	ep_tx_s2 	= 5'b00010;
localparam 	ep_tx_s3 	= 5'b00011;
localparam 	ep_tx_s4 	= 5'b00100;
localparam 	ep_tx_s5 	= 5'b00101;
localparam 	ep_tx_s6	= 5'b00110;
localparam 	ep_tx_s7 	= 5'b00111;
localparam 	ep_tx_s8	= 5'b01000;
localparam 	ep_tx_s9 	= 5'b01001;
localparam 	ep_tx_sa 	= 5'b01010;
localparam 	ep_tx_sb 	= 5'b01011;
localparam 	ep_tx_sc	= 5'b01100;
localparam 	ep_tx_sd 	= 5'b01101;
localparam 	ep_tx_se 	= 5'b01110;
localparam 	ep_tx_sf 	= 5'b01111;
localparam 	ep_tx_s10 	= 5'b10000;
localparam 	ep_tx_s11 	= 5'b10001;
localparam	ep_tx_s12	= 5'b10010;
localparam	ep_tx_s13	= 5'b10011;






//---------------------------------------------------------------------
// Input Register
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		trn_lnk_up_n_r <= #tDLY 1'b1;
		
		cfg_bus_number_r <= #tDLY 0;
		
		cfg_device_number_r <= #tDLY 0; 
		
		cfg_function_number_r <= #tDLY 0; 
		
		cfg_relaxed_ordering_en_r <= #tDLY 1'b0;		
		
		cfg_extended_tag_en_r <= #tDLY 1'b0;			

		cfg_bus_master_en_r <= #tDLY 1'b0;			
		
		npst_tb_av <= #tDLY 1'b0;
		pst_tb_av <= #tDLY 1'b0;
		cpl_tb_av <= #tDLY 1'b0;
	end
	else
	begin
		trn_lnk_up_n_r <= #tDLY trn_lnk_up_n;
		
		cfg_bus_number_r <= #tDLY cfg_bus_number;
		
		cfg_device_number_r <= #tDLY cfg_device_number; 
		
		cfg_function_number_r <= #tDLY cfg_function_number; 
		
		cfg_relaxed_ordering_en_r <= #tDLY cfg_relaxed_ordering_en;		
		
		cfg_extended_tag_en_r <= #tDLY cfg_extended_tag_en;			

		cfg_bus_master_en_r <= #tDLY cfg_bus_master_en;
		
		npst_tb_av <= #tDLY trn_tbuf_av[0];
		pst_tb_av <= #tDLY trn_tbuf_av[1];
		cpl_tb_av <= #tDLY trn_tbuf_av[2];
	end
end


always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		dmaw_ts_qws2 <= #tDLY 0;
	end
	else
	begin
		dmaw_ts_qws2 <= #tDLY dmawtlp_sz[9:1] - 2'b10;
	end
end


assign 	rqid = {cfg_bus_number_r, cfg_device_number_r, cfg_function_number_r};
assign 	cplid = {cfg_bus_number_r, cfg_device_number_r, cfg_function_number_r};

assign 	npsttlp_ord = cfg_relaxed_ordering_en_r;

assign	dma_wabt_ack = dmawa_ack_r;
assign	dma_rabt_ack = dmara_ack_r;
assign 	dma_wd = dmawd_r;



//---------------------------------------------------------------------
// EP_TX_FSM Finite State Machine(one process)
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		ep_tx_state <= #tDLY ep_tx_s0;
		
		trn_tsof_n_r     <= #tDLY 1'b1;
        trn_teof_n_r     <= #tDLY 1'b1;
        trn_tsrc_rdy_n_r <= #tDLY 1'b1;
        trn_td_r         <= #tDLY 64'h0000000000000000;
        trn_trem_n_r     <= #tDLY 8'h00;
        trn_tsrc_dsc_n_r <= #tDLY 1'b1;
        
        sw <= #tDLY 1'b0; 
		fifo_r_en <= #tDLY 1'b0;
		
		rnd_rob_inc <= #tDLY 1'b0; 
		
		fifo_q_u <= #tDLY 32'h00000000;
		
		psttlp_n1 <= #tDLY 1'b0;
		tx_psttlpcpl <= #tDLY 1'b0;
		dmawd_r <= #tDLY 1'b0;
		
		npsttlp_n1 <= #tDLY 1'b0;
		tx_npsttlp_cpl <= #tDLY 1'b0;
		
		b0_cpld_ack_r <= #tDLY 1'b0;
        b1_cpld_ack_r <= #tDLY 1'b0;
        
        dmawa_ack_r <= #tDLY 1'b0;
        dmara_ack_r <= #tDLY 1'b0;
	end
	else
	begin
		case (ep_tx_state)
			ep_tx_s0 :					 
			begin	
				//not linkup, DMA read/Write Abort;
				if ((!trn_lnk_up_n_r) && (!dma_wabt_rq) && (!dma_rabt_rq))	// Transaction link-up is asserted when the core and the connected upstream link partner port... 
				begin																	// ...are ready and able to exchange data packets
					ep_tx_state <= #tDLY ep_tx_s1;
				end
				
				if (dma_wabt_rq)
				begin
					dmawa_ack_r <= #tDLY 1'b1; 
				end
				else
				begin
					dmawa_ack_r <= #tDLY 1'b0; 
				end
				
				if (dma_rabt_rq)
				begin
					dmara_ack_r <= #tDLY 1'b1; 
				end
				else
				begin
					dmara_ack_r <= #tDLY 1'b0; 
				end
				
				trn_tsof_n_r     <= #tDLY 1'b1;
		        trn_teof_n_r     <= #tDLY 1'b1;
		        trn_tsrc_rdy_n_r <= #tDLY 1'b1;
        		trn_trem_n_r     <= #tDLY 8'h00;
        		trn_tsrc_dsc_n_r <= #tDLY 1'b1;	
        		
        		sw <= #tDLY 1'b0; 
        		fifo_r_en <= #tDLY 1'b0;
        		
        		rnd_rob_inc <= #tDLY 1'b0;
        		
        		psttlp_n1 <= #tDLY 1'b0;
        		tx_psttlpcpl <= #tDLY 1'b0;
        		dmawd_r <= #tDLY 1'b0;
        		
        		npsttlp_n1 <= #tDLY 1'b0;
				tx_npsttlp_cpl <= #tDLY 1'b0;
		        
		        b0_cpld_ack_r <= #tDLY 1'b0;
        		b1_cpld_ack_r <= #tDLY 1'b0;				
			end
			
			ep_tx_s1 :
			begin
				if ((!dma_wabt_rq) && (!dma_rabt_rq))
				begin
					//Linked up
					if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
					begin						// ...when communication with the link partner is lost due to errors on the transmission channel
						ep_tx_state <= #tDLY ep_tx_s0;
					end
					else if (cfg_bus_master_en_r && pst_tb_av && dma_ws && (!fifo_empty_pcie_us))
					begin
						ep_tx_state <= #tDLY ep_tx_s2;
					end
					else if (cfg_bus_master_en_r && npst_tb_av && dma_rs && (!tx_npsttlp_cpl_lev))
					begin
						ep_tx_state <= #tDLY ep_tx_s8;
					end
					else if (cpl_tb_av)
					begin
						if (b0_cpld_rq)
						begin
							ep_tx_state <= #tDLY ep_tx_sc;
						end
						else if (b1_cpld_rq) 
						begin
							ep_tx_state <= #tDLY ep_tx_sf;
						end 
					end
				end
				
				if (dma_wabt_rq)
				begin
					dmawa_ack_r <= #tDLY 1'b1; 
					
					sw <= #tDLY 1'b0; 
					fifo_r_en <= #tDLY 1'b0;
		
					psttlp_n1 <= #tDLY 1'b0;
        			tx_psttlpcpl <= #tDLY 1'b0;
        			dmawd_r <= #tDLY 1'b0;
				end
				else
				begin
					dmawa_ack_r <= #tDLY 1'b0; 
				end
				
				if (dma_rabt_rq)
				begin
					dmara_ack_r <= #tDLY 1'b1; 
					
					npsttlp_n1 <= #tDLY 1'b0;
					tx_npsttlp_cpl <= #tDLY 1'b0;
				end
				else
				begin
					dmara_ack_r <= #tDLY 1'b0; 
				end
				
				trn_tsof_n_r     <= #tDLY 1'b1;
		        trn_teof_n_r     <= #tDLY 1'b1;
		        trn_tsrc_rdy_n_r <= #tDLY 1'b1;
			end
			
			ep_tx_s2 :
			begin
				ep_tx_state <= #tDLY ep_tx_s3;
				
				trn_tsof_n_r     <= #tDLY 1'b0;
        		trn_teof_n_r     <= #tDLY 1'b1;
        		trn_tsrc_rdy_n_r <= #tDLY 1'b0;
        		trn_td_r         <= #tDLY { 1'b0, `MWr32_FMT_TYPE, 1'b0, 3'b000, 4'b0000, 1'b0, 1'b0, 2'b00, 2'b00,
                                  		    dmawtlp_sz[9:0], rqid, 8'b00000000, 4'b1111, 4'b1111 };
        		trn_trem_n_r    <= #tDLY 8'h00;
        		
        		sw <= #tDLY 1'b0;
        		
        		fifo_r_en <= #tDLY 1'b1;
			end
			
			ep_tx_s3 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_tx_state <= #tDLY ep_tx_s0;
				end
				else if (!trn_tdst_rdy_n)
				begin
					if (dma_wabt_rq)
					begin
						ep_tx_state <= #tDLY ep_tx_s12;
						
						trn_tsof_n_r     <= #tDLY 1'b1;
		        		trn_teof_n_r     <= #tDLY 1'b1;
		        		trn_tsrc_rdy_n_r <= #tDLY 1'b0;
		        		trn_tsrc_dsc_n_r <= #tDLY 1'b0;
		        		
        				fifo_r_en <= #tDLY 1'b0;
        			end
					else
					begin
						ep_tx_state <= #tDLY ep_tx_s4;
						
						trn_tsof_n_r     <= #tDLY 1'b1;
		        		trn_teof_n_r     <= #tDLY 1'b1;
		        		trn_tsrc_rdy_n_r <= #tDLY 1'b0;
		        		trn_td_r         <= #tDLY { {dmawad_l_r[31:2], 2'b00}, fifo_q_pcie_us[7:0],	 fifo_q_pcie_us[15:8],
		                              			    fifo_q_pcie_us[23:16], fifo_q_pcie_us[31:24] };
		        		trn_trem_n_r    <= #tDLY 8'h00;
		        		
		        		sw <= #tDLY 1'b1; 
		        		
		        		fifo_q_u <= #tDLY {fifo_q_pcie_us[39:32], fifo_q_pcie_us[47:40], fifo_q_pcie_us[55:48], fifo_q_pcie_us[63:56]}; 
		        		
		        		rnd_rob_inc <= #tDLY 1'b1;  
		        	end
				end
				
				psttlp_n1 <= #tDLY 1'b1; 
			end
			
			ep_tx_s4 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_tx_state <= #tDLY ep_tx_s0;
				end
				else if (dma_wabt_rq)
				begin
					ep_tx_state <= #tDLY ep_tx_s12;
						
					trn_tsof_n_r     <= #tDLY 1'b1;
	        		trn_teof_n_r     <= #tDLY 1'b1;
	        		trn_tsrc_rdy_n_r <= #tDLY 1'b0;
	        		trn_tsrc_dsc_n_r <= #tDLY 1'b0;
	        		
    				fifo_r_en <= #tDLY 1'b0;
    				
	        		sw <= #tDLY 1'b0;
				end
				else if (fifo_r_i)
				begin
					trn_tsof_n_r     <= #tDLY 1'b1;
	        		trn_teof_n_r     <= #tDLY 1'b1;
	        		trn_tsrc_rdy_n_r <= #tDLY 1'b0;
	        		trn_td_r         <= #tDLY { fifo_q_u, fifo_q_pcie_us[7:0], fifo_q_pcie_us[15:8],
	                              			    fifo_q_pcie_us[23:16], fifo_q_pcie_us[31:24] };
	        		trn_trem_n_r    <= #tDLY 8'h00;
	        		
	        		if (pst_qw_cnt == dmaw_ts_qws2)
	        		begin
	        			ep_tx_state <= #tDLY ep_tx_s5;
	        			
	        			sw <= #tDLY 1'b0;
	        			
        				fifo_r_en <= #tDLY 1'b0;
	        		end 
	        		
	        		fifo_q_u <= #tDLY {fifo_q_pcie_us[39:32], fifo_q_pcie_us[47:40], fifo_q_pcie_us[55:48], fifo_q_pcie_us[63:56]};  
				end
				
	        	rnd_rob_inc <= #tDLY 1'b0;
			end
			
			ep_tx_s5 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_tx_state <= #tDLY ep_tx_s0;
				end
				else if (!trn_tdst_rdy_n)
				begin
					ep_tx_state <= #tDLY ep_tx_s6;
					
					trn_tsof_n_r     <= #tDLY 1'b1;
	        		trn_teof_n_r     <= #tDLY 1'b0;
	        		trn_tsrc_rdy_n_r <= #tDLY 1'b0;
	        		trn_td_r         <= #tDLY { fifo_q_u, 32'h00000000 };
	        		trn_trem_n_r    <= #tDLY 8'h0F;
				end
				
				if (tx_psttlp_cnt == dmawtlp_num)
        		begin
        			tx_psttlpcpl <= #tDLY 1'b1;
        		end
        		else
        		begin
        			tx_psttlpcpl <= #tDLY 1'b0;
        		end
			end
			
			ep_tx_s6 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_tx_state <= #tDLY ep_tx_s0;
				end
				else if (!trn_tdst_rdy_n)
				begin
					if (tx_psttlpcpl)
					begin
						ep_tx_state <= #tDLY ep_tx_s7;
						
						dmawd_r <= #tDLY 1'b1;
						
						trn_tsof_n_r     <= #tDLY 1'b1;
	        			trn_teof_n_r     <= #tDLY 1'b1;
	        			trn_tsrc_rdy_n_r <= #tDLY 1'b1;
					end
					else if (
					(rnd_rob_cnt == 2'b01) 
					&& cfg_bus_master_en_r 
					&& npst_tb_av  //buffer avaliable;
					&& dma_rs 
					&& (!tx_npsttlp_cpl_lev) 
					&& (!dma_rabt_rq)
					)
					begin
						ep_tx_state <= #tDLY ep_tx_s8;
						
						trn_tsof_n_r     <= #tDLY 1'b1;
	        			trn_teof_n_r     <= #tDLY 1'b1;
	        			trn_tsrc_rdy_n_r <= #tDLY 1'b1;
					end
					else if ((rnd_rob_cnt == 2'b10) && cpl_tb_av && b0_cpld_rq)
					begin
						ep_tx_state <= #tDLY ep_tx_sc;
						
						trn_tsof_n_r     <= #tDLY 1'b1;
	        			trn_teof_n_r     <= #tDLY 1'b1;
	        			trn_tsrc_rdy_n_r <= #tDLY 1'b1;
					end
					else if ((rnd_rob_cnt == 2'b11) && cpl_tb_av && b1_cpld_rq)
					begin
						ep_tx_state <= #tDLY ep_tx_sf;
						
						trn_tsof_n_r     <= #tDLY 1'b1;
	        			trn_teof_n_r     <= #tDLY 1'b1;
	        			trn_tsrc_rdy_n_r <= #tDLY 1'b1;
					end
					else
					begin
						if (cfg_bus_master_en_r && pst_tb_av && dma_ws && (!fifo_empty_pcie_us) && (!dma_wabt_rq))	// Back-to-Back Transactions on Transmit Transaction Interface is Supported
						begin
							ep_tx_state <= #tDLY ep_tx_s3;
							
							trn_tsof_n_r     <= #tDLY 1'b0;
			        		trn_teof_n_r     <= #tDLY 1'b1;
			        		trn_tsrc_rdy_n_r <= #tDLY 1'b0;
			        		trn_td_r         <= #tDLY { 1'b0, `MWr32_FMT_TYPE, 1'b0, 3'b000, 4'b0000, 1'b0, 1'b0, 2'b00, 2'b00,
			                                  		    dmawtlp_sz[9:0], rqid, 8'b00000000, 4'b1111, 4'b1111 };
			        		trn_trem_n_r    <= #tDLY 8'h00;
			        		
			        		sw <= #tDLY 1'b0; 
			        		
			        		fifo_r_en <= #tDLY 1'b1;
						end
						else
						begin
							ep_tx_state <= #tDLY ep_tx_s1;
							
							trn_tsof_n_r     <= #tDLY 1'b1;
	        				trn_teof_n_r     <= #tDLY 1'b1;
	        				trn_tsrc_rdy_n_r <= #tDLY 1'b1;
						end
					end
					
					tx_psttlpcpl <= #tDLY 1'b0;
				end
			end
			
			ep_tx_s7 :
			begin
				ep_tx_state <= #tDLY ep_tx_s1;
				
				trn_tsof_n_r     <= #tDLY 1'b1;
			    trn_teof_n_r     <= #tDLY 1'b1;
			    trn_tsrc_rdy_n_r <= #tDLY 1'b1;
				
				dmawd_r <= #tDLY 1'b0;
				
				psttlp_n1 <= #tDLY 1'b0;
			end
			
			ep_tx_s8 :
			begin
				ep_tx_state <= #tDLY ep_tx_s9;
				
				trn_tsof_n_r     <= #tDLY 1'b0;
        		trn_teof_n_r     <= #tDLY 1'b1;
        		trn_tsrc_rdy_n_r <= #tDLY 1'b0;
        		trn_td_r         <= #tDLY { 1'b0, `MRd32_FMT_TYPE, 1'b0, 3'b000, 4'b0000, 1'b0, 1'b0, {npsttlp_ord, 1'b0}, 2'b00, 		
                                  		    dmartlp_sz[9:0], rqid,	npsttlp_tg,	4'b1111, 4'b1111 };
        		trn_trem_n_r    <= #tDLY 8'h00;
        		
				npsttlp_n1 <= #tDLY 1'b1;
        		
	        	rnd_rob_inc <= #tDLY 1'b1;
			end
			
			ep_tx_s9 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_tx_state <= #tDLY ep_tx_s0;
				end
				else if (!trn_tdst_rdy_n)
				begin
					ep_tx_state <= #tDLY ep_tx_sa;
					
					trn_tsof_n_r     <= #tDLY 1'b1;
	        		trn_teof_n_r     <= #tDLY 1'b0;
	        		trn_tsrc_rdy_n_r <= #tDLY 1'b0;
	        		trn_td_r         <= #tDLY { {dmaras_l_r[31:2], 2'b00}, 32'h00000000 };
	        		trn_trem_n_r    <= #tDLY 8'h0F;  
				end
				
				if (tx_npsttlp_cnt == dmartlp_num)
        		begin
        			tx_npsttlp_cpl <= #tDLY 1'b1;
        		end
        		else
        		begin
        			tx_npsttlp_cpl <= #tDLY 1'b0;
        		end
				
				rnd_rob_inc <= #tDLY 1'b0;
			end
			
			ep_tx_sa :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_tx_state <= #tDLY ep_tx_s0;
				end
				else if (!trn_tdst_rdy_n)
				begin
					if (tx_npsttlp_cpl)
					begin
						ep_tx_state <= #tDLY ep_tx_sb;
					end
					else if ((rnd_rob_cnt == 2'b00) && cfg_bus_master_en_r && pst_tb_av && dma_ws && (!fifo_empty_pcie_us) && (!dma_wabt_rq))
					begin
						ep_tx_state <= #tDLY ep_tx_s2;
					end
					else if ((rnd_rob_cnt == 2'b10) && cpl_tb_av && b0_cpld_rq)
					begin
						ep_tx_state <= #tDLY ep_tx_sc;
					end
					else if ((rnd_rob_cnt == 2'b11) && cpl_tb_av && b1_cpld_rq)
					begin
						ep_tx_state <= #tDLY ep_tx_sf;
					end
					else
					begin
						if (cfg_bus_master_en_r && npst_tb_av && dma_rs && (!dma_rabt_rq))
						begin
							ep_tx_state <= #tDLY ep_tx_s8;
						end
						else
						begin
							ep_tx_state <= #tDLY ep_tx_s1;
						end
					end
					
					trn_tsof_n_r     <= #tDLY 1'b1;
		        	trn_teof_n_r     <= #tDLY 1'b1;
		        	trn_tsrc_rdy_n_r <= #tDLY 1'b1;
					
					tx_npsttlp_cpl <= #tDLY 1'b0;
				end
			end
			
			ep_tx_sb :
			begin
				ep_tx_state <= #tDLY ep_tx_s1;
				
				npsttlp_n1 <= #tDLY 1'b0;
			end
			
			ep_tx_sc :
			begin
				ep_tx_state <= #tDLY ep_tx_sd;
						
				trn_tsof_n_r     <= #tDLY 1'b0;
        		trn_teof_n_r     <= #tDLY 1'b1;
        		trn_tsrc_rdy_n_r <= #tDLY 1'b0;
        		trn_td_r         <= #tDLY { 1'b0, `CplD_FMT_TYPE, 1'b0, b0_r32_tc, 4'b0000,	1'b0, 1'b0, b0_r32_at, 2'b00, 
        									10'b0000000001, cplid, 3'b000, 1'b0, b0_r32_bc };
        		trn_trem_n_r    <= #tDLY 8'h00;
        		
	        	rnd_rob_inc <= #tDLY 1'b1;
			end
			
			ep_tx_sd :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_tx_state <= #tDLY ep_tx_s0;
				end
				else if (!trn_tdst_rdy_n)
				begin
					ep_tx_state <= #tDLY ep_tx_se;
					
					trn_tsof_n_r     <= #tDLY 1'b1;
	                trn_teof_n_r     <= #tDLY 1'b0;
	                trn_tsrc_rdy_n_r <= #tDLY 1'b0;
	                trn_td_r         <= #tDLY { b0_r32_rqid, b0_r32_tg, {1'b0}, b0_r32_a_l,
	                                      		b0_r32_q[7:0], b0_r32_q[15:8], b0_r32_q[23:16], b0_r32_q[31:24] };
	                trn_trem_n_r     <= #tDLY 8'h00;
	                
	                b0_cpld_ack_r <= #tDLY 1'b1;
				end
				
	        	rnd_rob_inc <= #tDLY 1'b0;
			end
			
			ep_tx_se :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_tx_state <= #tDLY ep_tx_s0;
				end
				else if (!trn_tdst_rdy_n)
				begin
					if ((rnd_rob_cnt == 2'b00) && cfg_bus_master_en_r && pst_tb_av && dma_ws && (!fifo_empty_pcie_us) && (!dma_wabt_rq))
					begin
						ep_tx_state <= #tDLY ep_tx_s2;
					end
					else if ((rnd_rob_cnt == 2'b01) && cfg_bus_master_en_r && npst_tb_av && dma_rs && (!tx_npsttlp_cpl_lev) && (!dma_rabt_rq))
					begin
						ep_tx_state <= #tDLY ep_tx_s8;
					end
					else if ((rnd_rob_cnt == 2'b11) && cpl_tb_av && b1_cpld_rq)
					begin
						ep_tx_state <= #tDLY ep_tx_sf;
					end
					else
					begin
						ep_tx_state <= #tDLY ep_tx_s1;
					end
					
					trn_tsof_n_r     <= #tDLY 1'b1;
	                trn_teof_n_r     <= #tDLY 1'b1;
	                trn_tsrc_rdy_n_r <= #tDLY 1'b1;
				end
				
				b0_cpld_ack_r <= #tDLY 1'b0;
			end
			
			ep_tx_sf :
			begin
				ep_tx_state <= #tDLY ep_tx_s10;
						
				trn_tsof_n_r     <= #tDLY 1'b0;
        		trn_teof_n_r     <= #tDLY 1'b1;
        		trn_tsrc_rdy_n_r <= #tDLY 1'b0;
        		trn_td_r         <= #tDLY { 1'b0, `CplD_FMT_TYPE, 1'b0, b1_r32_tc, 4'b0000, 1'b0, 1'b0, b1_r32_at,
                                  		    2'b00, 10'b0000000001, cplid, 3'b000, 1'b0, b1_r32_bc };                 	   
        		trn_trem_n_r    <= #tDLY 8'h00;
        		
        		rnd_rob_inc <= #tDLY 1'b1;
			end
			
			ep_tx_s10 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_tx_state <= #tDLY ep_tx_s0;
				end
				else if (!trn_tdst_rdy_n)
				begin
					ep_tx_state <= #tDLY ep_tx_s11;
					
					trn_tsof_n_r     <= #tDLY 1'b1;
	                trn_teof_n_r     <= #tDLY 1'b0;
	                trn_tsrc_rdy_n_r <= #tDLY 1'b0;
	                trn_td_r         <= #tDLY { b1_r32_rqid, b1_r32_tg, {1'b0}, b1_r32_a_l,
	                                      		b1_r32_q[7:0], b1_r32_q[15:8], b1_r32_q[23:16],	b1_r32_q[31:24] };
	                trn_trem_n_r     <= #tDLY 8'h00;
	                
	                b1_cpld_ack_r <= #tDLY 1'b1;
				end
				
				rnd_rob_inc <= #tDLY 1'b0;
			end
			
			ep_tx_s11 :	
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_tx_state <= #tDLY ep_tx_s0;
				end
				else if (!trn_tdst_rdy_n)
				begin
					if ((rnd_rob_cnt == 2'b00) && cfg_bus_master_en_r && pst_tb_av && dma_ws && (!fifo_empty_pcie_us) && (!dma_wabt_rq))
					begin
						ep_tx_state <= #tDLY ep_tx_s2;
					end
					else if ((rnd_rob_cnt == 2'b01) && cfg_bus_master_en_r && npst_tb_av && dma_rs && (!tx_npsttlp_cpl_lev) && (!dma_rabt_rq))
					begin
						ep_tx_state <= #tDLY ep_tx_s8;
					end
					else if ((rnd_rob_cnt == 2'b10) && cpl_tb_av && b0_cpld_rq)
					begin
						ep_tx_state <= #tDLY ep_tx_sc;
					end
					else
					begin
						ep_tx_state <= #tDLY ep_tx_s1;
					end
					
					trn_tsof_n_r     <= #tDLY 1'b1;
	                trn_teof_n_r     <= #tDLY 1'b1;
	                trn_tsrc_rdy_n_r <= #tDLY 1'b1;
				end
				
				b1_cpld_ack_r <= #tDLY 1'b0;
			end
			
			ep_tx_s12 :
			begin
				if (trn_lnk_up_n_r)			// Transaction link-up is deasserted when the core and link partner are attempting to establish communication, and... 
				begin						// ...when communication with the link partner is lost due to errors on the transmission channel
					ep_tx_state <= #tDLY ep_tx_s0;
				end
				else if (!trn_tdst_rdy_n)
				begin
					ep_tx_state <= #tDLY ep_tx_s13;
					
					trn_tsof_n_r     <= #tDLY 1'b1;
	        		trn_teof_n_r     <= #tDLY 1'b1;
	        		trn_tsrc_rdy_n_r <= #tDLY 1'b1;
	        		trn_tsrc_dsc_n_r <= #tDLY 1'b1;
	        		
	        		dmawa_ack_r <= #tDLY 1'b1;
				end
				
				sw <= #tDLY 1'b0; 
        		fifo_r_en <= #tDLY 1'b0;
        		
				psttlp_n1 <= #tDLY 1'b0;
				tx_psttlpcpl <= #tDLY 1'b0;
        		dmawd_r <= #tDLY 1'b0;
			end
			
			ep_tx_s13 :
			begin
				ep_tx_state <= #tDLY ep_tx_s1;
				
				dmawa_ack_r <= #tDLY 1'b0;
			end
			
			default :
			begin
				ep_tx_state <= #tDLY 'bx;
		
				trn_tsof_n_r     <= #tDLY 1'bx;
		        trn_teof_n_r     <= #tDLY 1'bx;
		        trn_tsrc_rdy_n_r <= #tDLY 1'bx;
		        trn_td_r         <= #tDLY 64'hxxxxxxxxxxxxxxxx;
		        trn_trem_n_r     <= #tDLY 'bx;
		        trn_tsrc_dsc_n_r <= #tDLY 1'bx;
				
				sw <= #tDLY 1'bx; 
        		fifo_r_en <= #tDLY 1'bx;
        		
        		rnd_rob_inc <= #tDLY 1'bx;
        		
        		fifo_q_u <= #tDLY 32'hxxxxxxxx;
        		
        		psttlp_n1 <= #tDLY 1'bx;
        		tx_psttlpcpl <= #tDLY 1'bx;
        		dmawd_r <= #tDLY 1'bx;
        		
        		npsttlp_n1 <= #tDLY 1'bx;
				tx_npsttlp_cpl <= #tDLY 1'bx;
		        
		        b0_cpld_ack_r <= #tDLY 1'bx;
        		b1_cpld_ack_r <= #tDLY 1'bx;
        		
        		dmawa_ack_r <= #tDLY 1'bx;
        		dmara_ack_r <= #tDLY 1'bx;
			end
		endcase
	end
end


assign 	trn_tsof_n 			= trn_tsof_n_r;
assign 	trn_teof_n 			= trn_teof_n_r;
assign 	trn_tsrc_rdy_n 		= sw ? fifo_empty_pcie_us : trn_tsrc_rdy_n_r;
assign 	trn_trem_n 			= trn_trem_n_r;
assign 	trn_td 				= trn_td_r;
assign 	trn_tsrc_dsc_n 		= trn_tsrc_dsc_n_r;

assign 	b0_cpld_ack 		= b0_cpld_ack_r;
assign 	b1_cpld_ack 		= b1_cpld_ack_r;

assign 	fifo_r_i			= (!fifo_empty_pcie_us) && fifo_r_en && (!trn_tdst_rdy_n);
assign 	fifo_rdreq_pcie_us 	= fifo_r_i;



//---------------------------------------------------------------------
// rnd_rob_cnt Counter
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
        rnd_rob_cnt <= #tDLY 0;
	end
	else
	begin
		if (trn_lnk_up_n_r  || (ep_tx_state == ep_tx_s0))
		begin
			rnd_rob_cnt <= #tDLY 0;
		end
		else if (rnd_rob_inc)
		begin
			rnd_rob_cnt <= #tDLY rnd_rob_cnt + 1'b1;
		end
	end
end


//---------------------------------------------------------------------
// dmawad_l_r Accumulator
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
        dmawad_l_r <= #tDLY 0;
	end
	else
	begin
		if ((ep_tx_state == ep_tx_s2) && (!psttlp_n1))
		begin
			dmawad_l_r <= #tDLY dmawad_l;
		end
		else if ((ep_tx_state == ep_tx_s3) && (!trn_tdst_rdy_n))
		begin
	       	dmawad_l_r <= #tDLY dmawad_l_r + {19'h00000, dmawtlp_sz, 2'b00};
		end
	end
end


//---------------------------------------------------------------------
// pst_qw_cnt Counter
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
        pst_qw_cnt <= #tDLY 0;
	end
	else
	begin
		if (trn_lnk_up_n_r || (ep_tx_state == ep_tx_s5) || (ep_tx_state == ep_tx_s0) || dma_wabt_rq)
		begin
			pst_qw_cnt <= #tDLY 0;
		end
		else if ((ep_tx_state == ep_tx_s4) && fifo_r_i)
		begin
			pst_qw_cnt <= #tDLY pst_qw_cnt + 1'b1;
		end
	end
end


//---------------------------------------------------------------------
// tx_psttlp_cnt Counter
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
        tx_psttlp_cnt <= #tDLY 0;
	end
	else
	begin
		if (trn_lnk_up_n_r || (ep_tx_state == ep_tx_s7) || (ep_tx_state == ep_tx_s0) || ((ep_tx_state != ep_tx_s5) && dma_wabt_rq))
		begin
			tx_psttlp_cnt <= #tDLY 0;
		end
		else if ((ep_tx_state == ep_tx_s3) && (!trn_tdst_rdy_n))
		begin
			tx_psttlp_cnt <= #tDLY tx_psttlp_cnt + 1'b1;
		end
	end
end


//---------------------------------------------------------------------
// dmaras_l_r Accumulator
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
        dmaras_l_r <= #tDLY 0;
	end
	else
	begin
		if ((ep_tx_state == ep_tx_s8) && (!npsttlp_n1))
		begin
			dmaras_l_r <= #tDLY dmaras_l;
		end
		else if ((ep_tx_state == ep_tx_s9) && (!trn_tdst_rdy_n))
		begin
	       	dmaras_l_r <= #tDLY dmaras_l_r + {19'h00000, dmartlp_sz, 2'b00};
		end
	end
end


//---------------------------------------------------------------------
// tx_npsttlp_cnt Counter
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
        tx_npsttlp_cnt <= #tDLY 0;
	end
	else
	begin
		if (trn_lnk_up_n_r || (ep_tx_state == ep_tx_sb) || (ep_tx_state == ep_tx_s0) || ((ep_tx_state == ep_tx_s1) && dma_rabt_rq))
		begin
			tx_npsttlp_cnt <= #tDLY 0;
		end
		else if (ep_tx_state == ep_tx_s8)  //mem read32 packet
		begin
			tx_npsttlp_cnt <= #tDLY tx_npsttlp_cnt + 1'b1;
		end
	end
end


//---------------------------------------------------------------------
// npsttlp_tg Generate
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
        npsttlp_tg <= #tDLY 0;
	end
	else
	begin
		if (cfg_extended_tag_en_r)
		begin
			npsttlp_tg <= #tDLY tx_npsttlp_cnt[7:0];
		end
		else
		begin
			npsttlp_tg <= #tDLY {3'b000, tx_npsttlp_cnt[4:0]};
		end
	end
end


//---------------------------------------------------------------------
// tx_npsttlp_cpl_lev Generate
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
        tx_npsttlp_cpl_lev <= #tDLY 1'b0;
	end
	else
	begin
		if (trn_lnk_up_n_r || dma_rd || (ep_tx_state == ep_tx_s0)  || ((ep_tx_state == ep_tx_s1) && dma_rabt_rq))
		begin
			tx_npsttlp_cpl_lev <= #tDLY 1'b0;
		end
		else if (tx_npsttlp_cpl)
		begin
			tx_npsttlp_cpl_lev <= #tDLY 1'b1;
		end
	end
end



//---------------------------------------------------------------------
// Calculate byte count
//---------------------------------------------------------------------
always@(b0_r32_be) 
begin
	case (b0_r32_be)
		4'b1001 : b0_r32_bc = #tDLY 12'h004;
		4'b1011 : b0_r32_bc = #tDLY 12'h004;
		4'b1101 : b0_r32_bc = #tDLY 12'h004;
		4'b1111 : b0_r32_bc = #tDLY 12'h004;
		4'b0101 : b0_r32_bc = #tDLY 12'h003;
		4'b0111 : b0_r32_bc = #tDLY 12'h003;
		4'b1010 : b0_r32_bc = #tDLY 12'h003;
		4'b1110 : b0_r32_bc = #tDLY 12'h003;
		4'b0011 : b0_r32_bc = #tDLY 12'h002;
		4'b0110 : b0_r32_bc = #tDLY 12'h002;
		4'b1100 : b0_r32_bc = #tDLY 12'h002;
		4'b0001 : b0_r32_bc = #tDLY 12'h001;
		4'b0010 : b0_r32_bc = #tDLY 12'h001;
		4'b0100 : b0_r32_bc = #tDLY 12'h001;
		4'b1000 : b0_r32_bc = #tDLY 12'h001;
		4'b0000 : b0_r32_bc = #tDLY 12'h001;
	endcase
end

always@(b1_r32_be) 
begin
	case (b1_r32_be)
		4'b1001 : b1_r32_bc = #tDLY 12'h004;
		4'b1011 : b1_r32_bc = #tDLY 12'h004;
		4'b1101 : b1_r32_bc = #tDLY 12'h004;
		4'b1111 : b1_r32_bc = #tDLY 12'h004;
		4'b0101 : b1_r32_bc = #tDLY 12'h003;
		4'b0111 : b1_r32_bc = #tDLY 12'h003;
		4'b1010 : b1_r32_bc = #tDLY 12'h003;
		4'b1110 : b1_r32_bc = #tDLY 12'h003;
		4'b0011 : b1_r32_bc = #tDLY 12'h002;
		4'b0110 : b1_r32_bc = #tDLY 12'h002;
		4'b1100 : b1_r32_bc = #tDLY 12'h002;
		4'b0001 : b1_r32_bc = #tDLY 12'h001;
		4'b0010 : b1_r32_bc = #tDLY 12'h001;
		4'b0100 : b1_r32_bc = #tDLY 12'h001;
		4'b1000 : b1_r32_bc = #tDLY 12'h001;
		4'b0000 : b1_r32_bc = #tDLY 12'h001;
	endcase
end


//---------------------------------------------------------------------
// Calculate lower address
//---------------------------------------------------------------------
always@(b0_r32_be, b0_r32_a[6:2]) begin
	case (b0_r32_be)
		4'b0000 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b00};
		4'b0001 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b00};
		4'b0011 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b00};
		4'b0101 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b00};
		4'b0111 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b00};
		4'b1001 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b00};
		4'b1011 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b00};
		4'b1101 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b00};
		4'b1111 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b00};
		4'b0010 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b01};
		4'b0110 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b01};
		4'b1010 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b01};
		4'b1110 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b01};
		4'b0100 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b10};
		4'b1100 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b10};
		4'b1000 : b0_r32_a_l = #tDLY {b0_r32_a[6:2], 2'b11};
	endcase
end

always@(b1_r32_be, b1_r32_a[6:2]) begin
	case (b1_r32_be)
		4'b0000 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b00};
		4'b0001 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b00};
		4'b0011 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b00};
		4'b0101 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b00};
		4'b0111 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b00};
		4'b1001 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b00};
		4'b1011 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b00};
		4'b1101 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b00};
		4'b1111 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b00};
		4'b0010 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b01};
		4'b0110 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b01};
		4'b1010 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b01};
		4'b1110 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b01};
		4'b0100 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b10};
		4'b1100 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b10};
		4'b1000 : b1_r32_a_l = #tDLY {b1_r32_a[6:2], 2'b11};
	endcase
end





endmodule