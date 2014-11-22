///////////////////////////////////////////////////////////////////////////////
// ?2007-2008 Xilinx, Inc. All Rights Reserved.
// Confidential and proprietary information of Xilinx, Inc.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Version: 1.0
//  \   \        Filename:  intr_ctrl.v
//  /   /        Date Last Modified: June. 15th, 2009
// /___/   /\    Date Created: Apr. 1st, 2009
// \   \  /  \ 
//  \___\/\___\ 
//
// Device: Virtex-5 LXT/FXT/TXT
// Purpose: Endpoint Interrupt Controller, 32 Vectors'MSI and Legacy Interrupt is Supported
//
// Reference:
// Revision History:
//   Rev 1.0 - First created, Apr. 1 2009.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 100ps



module intr_ctrl	
	# (
		parameter	tDLY		= 0							// Simulation delay
	)
	
	(
		// Common TRN Interface
		input					trn_clk,					// Transaction Clock, Rising Edge
		input					trn_lnk_up_n,				// Transaction Link Up, Active low
		input					trn_reset_n,				// Transaction Reset, Active low
		
		// Interrupt Disable
		input					cfg_intr_dis,				// Controls the ability of a PCI Express function to generate INTx interrupt messages in bit 10 of Command Register
		
		// DMA Control and Status Register
		input		[31:0]		lpci_intm,		 			//
		input		[31:0]		lpci_ints,					//
		input					dma_wd,						//
		input					dma_rd,						//
		
		// Interrupt Requests
		input		[2:0]		cfg_interrupt_mmenable,		// Configuration Interrupt Multiple Message Enable
		input					cfg_interrupt_msienable,	// Configuration Interrupt MSI Enabled
		input		[7:0]		cfg_interrupt_do,			// Configuration Interrupt Data Out
		output					cfg_interrupt_n,			// Configuration Interrupt, Active low
		input					cfg_interrupt_rdy_n,		// Configuration Interrupt Ready
		output		[7:0]		cfg_interrupt_di,			// Configuration Interrupt Data In
		output					cfg_interrupt_assert_n		// Configuration Legacy Interrupt Assert/Deassert Select
);




//---------------------------------------------------------------------
// registers
//---------------------------------------------------------------------
reg		[2:0]		intr_state;

reg					trn_lnk_up_n_r;

reg					cfg_intr_dis_r;

reg					lpci_ints_0_r;
reg					lpci_ints_1_r;

reg		[2:0]		cfg_interrupt_mmenable_r;
reg					cfg_interrupt_msienable_r;
reg					cfg_interrupt_n_r;
reg		[7:0]		cfg_interrupt_di_r;
reg					cfg_interrupt_assert_n_r;

reg					dma_wd_int_rq;
reg					dma_wd_int_ack;
reg					dma_rd_int_rq;
reg					dma_rd_int_ack;
reg					dma_wd_int_rel_rq;
reg					dma_wd_int_rel_ack;
reg					dma_rd_int_rel_rq;
reg					dma_rd_int_rel_ack;

reg		[4:0]		msi_vec;

reg		[4:0]		lpci_vec;



//---------------------------------------------------------------------
// MSI_FSM state variable assignments (sequential coded) 
//---------------------------------------------------------------------
localparam 	intr_s0		= 3'b000;
localparam 	intr_s1 	= 3'b001;
localparam 	intr_s2 	= 3'b010;
localparam 	intr_s3 	= 3'b011;
localparam 	intr_s4 	= 3'b100;
localparam 	intr_s5 	= 3'b101;
localparam 	intr_s6 	= 3'b110;






assign 	cfg_interrupt_n 		= cfg_interrupt_n_r;
assign 	cfg_interrupt_di		= cfg_interrupt_di_r;
assign 	cfg_interrupt_assert_n	= cfg_interrupt_assert_n_r;






//---------------------------------------------------------------------
// Input Register
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		trn_lnk_up_n_r <= #tDLY 1'b1;
		
		cfg_intr_dis_r <= #tDLY 1'b1; 
		
		cfg_interrupt_mmenable_r <= #tDLY 0; 
		cfg_interrupt_msienable_r <= #tDLY 1'b0;
	end
	else
	begin
		trn_lnk_up_n_r <= #tDLY trn_lnk_up_n;
		
		cfg_intr_dis_r <= #tDLY cfg_intr_dis;
		
		cfg_interrupt_mmenable_r <= #tDLY cfg_interrupt_mmenable; 
		cfg_interrupt_msienable_r <= #tDLY cfg_interrupt_msienable;
	end
