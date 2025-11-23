module TxUnit(
    input rst,              //  Active low reset.
    send,                   //  An enable to start sending data.
    clock,                  //  The main system's clock.
    input [1:0]parity_type, //  Parity type agreed upon by the Tx and Rx units.
    input [1:0]baud_rate,   //  Baud Rate agreed upon by the Tx and Rx units.
    input [7:0]data_in,     //  The data input.
    output data_tx,         //  Serial transmitter's data out.
    active_flag,            //  high when Tx is transmitting, low when idle.
    done_flag               //  high when transmission is done, low when active.
); 
wire parity_bit_w,baud_clk_w;

BaudGenT Unit1(.rst(rst),.clock(clock),.baud_rate(baud_rate),   
     .baud_clk(baud_clk_w));

Parity Unit2(.rst(rst),.data_in(data_in),.parity_type(parity_type),
    .parity_bit(parity_bit_w));

PISO Unit3(.rst(rst),.send(send),.baud_clk(baud_clk_w),.data_in(data_in),
    .parity_bit(parity_bit_w),.data_tx(data_tx),.active_flag(active_flag),
    .done_flag(done_flag));
endmodule