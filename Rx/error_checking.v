module ErrorCheck(
    input rst,               //  Active low reset.
    recieved_flag,           //  enable from the sipo unit for the flags.
    parity_bit,              //  The parity bit from the frame for comparison.
    start_bit,               //  The Start bit from the frame for comparison.
    stop_bit,                //  The Stop bit from the frame for comparison.
    input [1:0]parity_type,  //  Parity type agreed upon by the Tx and Rx units.
    input [7:0]raw_data,     //  The 8-bits data separated from the data frame.
    output [2:0]error_flag   //  {stop_flag,start_flag,parity_flag}
);
reg error_parity,parity_flag,start_flag,stop_flag;
parameter ODD = 2'b01,EVEN = 2'b10;

//  Parity Check logic
always @(*) 
begin
  case (parity_type)
    ODD:     error_parity = (^raw_data)? 1'b0 : 1'b1;
    EVEN:    error_parity = (^raw_data)? 1'b1 : 1'b0;
    default: error_parity = 1'b1;
  endcase
end

// Error Check logic
always @(*) begin
  parity_flag  = (error_parity ^ parity_bit);
  start_flag   = (start_bit || 1'b0);
  stop_flag    = ~(stop_bit && 1'b1);
end
assign error_flag = (rst && recieved_flag)? {stop_flag,start_flag,parity_flag} : 3'b0;
endmodule