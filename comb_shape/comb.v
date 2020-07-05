//------------------------------------------------------------------------
// File Name   : comb.v
// Author      : victor dong (dxs_uestc@163.com)
// Version     : V0.1 
//------------------------------------------------------------------------
// Description :
//     
//------------------------------------------------------------------------
// Revision History:
// *Version* | *Modifier* | *Modified Date* | *Description*
//   V0.1    |   Victor   |   2019-10-20    | Fisrt Created.
//------------------------------------------------------------------------

module comb(
  input                 clk               ,
  input                 rst_n             ,
  input                 chip_head_in      ,
  input                 cell0_vld_in      ,
  input       [3:0]     cell0_chnum_in    ,
  input       [15:0]    cell0_data_in     ,
  input                 cell0_10ms_timer  ,
  input                 cell1_vld_in      ,
  input       [3:0]     cell1_chnum_in    ,
  input       [15:0]    cell1_data_in     ,
  input                 cell1_10ms_timer  ,
  output wire           comb_vld_out      ,
  output wire           comb_chnum_in     ,
  output wire           comb_data_out     ,
);

//==============================================
// Definition of regs and wires
//==============================================

//**********************************************
// Function
//**********************************************
assign cell0_vld_ch[0]        = cell0_vld_in & (cell0_chnum_in==4'd0);
assign cell1_vld_ch[0]        = cell1_vld_in & (cell1_chnum_in==4'd0);
assign cell0_10ms_timer_ch[0] = cell0_vld_ch[0] & cell0_10ms_timer;
assign cell1_10ms_timer_ch[0] = cell0_vld_ch[0] & cell0_10ms_timer;

always @(posedge clk,negedge rst_n) begin
  if(rst_n == 1'b0) begin
    cstate = IDLE;
  end
  else begin
    cstate = nstate;
  end
end

always @* begin
  case(cstate)
    IDLE: begin
      if(cell0_10ms_timer_ch==1'b1 && cell1_10ms_timer_ch==1'b1) begin
        nstate = ALIGNED;
      end
      else if(cell0_10ms_timer_ch==1'b1) begin
        nstate = CELL1_WAIT;
      end
      else if(cell1_10ms_timer_ch==1'b1) begin
        nstate = CELL0_WAIT;
      end
      else begin
        nstate = cstate;
      end
    end
    CELL0_WAIT: begin
      if(cell0_10ms_timer_ch == 1'b1) begin
        nstate = ALIGNED;
      end
      else if(dly_cnt == 5'd23) begin
        nstate = IDLE;
      end
      else begin
        nstate = cstate;
      end
    end
    CELL1_WAIT: begin
      if(cell1_10ms_timer_ch == 1'b1) begin
        nstate = ALIGNED;
      end
      else if(dly_cnt == 5'd23) begin
        nstate = IDLE;
      end
      else begin
        nstate = cstate;
      end
    end
    ALIGNED: begin
      nstate = IDLE;
    end
    default: begin
      nstate = IDLE;
    end
  endcase
end

always @(posedge clk,negedge rst_n) begin
  if(rst_n == 1'b0) begin
    dly_cnt <= 5'd0;
  end
  else if(cell0_10ms_timer_ch==1'b1 || cell1_10ms_timer_ch==1'b1) begin
    dly_cnt <= 5'b0;
  end
  else if(cell0_vld_ch==1'b1 && (cstate==CELL0_WAIT || cstate==CELL1_WAIT)) begin
    dly_cnt <= dly_cnt + 5'd1;
  end
end



endmodule
