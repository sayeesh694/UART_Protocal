// module PISO(
//     input rst,            //  Active low reset.
//     send,                     //  An enable to start sending data.
//     baud_clk,                 //  Clocking signal from the BaudGen unit.
//     parity_bit,               //  The parity bit from the Parity unit.
//     input [7:0]data_in,       //  The data input.  
//     output reg data_tx, 	  //  Serial transmitter's data out
// 	active_flag,              //  high when Tx is transmitting, low when idle.
// 	done_flag 	              //  high when transmission is done, low when active.
// );

// reg [3:0]   stop_count;
// reg [10:0]  frame_r;
// reg [10:0]  frame_out;
// reg  next_state;
// wire count_full;
// parameter IDLE   = 1'b0, ACTIVE = 1'b1;

// //  Frame generation
// always @(posedge baud_clk, negedge rst) begin
//     if (!rst)        frame_r <= {11{1'b1}};
//     else if (next_state) frame_r <= frame_r;
//     else                 frame_r <= {1'b1,parity_bit,data_in,1'b0};
// end

// // Counter logic
// always @(posedge baud_clk, negedge rst) begin
//     if (!rst || !next_state || count_full) stop_count <= 4'd0;
//     else  stop_count <= stop_count + 4'd1;
// end
// assign count_full = (stop_count == 4'd11);

// //  Transmission logic 
// always @(posedge baud_clk, negedge rst) begin
//     if (!rst) next_state   <= IDLE;
// 	else
// 	begin
// 		if (!next_state) begin
//             if (send) next_state   <= ACTIVE;
//             else      next_state   <= IDLE;
//         end
//         else begin
//             if (count_full) next_state   <= IDLE;
//             else            next_state   <= ACTIVE;
//         end
// 	end 
// end

// always @(*) begin
//     if (rst && next_state && (stop_count != 4'd0)) begin
//         data_tx      = frame_out[0];
//         frame_out    = frame_out >> 1;
//         active_flag  = 1'b1;
//         done_flag    = 1'b0;
//     end
//     else begin
//         data_tx      = 1'b1;
//         frame_out    = frame_r;
//         active_flag  = 1'b0;
//         done_flag    = 1'b1;
//     end
// end
// endmodule  


module PISO (
    input  wire       reset_n,      // Active-low reset
    input  wire       send,         // Start transmission
    input  wire       baud_clk,     // Baud rate clock
    input  wire       parity_bit,   // Parity bit
    input  wire [7:0] data_in,      // Data byte

    output reg        data_tx,      // Serial TX output
    output reg        active_flag,  // High during transmission
    output reg        done_flag     // High when idle
);

// internal
reg [3:0]  bit_cnt;
reg [10:0] frame;        // 11-bit UART frame
reg        state;

// State encoding
localparam IDLE   = 1'b0;
localparam ACTIVE = 1'b1;

// UART FRAME (LSB FIRST)
// frame[0] = start bit (0)
// frame[8:1] = data bits (LSB first)
// frame[9] = parity
// frame[10] = stop bit (1)

always @(posedge baud_clk or negedge reset_n) begin
    if (!reset_n) begin
        state   <= IDLE;
        bit_cnt <= 4'd0;
        frame   <= 11'h7FF;
    end
    else begin
        case (state)

        //-----------------------
        //      IDLE STATE
        //-----------------------
        IDLE: begin
            data_tx     <= 1'b1;       // line idle = 1
            active_flag <= 1'b0;
            done_flag   <= 1'b1;
            bit_cnt     <= 4'd0;

            if (send) begin
                // Create UART frame (LSB first)
                frame <= {1'b1,         // stop bit
                          parity_bit,    // parity
                          data_in,       // data[7:0]
                          1'b0};         // start bit
                state <= ACTIVE;
            end
        end

        //-----------------------
        //    ACTIVE STATE
        //-----------------------
        ACTIVE: begin
            active_flag <= 1'b1;
            done_flag   <= 1'b0;

            data_tx <= frame[0];      // output LSB
            frame   <= frame >> 1;    // shift right, next bit moves to LSB

            bit_cnt <= bit_cnt + 1;

            if (bit_cnt == 4'd10)     // total bits = 11 (0..10)
                state <= IDLE;
        end

        endcase
    end
end

endmodule
