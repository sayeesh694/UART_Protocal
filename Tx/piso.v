module PISO(
    input rst,            //  Active low reset.
    send,                     //  An enable to start sending data.
    baud_clk,                 //  Clocking signal from the BaudGen unit.
    parity_bit,               //  The parity bit from the Parity unit.
    input [7:0]data_in,       //  The data input.  
    output reg data_tx, 	  //  Serial transmitter's data out
	active_flag,              //  high when Tx is transmitting, low when idle.
	done_flag 	              //  high when transmission is done, low when active.
);

reg [3:0]   stop_count;
reg [10:0]  frame_r;
reg [10:0]  frame_out;
reg  next_state;
wire count_full;
parameter IDLE   = 1'b0, ACTIVE = 1'b1;

//  Frame generation
always @(posedge baud_clk, negedge rst) begin
    if (!rst)        frame_r <= {11{1'b1}};
    else if (next_state) frame_r <= frame_r;
    else                 frame_r <= {1'b1,parity_bit,data_in,1'b0};
end

// Counter logic
always @(posedge baud_clk, negedge rst) begin
    if (!rst || !next_state || count_full) stop_count <= 4'd0;
    else  stop_count <= stop_count + 4'd1;
end
assign count_full = (stop_count == 4'd11);

//  Transmission logic 
always @(posedge baud_clk, negedge rst) begin
    if (!rst) next_state   <= IDLE;
	else
	begin
		if (!next_state) begin
            if (send) next_state   <= ACTIVE;
            else      next_state   <= IDLE;
        end
        else begin
            if (count_full) next_state   <= IDLE;
            else            next_state   <= ACTIVE;
        end
	end 
end

always @(*) begin
    if (rst && next_state && (stop_count != 4'd0)) begin
        data_tx      = frame_out[0];
        frame_out    = frame_out >> 1;
        active_flag  = 1'b1;
        done_flag    = 1'b0;
    end
    else begin
        data_tx      = 1'b1;
        frame_out    = frame_r;
        active_flag  = 1'b0;
        done_flag    = 1'b1;
    end
end
endmodule  