end


always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		dma_wd_int_rq <= #tDLY 1'b0;
	end
	else
	begin
		if (dma_wd && (cfg_interrupt_msienable_r || ((!cfg_intr_dis_r) && (!lpci_intm[0]) && (!lpci_intm[31]))))
		begin
			dma_wd_int_rq <= #tDLY 1'b1;
		end
		else if (dma_wd_int_ack)
		begin										
			dma_wd_int_rq <= #tDLY 1'b0;
		end
	end
end

always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		dma_rd_int_rq <= #tDLY 1'b0;
	end
	else
	begin
		if (dma_rd && (cfg_interrupt_msienable_r || ((!cfg_intr_dis_r) && (!lpci_intm[1]) && (!lpci_intm[31]))))
		begin
			dma_rd_int_rq <= #tDLY 1'b1;
		end
		else if (dma_rd_int_ack)
		begin										
			dma_rd_int_rq <= #tDLY 1'b0;
		end
	end
end


always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		dma_wd_int_rel_rq <= #tDLY 1'b0;
		
		lpci_ints_0_r <= #tDLY 1'b0;
	end
	else
	begin
		if (lpci_ints_0_r && (!lpci_ints[0]) && 
			(!cfg_interrupt_msienable_r) && (!cfg_intr_dis_r) && (!lpci_intm[0]) && (!lpci_intm[31]))
		begin
			dma_wd_int_rel_rq <= #tDLY 1'b1;
		end
		else if (dma_wd_int_rel_ack)
		begin														
			dma_wd_int_rel_rq <= #tDLY 1'b0;
		end
		
		lpci_ints_0_r <= #tDLY lpci_ints[0];
	end
end

always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		dma_rd_int_rel_rq <= #tDLY 1'b0;
		
		lpci_ints_1_r <= #tDLY 1'b0;
	end
	else
	begin
		if (lpci_ints_1_r && (!lpci_ints[1]) && 
			(!cfg_interrupt_msienable_r) && (!cfg_intr_dis_r) && (!lpci_intm[1]) && (!lpci_intm[31]))
		begin
			dma_rd_int_rel_rq <= #tDLY 1'b1;
		end
		else if (dma_rd_int_rel_ack)
		begin												
			dma_rd_int_rel_rq <= #tDLY 1'b0;
		end
		
		lpci_ints_1_r <= #tDLY lpci_ints[1];
	end
end




