`timescale 1ns/1ps
module baud_test;
reg rst,clock;
reg [1:0] baud_rate;
wire T_baud_clk,R_baud_clk;

BaudGenR t(.rst(rst),.clock(clock),
    .baud_rate(baud_rate),.baud_clk(R_baud_clk));
BaudGenT t2(.rst(rst),.clock(clock),
    .baud_rate(baud_rate),.baud_clk(T_baud_clk));
initial begin
                clock = 1'b1;
    forever #2.5 clock = ~clock;
end
initial begin
        rst = 1'b0; baud_rate = 2'b10;#5  
        rst = 1'b1; #3500000
        $stop;
end
endmodule
