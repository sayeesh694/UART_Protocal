module Uart (
    input rst,                  //  Active low reset.
    send,                       //  An enable to start sending data.
    clock,                      //  The main system's clock.
    input [1:0]parity_type,     //  Parity type agreed upon by the Tx and Rx units.
    input [1:0]baud_rate,       //  Baud Rate agreed upon by the Tx and Rx units.
    input [7:0]data_in,         //  The data input.
    output tx_active_flag,      //  outputs logic 1 when data is in progress.
    tx_done_flag,               //  Outputs logic 1 when data is transmitted
    rx_active_flag,             //  outputs logic 1 when data is in progress.
    rx_done_flag,               //  Outputs logic 1 when data is recieved
    output [7:0]data_out,       //  The 8-bits data separated from the frame.
    output [2:0]error_flag      //  Consits of three bits, each bit is a flag for an error
                                //  error_flag[0] ParityError flag, error_flag[1] StartError flag,
                                //  error_flag[2] StopError flag.
);
wire data_tx_w;       

TxUnit Transmitter(.rst(rst),.send(send),
    .clock(clock),.parity_type(parity_type),
    .baud_rate(baud_rate),.data_in(data_in),
    .data_tx(data_tx_w),.active_flag(tx_active_flag),
    .done_flag(tx_done_flag));

RxUnit Reciever(.rst(rst),.clock(clock),.parity_type(parity_type),
    .baud_rate(baud_rate),.data_tx(data_tx_w),
    .data_out(data_out),.error_flag(error_flag),
    .active_flag(rx_active_flag),
    .done_flag(rx_done_flag));
endmodule