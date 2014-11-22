///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename: dma_reg_file.v
//  /   /        Date Last Modified: June. 15th, 2009 
// /___/   /\    Date Created: Apr. 1st, 2009
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT/FXT/TXT
// Purpose: This module is the DMA Control and Status register file.
//           
// Reference: 
// Revision History:
//   Rev 1.0 - First created, Apr. 1st 2009.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps



module dma_reg_file 
	# (
		parameter	tDLY		= 0									// Simulation delay
	)
	
	(
		// Common TRN Interface
		input					trn_clk,							// Transaction Clock, Rising Edge
		input					trn_reset_n,						// Transaction Reset, Active low
		input					trn_lnk_up_n,						// Transaction Link Up, Active low
		input					sys_reset_n,						// System Reset#
		
		// PCI Express Configuration
		input		[3:0]		cfg_link_speed,						// Negotiated Link speed
		input		[5:0]		cfg_link_width,						// Negotiated Link width
		input					cfg_common_clock,					// same physical reference clock
		input					cfg_io_space_en,					// IO Address Space Decoder Enable
		input					cfg_mem_space_en,					// Memory Address Space Decoder Enable
		input					cfg_bus_master_en,					// Memory Address Space Decoder Enable 
		input					cfg_intr_dis,						// PCI ExpressINTx interrupt messages disable
		input		[2:0]		cfg_pcie_link_state_n,				// PCIe Link State
		input					cfg_interrupt_msienable,			// Message Signaling Interrupt enabled.
		input		[2:0]		cfg_interrupt_mmenable,				// Multiple Message Enable field.
		input		[2:0]		cfg_max_payload_size,				// Max Payload Size 
		input		[2:0]		cfg_max_read_req_size,				// Max Read Request Size
		input					cfg_relaxed_ordering_en,			// Enable Relaxed Ordering
		input					cfg_extended_tag_en,				// Extended Tag Field Enable
		input		[1:0]		cfg_aspm_ctrl,						// Active State Power Management (ASPM) Control
		
		// BAR0 Info
		input					b0_w32_w,							//	
		input		[3:0]		b0_w32_be,							//
		input		[31:0]		b0_w32_a,							//
		input		[31:0]		b0_w32_d,							//
		input					b0_r32_r,							//
		input		[3:0]		b0_r32_be,							//
		input		[31:0]		b0_r32_a,							//
		output		[31:0]		b0_r32_q,							//
		
		// Status
		input					sim_error,							// Simulator Error Indicator
		input					fifo_prog_full_pcie_ds,				// program full
		
		// Software Reset Register
		output					sw_reset_n,							// Software Reset#
		
		// User Register
		output					record_en,							// Record Enable
		output					play_en,							// Play Enable
		output					sim_en,								// simulator Enable
		
		// DMA Control and Status Register
		output		[31:0]		dmawas,								//
		output		[31:0]		dmawad_l,							//
		output		[31:0]		dmawad_u,							//
		output		[31:0]		dmaras_l,							//
		output		[31:0]		dmaras_u,							//
		output		[31:0]		dmarad,								//
		output		[31:0]		dmawxs,								//
		output		[31:0]		dmarxs,								//
		output		[31:0]		lpci_intm,							//
		output		[31:0]		lpci_ints,							//
		output					dma_wabt_rq,						//
		input					dma_wabt_ack,						//
		output					dma_rabt_rq,						//
		input					dma_rabt_ack_0,						//
		input					dma_rabt_ack_1,						//
		output					dma_ws,								//
		output					dma_rs,								//
		input					dma_wd,								//
		input					dma_rd,								//
		input     [9:0]   fifo_dcnt_pcie_us
);



//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
reg		[1:0]		dra_state;

reg					trn_lnk_up_n_r;

reg					dma_wabt_r;
reg					dma_rabt_r;
reg					dma_wabt_rq_r;
reg					dma_rabt_rq_r;
reg					dma_rabt_ack;

reg					dma_wd_rq;
reg					dma_wd_ack;
reg					dma_rd_rq;
reg					dma_rd_ack;

