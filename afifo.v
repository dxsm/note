module afifo
#(parameter DATA_WIDTH = 64,
            FIFO_DEPTH = 8,
			AF_LEVEL   = (1<<FIFO_DEPTH - 10),
			AE_LEVEL   = 10
)
(	
	input 							wclk			,
	input 							wrst			,
	input 							wen				,
	input 		[DATA_WIDTH-1:0]	wdata   		,
	output reg						wfull			,
	output reg						walmost_full	,
	
	input 							rclk			,
	input 							rrst			,
	input 							ren				,
	output reg	[DATA_WIDTH-1:0]	rdata   		,
	output reg						rempty			,
	output reg  					ralmost_empty
);


wire				  fifo_rd;
wire				  fifo_wr;
wire [FIFO_DEPTH-1:0] raddr;
wire [FIFO_DEPTH-1:0] waddr;
reg  [DATA_WIDTH-1:0] memory [0:(1<<FIFO_DEPTH)-1];        

wire				wen_mask;
wire [FIFO_DEPTH:0] wbinnext;
wire [FIFO_DEPTH:0] wptrnext;
reg  [FIFO_DEPTH:0] wbin;
reg  [FIFO_DEPTH:0] wptr;
reg  [FIFO_DEPTH:0] wptr_rsync1;
reg  [FIFO_DEPTH:0] wptr_rsync2;
wire [FIFO_DEPTH:0] wbin_rsync;

wire				ren_mask;
wire [FIFO_DEPTH:0] rbinnext;
wire [FIFO_DEPTH:0] rptrnext;
reg  [FIFO_DEPTH:0] rbin;
reg  [FIFO_DEPTH:0] rptr;
reg  [FIFO_DEPTH:0] rptr_wsync1;
reg  [FIFO_DEPTH:0] rptr_wsync2;
wire [FIFO_DEPTH:0] rbin_wsync;

genvar i;

//*************************************
// Dual port RAM
//*************************************
assign fifo_wr = wen_mask;
always @(posedge wclk) begin
	if(fifo_wr) 
		memory[waddr] <= wdata;
end

assign fifo_rd = ren_mask;
always @(posedge rclk) begin
	if(fifo_rd)
		rdata <= memory[raddr];
end
//

//*************************************
// sync wptr to rclk domain
//*************************************
always @(posedge rclk or negedge rrst) begin
	if(!rrst)
		{wptr_rsync2,wptr_rsync1} <= 0;
	else
		{wptr_rsync2,wptr_rsync1} <= {wptr_rsync1,wptr};
end 

generate
	for(i=FIFO_DEPTH;i>=0;i=i-1) begin: wbin_rsync_gen
		assign wbin_rsync[i] = ^({{i{1'b0}},wptr_rsync2[FIFO_DEPTH:i]});
	end
endgenerate

//*************************************
// sync rptr to wclk domain
//*************************************
always @(posedge wclk or negedge wrst) begin
	if(!wrst)
		{rptr_wsync2,rptr_wsync1} <= 0;
    else
		{rptr_wsync2,rptr_wsync1} <= {rptr_wsync1,rptr};
end 

generate
	for(i=FIFO_DEPTH;i>=0;i=i-1) begin: rbin_wsync_gen
		assign rbin_wsync[i] = ^({{i{1'b0}},rptr_wsync2[FIFO_DEPTH:i]});
	end
endgenerate

//*************************************
// rd addr generate
//*************************************
always @(posedge rclk or negedge rrst) begin 
	if(!rrst)
		{rbin,rptr} <= 0;
    else
		{rbin,rptr} <= {rbinnext,rptrnext};
end
assign raddr = rbin[FIFO_DEPTH-1:0];
assign ren_mask = ren & (~rempty);
assign rbinnext = ren_mask ? (rbin + 1'b1) : rbin;
assign rptrnext = (rbinnext>>1) ^ rbinnext;


//*************************************
// wr addr generate
//*************************************
always @(posedge wclk or negedge wrst) begin
	if(!wrst)
		{wbin,wptr} <= 0;
    else
		{wbin,wptr} <= {wbinnext,wptrnext};
end
assign waddr = wbin[FIFO_DEPTH-1:0];
assign wen_mask = (wen & (~wfull));
assign wbinnext = wen_mask ? (wbin + 1'b1) : wbin;
assign wptrnext = (wbinnext>>1) ^ wbinnext;

//*************************************
// FIFO status
//*************************************
always @(posedge rclk or negedge rrst) begin
	if(!rrst)
		rempty <= 1'b1;
    else
		rempty <= (rptrnext == wptr_rsync2);
end

always @(posedge rclk or negedge rrst) begin
	if(!rrst)
		ralmost_empty <= 1'b1;
    else
		ralmost_empty <= (wbin_rsync - rbinnext <= AE_LEVEL);
end

always @(posedge wclk or negedge wrst) begin
	if(!wrst)
		wfull <= 0;
    else
		wfull <= (wptrnext == {~rptr_wsync2[FIFO_DEPTH:FIFO_DEPTH-1],rptr_wsync2[FIFO_DEPTH-2:0]});
end

always @(posedge wclk or negedge wrst) begin
	if(!wrst)
		walmost_full <= 1'b1;
    else
		walmost_full <= (wbinnext - rbin_wsync >= AF_LEVEL);
end

endmodule