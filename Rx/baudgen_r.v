module BaudGenR(
    input rst,              //  Active low reset.
    clock,                  //  The System's main clock.
    input [1:0]baud_rate,   //  Baud Rate agreed upon by the Tx and Rx units.
    output reg baud_clk     //  Clocking output for the other modules.
);

reg [9:0]  final_value;  
reg [9:0]  clock_ticks; 
parameter BAUD24 = 2'b00, BAUD48 = 2'b01,BAUD96 = 2'b10,BAUD192 = 2'b11;

always @(*) 
begin
    case (baud_rate)
      //  All these ratio ticks are calculated for 50MHz Clock,
      //  The values shall change with the change of the clock frequency.
      BAUD24: final_value  = 10'd651;     //  16 * 2400 BaudRate.
      BAUD48: final_value  = 10'd326;     //  16 * 4800 BaudRate.
      BAUD96: final_value  = 10'd163;     //  16 * 9600 BaudRate.
      BAUD192: final_value = 10'd81;      //  16 * 19200 BaudRate.
      default: final_value = 10'd163;     //  16 * 9600 BaudRate.
    endcase
end

always @(negedge rst, posedge clock) begin
  if(!rst)   begin
    clock_ticks   <= 10'd0;
    baud_clk      <= 1'b0;
  end
  else   begin
    if(clock_ticks == final_value)
    begin
      baud_clk      <= ~baud_clk;
      clock_ticks   <= 10'd0;
    end
    else  begin
      clock_ticks   <= clock_ticks + 1'd1;
      baud_clk      <= baud_clk;
    end
  end
end
endmodule