reg		[3:0]		cfg_link_speed_r;
reg		[5:0]		cfg_link_width_r;
reg					cfg_common_clock_r;
reg					cfg_io_space_en_r;
reg					cfg_mem_space_en_r;
reg					cfg_bus_master_en_r;
reg					cfg_intr_dis_r;
reg		[2:0]		cfg_pcie_link_state_n_r;
reg					cfg_interrupt_msienable_r;
reg		[2:0]		cfg_interrupt_mmenable_r;
reg		[2:0]		cfg_max_payload_size_r; 
reg		[2:0]		cfg_max_read_req_size_r;
reg					cfg_relaxed_ordering_en_r;
reg					cfg_extended_tag_en_r;
reg		[1:0]		cfg_aspm_ctrl_r;

reg		[31:0]		dmawas_r;
reg		[31:0]		dmawad_l_r;
reg		[31:0]		dmawad_u_r;
reg		[31:0]		dmaras_l_r;
reg		[31:0]		dmaras_u_r;
reg		[31:0]		dmarad_r;
reg		[31:0]		dmawxs_r;
reg		[31:0]		dmarxs_r;
reg		[31:0]		lpciintm_r;
reg		[31:0]		lpciints_r;
reg		[31:0]		dmacst_r;
reg		[31:0]		srst_r;
reg		[31:0]		dmawrp_r;
reg		[31:0]		dmardp_r;
reg		[31:0]		ust_r;
reg		[31:0]		epc_r;
reg		[31:0]		fifo_dcnt_pcie_us_r;


reg					sim_error_r;
reg					fifo_prog_full_pcie_ds_r;

reg		[31:0]		b0_r32_q_r;

reg					dma_wact;
reg					dma_ract;




//---------------------------------------------------------------------
// wires
//---------------------------------------------------------------------



//---------------------------------------------------------------------
// DRA_STATE state variable assignments (sequential coded) 
//---------------------------------------------------------------------
localparam 	dra_s0	= 2'b00;
localparam 	dra_s1 	= 2'b01;
localparam 	dra_s2 	= 2'b10;
localparam 	dra_s3 	= 2'b11;








//////////////////////////////////////////////////////////////////////////////
//Start of Register File Code
//////////////////////////////////////////////////////////////////////////////