//---------------------------------------------------------------------
// INTR_FSM Finite State Machine(one process)
//---------------------------------------------------------------------
always@(posedge trn_clk, negedge trn_reset_n)
begin
	if (!trn_reset_n)
	begin
		intr_state <= #tDLY intr_s0;
		
		msi_vec <= #tDLY 0; 
		lpci_vec <= #tDLY 0;
		
		cfg_interrupt_n_r <= #tDLY 1'b1;
		cfg_interrupt_assert_n_r <= #tDLY 1'b1;
		cfg_interrupt_di_r <= #tDLY 0; 
				
		dma_wd_int_ack <= #tDLY 1'b0;
		dma_rd_int_ack <= #tDLY 1'b0;
		
		dma_wd_int_rel_ack <= #tDLY 1'b0;
		dma_rd_int_rel_ack <= #tDLY 1'b0;		
	end
	else
	begin
		case (intr_state)
			intr_s0 :
			begin
				if (cfg_interrupt_msienable_r)		// MSI is enabled
				begin
					if (dma_wd_int_rq)
					begin
						intr_state <= #tDLY intr_s1;
						
						msi_vec <= #tDLY 5'h00;
					end
					else if (dma_rd_int_rq)
					begin
						intr_state <= #tDLY intr_s1;
						
						msi_vec <= #tDLY 5'h01;
					end
				end
				else if (!cfg_intr_dis_r)			// Legacy Interrupt is enabled
				begin
					if (dma_wd_int_rq)
					begin
						intr_state <= #tDLY intr_s3;
						
						lpci_vec <= #tDLY 5'h00;
					end
					else if (dma_rd_int_rq)
					begin
						intr_state <= #tDLY intr_s3;
						
						lpci_vec <= #tDLY 5'h01;
					end
					else if (dma_wd_int_rel_rq)
					begin
						intr_state <= #tDLY intr_s5;
						
						lpci_vec <= #tDLY 5'h00;
					end
					else if (dma_rd_int_rel_rq)
					begin
						intr_state <= #tDLY intr_s5;
						
						lpci_vec <= #tDLY 5'h01;
					end
				end
			end
			
			intr_s1 :
			begin
				intr_state <= #tDLY intr_s2;
				
				cfg_interrupt_n_r <= #tDLY 1'b0;
				cfg_interrupt_di_r <= #tDLY {cfg_interrupt_do[7:5], msi_vec}; 
				
				case (msi_vec)
					5'h00 :
					begin
						dma_wd_int_ack <= #tDLY 1'b1;
					end
					
					5'h01 :
					begin
						dma_rd_int_ack <= #tDLY 1'b1;
					end
					
					default :
					begin
						dma_wd_int_ack <= #tDLY 1'bx;
						dma_rd_int_ack <= #tDLY 1'bx;					
					end
				 endcase
			end
			
			intr_s2 :
			begin
				if ((!cfg_interrupt_rdy_n) || trn_lnk_up_n_r)
				begin
					intr_state <= #tDLY intr_s0;
					
					cfg_interrupt_n_r <= #tDLY 1'b1;
				end
				
				dma_wd_int_ack <= #tDLY 1'b0;
				dma_rd_int_ack <= #tDLY 1'b0;
			end

			intr_s3 :
			begin
				intr_state <= #tDLY intr_s4;
				
				cfg_interrupt_n_r <= #tDLY 1'b0;
				cfg_interrupt_assert_n_r <= #tDLY 1'b0;
				cfg_interrupt_di_r <= #tDLY 8'h00;
				
				case (lpci_vec)
					5'h00 :
					begin
						dma_wd_int_ack <= #tDLY 1'b1;
					end
					
					5'h01 :
					begin
						dma_rd_int_ack <= #tDLY 1'b1;
					end
					
					default :
					begin
						dma_wd_int_ack <= #tDLY 1'bx;
						dma_rd_int_ack <= #tDLY 1'bx;
					end
				 endcase
			end
			
			intr_s4 :
			begin
				if ((!cfg_interrupt_rdy_n) || trn_lnk_up_n_r)
				begin
					intr_state <= #tDLY intr_s0;
					
					cfg_interrupt_n_r <= #tDLY 1'b1;
					cfg_interrupt_assert_n_r <= #tDLY 1'b1;
				end
				
				dma_wd_int_ack <= #tDLY 1'b0;
				dma_rd_int_ack <= #tDLY 1'b0;
			end
		
			intr_s5 :
			begin
				intr_state <= #tDLY intr_s6;
				
				cfg_interrupt_n_r <= #tDLY 1'b0;
				cfg_interrupt_assert_n_r <= #tDLY 1'b1;
				cfg_interrupt_di_r <= #tDLY 8'h00;
				
				case (lpci_vec)
					5'h00 :
					begin
						dma_wd_int_rel_ack <= #tDLY 1'b1;
					end
					
					5'h01 :
					begin
						dma_rd_int_rel_ack <= #tDLY 1'b1;
					end
					
					default :
					begin
						dma_wd_int_rel_ack <= #tDLY 1'bx;
						dma_rd_int_rel_ack <= #tDLY 1'bx;
					end
				 endcase
			end
			
			intr_s6 :
			begin
				if ((!cfg_interrupt_rdy_n) || trn_lnk_up_n_r)
				begin
					intr_state <= #tDLY intr_s0;
					
					cfg_interrupt_n_r <= #tDLY 1'b1;
				end
				
				dma_wd_int_rel_ack <= #tDLY 1'b0;
				dma_rd_int_rel_ack <= #tDLY 1'b0;
			end
			
			default :
			begin
				intr_state <= #tDLY 'bx;
						
				msi_vec <= #tDLY 'bx; 
				lpci_vec <= #tDLY 'bx;
				
				cfg_interrupt_n_r <= #tDLY 1'bx;
				cfg_interrupt_assert_n_r <= #tDLY 1'bx;
				cfg_interrupt_di_r <= #tDLY 'bx;  
						
				dma_wd_int_ack <= #tDLY 1'bx;
				dma_rd_int_ack <= #tDLY 1'bx;
				
				dma_wd_int_rel_ack <= #tDLY 1'bx;
				dma_rd_int_rel_ack <= #tDLY 1'bx;
			end
		endcase
	end
end






endmodule