assign	dmawas = dmawas_r;
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dmawas_r <= #tDLY 0;
	end
	else
	begin
		if (b0_w32_w && (b0_w32_a[7:2] == 6'b000000))
		begin
			if (b0_w32_be[0])
			begin
				dmawas_r[7:0] <= #tDLY b0_w32_d[7:0];
			end
			if (b0_w32_be[1])
			begin
				dmawas_r[15:8] <= #tDLY b0_w32_d[15:8];
			end
			if (b0_w32_be[2])
			begin
				dmawas_r[23:16] <= #tDLY b0_w32_d[23:16];
			end
			if (b0_w32_be[3])
			begin
				dmawas_r[31:24] <= #tDLY b0_w32_d[31:24];
			end
		end
	end
end


assign 	dmawad_l = dmawad_l_r;
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dmawad_l_r <= #tDLY 0;
	end
	else
	begin
		if (b0_w32_w && (b0_w32_a[7:2] == 6'b000001))
		begin
			if (b0_w32_be[0])
			begin
				dmawad_l_r[7:0] <= #tDLY b0_w32_d[7:0];
			end
			if (b0_w32_be[1])
			begin
				dmawad_l_r[15:8] <= #tDLY b0_w32_d[15:8];
			end
			if (b0_w32_be[2])
			begin
				dmawad_l_r[23:16] <= #tDLY b0_w32_d[23:16];
			end
			if (b0_w32_be[3])
			begin
				dmawad_l_r[31:24] <= #tDLY b0_w32_d[31:24];
			end
		end
	end
end


assign 	dmawad_u = dmawad_u_r;
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dmawad_u_r <= #tDLY 0;
	end
	else
	begin
		if (b0_w32_w && (b0_w32_a[7:2] == 6'b000010))
		begin
			if (b0_w32_be[0])
			begin
				dmawad_u_r[7:0] <= #tDLY b0_w32_d[7:0];
			end
			if (b0_w32_be[1])
			begin
				dmawad_u_r[15:8] <= #tDLY b0_w32_d[15:8];
			end
			if (b0_w32_be[2])
			begin
				dmawad_u_r[23:16] <= #tDLY b0_w32_d[23:16];
			end
			if (b0_w32_be[3])
			begin
				dmawad_u_r[31:24] <= #tDLY b0_w32_d[31:24];
			end
		end
	end
end


assign 	dmaras_l = dmaras_l_r;
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dmaras_l_r <= #tDLY 0;
	end
	else
	begin
		if (b0_w32_w && (b0_w32_a[7:2] == 6'b000011))
		begin
			if (b0_w32_be[0])
			begin
				dmaras_l_r[7:0] <= #tDLY b0_w32_d[7:0];
			end
			if (b0_w32_be[1])
			begin
				dmaras_l_r[15:8] <= #tDLY b0_w32_d[15:8];
			end
			if (b0_w32_be[2])
			begin
				dmaras_l_r[23:16] <= #tDLY b0_w32_d[23:16];
			end
			if (b0_w32_be[3])
			begin
				dmaras_l_r[31:24] <= #tDLY b0_w32_d[31:24];
			end
		end
	end
end


assign 	dmaras_u = dmaras_u_r;
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dmaras_u_r <= #tDLY 0;
	end
	else
	begin
		if (b0_w32_w && (b0_w32_a[7:2] == 6'b000100))
		begin
			if (b0_w32_be[0])
			begin
				dmaras_u_r[7:0] <= #tDLY b0_w32_d[7:0];
			end
			if (b0_w32_be[1])
			begin
				dmaras_u_r[15:8] <= #tDLY b0_w32_d[15:8];
			end
			if (b0_w32_be[2])
			begin
				dmaras_u_r[23:16] <= #tDLY b0_w32_d[23:16];
			end
			if (b0_w32_be[3])
			begin
				dmaras_u_r[31:24] <= #tDLY b0_w32_d[31:24];
			end
		end
	end
end


assign 	dmarad = dmarad_r;
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dmarad_r <= #tDLY 0;
	end
	else
	begin
		if (b0_w32_w && (b0_w32_a[7:2] == 6'b000101))
		begin
			if (b0_w32_be[0])
			begin
				dmarad_r[7:0] <= #tDLY b0_w32_d[7:0];
			end
			if (b0_w32_be[1])
			begin
				dmarad_r[15:8] <= #tDLY b0_w32_d[15:8];
			end
			if (b0_w32_be[2])
			begin
				dmarad_r[23:16] <= #tDLY b0_w32_d[23:16];
			end
			if (b0_w32_be[3])
			begin
				dmarad_r[31:24] <= #tDLY b0_w32_d[31:24];
			end
		end
	end
end


assign 	dmawxs = dmawxs_r;
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dmawxs_r <= #tDLY 0;
	end
	else
	begin
		if (b0_w32_w && (b0_w32_a[7:2] == 6'b000110))
		begin
			if (b0_w32_be[0])
			begin
				dmawxs_r[7:0] <= #tDLY b0_w32_d[7:0];
			end
			if (b0_w32_be[1])
			begin
				dmawxs_r[15:8] <= #tDLY b0_w32_d[15:8];
			end
			if (b0_w32_be[2])
			begin
				dmawxs_r[23:16] <= #tDLY b0_w32_d[23:16];
			end
			if (b0_w32_be[3])
			begin
				dmawxs_r[31:24] <= #tDLY b0_w32_d[31:24];
			end
		end
	end
end


assign 	dmarxs = dmarxs_r;
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dmarxs_r <= #tDLY 0;
	end
	else
	begin
		if (b0_w32_w && (b0_w32_a[7:2] == 6'b000111))
		begin
			if (b0_w32_be[0])
			begin
				dmarxs_r[7:0] <= #tDLY b0_w32_d[7:0];
			end
			if (b0_w32_be[1])
			begin
				dmarxs_r[15:8] <= #tDLY b0_w32_d[15:8];
			end
			if (b0_w32_be[2])
			begin
				dmarxs_r[23:16] <= #tDLY b0_w32_d[23:16];
			end
			if (b0_w32_be[3])
			begin
				dmarxs_r[31:24] <= #tDLY b0_w32_d[31:24];
			end
		end
	end
end


assign 	lpci_intm = lpciintm_r;
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		lpciintm_r <= #tDLY 32'hFFFFFFFF;
	end
	else
	begin
		if (b0_w32_w && (b0_w32_a[7:2] == 6'b001000))
		begin
			if (b0_w32_be[0])
			begin
				lpciintm_r[7:0] <= #tDLY b0_w32_d[7:0];
			end
			if (b0_w32_be[1])
			begin
				lpciintm_r[15:8] <= #tDLY b0_w32_d[15:8];
			end
			if (b0_w32_be[2])
			begin
				lpciintm_r[23:16] <= #tDLY b0_w32_d[23:16];
			end
			if (b0_w32_be[3])
			begin
				lpciintm_r[31:24] <= #tDLY b0_w32_d[31:24];
			end
		end
	end
end


assign 	lpci_ints = lpciints_r;
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dma_wd_rq <= #tDLY 1'b0;
	end
	else
	begin
		if (dma_wd && (!cfg_intr_dis_r) && (!cfg_interrupt_msienable_r))
		begin
			dma_wd_rq <= #tDLY 1'b1;
		end
		else if (dma_wd_ack) 
		begin
			dma_wd_rq <= #tDLY 1'b0;
		end
	end
end

always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dma_rd_rq <= #tDLY 1'b0;
	end
	else
	begin
		if (dma_rd && (!cfg_intr_dis_r) && (!cfg_interrupt_msienable_r))
		begin
			dma_rd_rq <= #tDLY 1'b1;
		end
		else if (dma_rd_ack)
		begin
			dma_rd_rq <= #tDLY 1'b0;
		end
	end
end


always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		lpciints_r <= #tDLY 0;
	end
	else
	begin
		if (b0_w32_w && (b0_w32_a[7:2] == 6'b001001))
		begin
			if (b0_w32_be[0])
			begin
				lpciints_r[7:0] <= #tDLY (~b0_w32_d[7:0]) & lpciints_r[7:0];
			end
			if (b0_w32_be[1])
			begin
				lpciints_r[15:8] <= #tDLY (~b0_w32_d[15:8]) & lpciints_r[15:8];
			end
			if (b0_w32_be[2])
			begin
				lpciints_r[23:16] <= #tDLY (~b0_w32_d[23:16]) & lpciints_r[23:16];
			end
			if (b0_w32_be[3])
			begin
				lpciints_r[31:24] <= #tDLY (~b0_w32_d[31:24]) & lpciints_r[31:24];
			end
		end
		else
		begin
			if (dma_wd_rq)
			begin
				lpciints_r[0] <= #tDLY 1'b1;
				
				dma_wd_ack <= #tDLY 1'b1; 
			end
			else
			begin
				dma_wd_ack <= #tDLY 1'b0;
			end
			
			if (dma_rd_rq)
			begin
				lpciints_r[1] <= #tDLY 1'b1;
				
				dma_rd_ack <= #tDLY 1'b1; 
			end
			else
			begin
				dma_rd_ack <= #tDLY 1'b0;
			end
		end
	end
end


assign 	dma_ws = dmacst_r[0];
assign 	dma_rs = dmacst_r[2];
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dmacst_r <= #tDLY 0;
	end
	else
	begin
		if (dma_wd || dma_wabt_rq_r) 
		begin
			dmacst_r[0] <= #tDLY 1'b0;
		end
		else if (b0_w32_w && (b0_w32_a[7:2] == 6'b001010) && b0_w32_d[0])
		begin
			dmacst_r[0] <= #tDLY 1'b1;
		end
		
		if (dma_wd) 
		begin
			dmacst_r[1] <= #tDLY 1'b1;
		end
		else if (b0_w32_w && (b0_w32_a[7:2] == 6'b001010) && b0_w32_d[1])
		begin
			dmacst_r[1] <= #tDLY 1'b0;
		end
		
		if (dma_rd || dma_rabt_rq_r) 
		begin
			dmacst_r[2] <= #tDLY 1'b0;
		end
		else if (b0_w32_w && (b0_w32_a[7:2] == 6'b001010) && b0_w32_d[2])
		begin
			dmacst_r[2] <= #tDLY 1'b1;
		end
		
		if (dma_rd) 
		begin
			dmacst_r[3] <= #tDLY 1'b1;
		end
		else if (b0_w32_w && (b0_w32_a[7:2] == 6'b001010) && b0_w32_d[3])
		begin
			dmacst_r[3] <= #tDLY 1'b0;
		end
		
		if (dma_wabt_ack) 
		begin
			dmacst_r[4] <= #tDLY 1'b0;
		end
		else if (b0_w32_w && (b0_w32_a[7:2] == 6'b001010) && b0_w32_d[4])
		begin
			dmacst_r[4] <= #tDLY 1'b1;
		end
		
		if (dma_rabt_ack) 
		begin
			dmacst_r[5] <= #tDLY 1'b0;
		end
		else if (b0_w32_w && (b0_w32_a[7:2] == 6'b001010) && b0_w32_d[5])
		begin
			dmacst_r[5] <= #tDLY 1'b1;
		end
	end
end

assign	dma_wabt_rq = dma_wabt_rq_r;
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dma_wabt_r <= #tDLY 1'b0;
		
		dma_wabt_rq_r <= #tDLY 1'b0;
	end
	else
	begin
		dma_wabt_r <= #tDLY dmacst_r[4];
		
		if ((!dma_wabt_r) && dmacst_r[4])
		begin
			dma_wabt_rq_r <= #tDLY 1'b1;
		end
		else if (dma_wabt_ack)
		begin
			dma_wabt_rq_r <= #tDLY 1'b0;
		end
	end
end

assign	dma_rabt_rq = dma_rabt_rq_r;
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dma_rabt_r <= #tDLY 1'b0;
	end
	else
	begin
		dma_rabt_r <= #tDLY dmacst_r[5];
	end
end

always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dra_state <= #tDLY dra_s0;
		
		dma_rabt_rq_r <= #tDLY 1'b0;
		
		dma_rabt_ack <= #tDLY 1'b0; 
	end
	else
	begin
		case (dra_state)
			dra_s0 :
			begin
				if ((!dma_rabt_r) && dmacst_r[5])
				begin
					dra_state <= #tDLY dra_s1;
					
					dma_rabt_rq_r <= #tDLY 1'b1;
				end
				
				dma_rabt_ack <= #tDLY 1'b0;
			end
			
			dra_s1 :
			begin
				if (dma_rabt_ack_0 && dma_rabt_ack_1)
				begin
					dra_state <= #tDLY dra_s0;
					
					dma_rabt_rq_r <= #tDLY 1'b0;
					
					dma_rabt_ack <= #tDLY 1'b1;
				end
				else if (dma_rabt_ack_0)
				begin
					dra_state <= #tDLY dra_s2;
				end
				else if (dma_rabt_ack_1)
				begin
					dra_state <= #tDLY dra_s3;
				end
			end
			
			dra_s2 :
			begin
				if (dma_rabt_ack_1)
				begin
					dra_state <= #tDLY dra_s0;
					
					dma_rabt_rq_r <= #tDLY 1'b0;
					
					dma_rabt_ack <= #tDLY 1'b1;
				end
			end
			
			dra_s3 :
			begin
				if (dma_rabt_ack_0)
				begin
					dra_state <= #tDLY dra_s0;
					
					dma_rabt_rq_r <= #tDLY 1'b0;
					
					dma_rabt_ack <= #tDLY 1'b1;
				end
			end
			
			default :
			begin
				dra_state <= #tDLY 'bx;
		
				dma_rabt_rq_r <= #tDLY 1'bx;
				
				dma_rabt_ack <= #tDLY 1'bx;
			end
		endcase
	end
end


assign 	sw_reset_n = !srst_r[0];
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		srst_r <= #tDLY 0;
	end
	else
	begin
		if (b0_w32_w && (b0_w32_a[7:2] == 6'b001011))
		begin
			if (b0_w32_be[0])
			begin
				srst_r[0] <= #tDLY b0_w32_d[0];
			end
		end
	end
end


always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dma_wact <= #tDLY 1'b0;
	end
	else
	begin 
		if (dmacst_r[0])
		begin
			dma_wact <= #tDLY 1'b1;
		end
		else if (dmacst_r[1])
		begin
			dma_wact <= #tDLY 1'b0;
		end
	end
end

always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dmawrp_r <= #tDLY 0;
	end
	else
	begin
		if (dma_wact)
		begin
			dmawrp_r <= #tDLY dmawrp_r + 1'b1;
		end
	end
end


always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dma_ract <= #tDLY 1'b0;
	end
	else
	begin
		if (dmacst_r[2])
		begin
			dma_ract <= #tDLY 1'b1;
		end
		else if (dmacst_r[3])
		begin
			dma_ract <= #tDLY 1'b0;
		end
	end
end

always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		dmardp_r <= #tDLY 0;
	end
	else
	begin
		if (dma_ract)
		begin
			dmardp_r <= #tDLY dmardp_r + 1'b1;
		end
	end
end


assign 	record_en 	= ust_r[0];
assign 	play_en 	= ust_r[1];
assign 	sim_en 		= ust_r[2];	
always@(posedge trn_clk, negedge sys_reset_n) 
begin
	if (!sys_reset_n)
	begin
		ust_r[15:0] <= #tDLY 0;
	end
	else
	begin
		if (b0_w32_w && (b0_w32_a[7:2] == 6'b001110))
		begin
			if (b0_w32_be[0])
			begin
				ust_r[7:0] <= #tDLY b0_w32_d[7:0];
			end
		end
	end
end


always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		trn_lnk_up_n_r <= #tDLY 1'b1;
		
		sim_error_r <= #tDLY 1'b0;
		
		fifo_prog_full_pcie_ds_r <= #tDLY 1'b0;
		
		ust_r[31:16] <= #tDLY 0;
	end
	else
	begin
		trn_lnk_up_n_r <= #tDLY trn_lnk_up_n;
		
		sim_error_r <= #tDLY sim_error;
		
		fifo_prog_full_pcie_ds_r <= #tDLY fifo_prog_full_pcie_ds;
		
		ust_r[16] <= #tDLY !trn_lnk_up_n_r;
		ust_r[19] <= #tDLY sim_error_r;
		ust_r[23] <= #tDLY !fifo_prog_full_pcie_ds_r;
	end
end


										
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		cfg_link_speed_r <= #tDLY 0;
		
		cfg_link_width_r <= #tDLY 0;
		
		cfg_common_clock_r <= #tDLY 1'b0;
		
		cfg_io_space_en_r <= #tDLY 1'b0;
		
		cfg_mem_space_en_r <= #tDLY 1'b0;
		
		cfg_bus_master_en_r <= #tDLY 1'b0;
		
		cfg_intr_dis_r <= #tDLY 1'b0; 
		
		cfg_pcie_link_state_n_r <= #tDLY 0;
		
		cfg_interrupt_msienable_r <= #tDLY 0;

		cfg_interrupt_mmenable_r <= #tDLY 0;
		
		cfg_max_payload_size_r <= #tDLY 0; 
		
		cfg_max_read_req_size_r <= #tDLY 0;
		
		cfg_relaxed_ordering_en_r <= #tDLY 1'b0;
		
		cfg_extended_tag_en_r <= #tDLY 1'b0;
		
		cfg_aspm_ctrl_r <= #tDLY 0;
		
		
		epc_r <= #tDLY 0;
	end
	else
	begin
		cfg_link_speed_r <= #tDLY cfg_link_speed;
		
		cfg_link_width_r <= #tDLY cfg_link_width;
		
		cfg_common_clock_r <= #tDLY cfg_common_clock;
		
		cfg_io_space_en_r <= #tDLY cfg_io_space_en;
		 
		cfg_mem_space_en_r <= #tDLY cfg_mem_space_en;
		
		cfg_bus_master_en_r <= #tDLY cfg_bus_master_en;
		
		cfg_intr_dis_r <= #tDLY cfg_intr_dis; 
		
		cfg_pcie_link_state_n_r <= #tDLY cfg_pcie_link_state_n;
		
		cfg_interrupt_msienable_r <= #tDLY cfg_interrupt_msienable;

		cfg_interrupt_mmenable_r <= #tDLY cfg_interrupt_mmenable;
		
		cfg_max_payload_size_r <= #tDLY cfg_max_payload_size; 
		
		cfg_max_read_req_size_r <= #tDLY cfg_max_read_req_size;
		
		cfg_relaxed_ordering_en_r <= #tDLY cfg_relaxed_ordering_en;
		
		cfg_extended_tag_en_r <= #tDLY cfg_extended_tag_en;
		
		cfg_aspm_ctrl_r <= #tDLY cfg_aspm_ctrl;
		
		
		epc_r[3:0] <= #tDLY cfg_link_speed_r;
		epc_r[9:4] <= #tDLY cfg_link_width_r;
		epc_r[10] <= #tDLY cfg_common_clock_r;
		epc_r[11] <= #tDLY cfg_io_space_en_r;
		epc_r[12] <= #tDLY cfg_mem_space_en_r;
		epc_r[13] <= #tDLY cfg_bus_master_en_r;
		epc_r[14] <= #tDLY cfg_intr_dis_r;
		epc_r[17:15] <= #tDLY cfg_pcie_link_state_n_r;
		epc_r[18] <= #tDLY cfg_interrupt_msienable_r;
		epc_r[21:19] <= #tDLY cfg_interrupt_mmenable_r;
		epc_r[24:22] <= #tDLY cfg_max_payload_size_r; 
		epc_r[27:25] <= #tDLY cfg_max_read_req_size_r;
		epc_r[28] <= #tDLY cfg_relaxed_ordering_en_r ;
		epc_r[29] <= #tDLY cfg_extended_tag_en_r;
		epc_r[31:30] <= #tDLY cfg_aspm_ctrl_r;
	end
end


always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin		
		fifo_dcnt_pcie_us_r <= #tDLY 0;
	end
	else
	begin
	   fifo_dcnt_pcie_us_r[12:3] <=  #tDLY fifo_dcnt_pcie_us;
	end
end
//////////////////////////////////////////////////////////////////////////////
//END of Register File Code
//////////////////////////////////////////////////////////////////////////////




assign 	b0_r32_q = b0_r32_q_r;
always@(posedge trn_clk, negedge sys_reset_n)
begin
	if (!sys_reset_n)
	begin
		b0_r32_q_r <= #tDLY 0; 
	end
	else
	begin
		case (b0_r32_a[7:2])
			6'b000000 :	
			begin
				b0_r32_q_r <= #tDLY dmawas_r;
			end
			
			6'b000001 :	
			begin
				b0_r32_q_r <= #tDLY dmawad_l_r;
			end
			
			6'b000010 :
			begin
				b0_r32_q_r <= #tDLY dmawad_u_r;
			end
			
			6'b000011 :	
			begin
				b0_r32_q_r <= #tDLY dmaras_l_r;
			end
			
			6'b000100 :	
			begin
				b0_r32_q_r <= #tDLY dmaras_u_r;
			end
			
			6'b000101 :	
			begin
				b0_r32_q_r <= #tDLY dmarad_r;
			end
			
			6'b000110 :	
			begin
				b0_r32_q_r <= #tDLY dmawxs_r;
			end
			
			6'b000111 :	
			begin
				b0_r32_q_r <= #tDLY dmarxs_r;
			end
			
			6'b001000 :	
			begin
				b0_r32_q_r <= #tDLY lpciintm_r;
			end
			
			6'b001001 :	
			begin
				b0_r32_q_r <= #tDLY lpciints_r;
			end
			
			6'b001010 :	
			begin
				b0_r32_q_r <= #tDLY dmacst_r;
			end
			
			6'b001011 :	
			begin
				b0_r32_q_r <= #tDLY srst_r;
			end
			
			6'b001100 :	
			begin
				b0_r32_q_r <= #tDLY dmawrp_r;
			end
			
			6'b001101 :	
			begin
				b0_r32_q_r <= #tDLY dmardp_r;
			end
			
			6'b001110 :	
			begin
				b0_r32_q_r <= #tDLY ust_r;
			end
			
			6'b001111 :	
			begin
				b0_r32_q_r <= #tDLY epc_r;
			end
			
			6'b010000 :	
			begin
				b0_r32_q_r <= #tDLY fifo_dcnt_pcie_us_r;
			end
			
			default :
			begin
				b0_r32_q_r <= #tDLY 'bx;
			end
		endcase
	end
end

			


endmodule