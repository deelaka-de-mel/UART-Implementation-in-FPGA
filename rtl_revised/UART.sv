module UART(
    input logic tx_start, 
    input logic rst,
    input logic clk,
    input logic [7:0] i_tx_data,    //transmit data
    output logic o_tx,      //output wire
    output logic o_tx_done,

    input logic		 i_rx,			// serial input line
    output logic [7:0] o_rx_data,    // byte received       
    output logic  o_rx_done     // pulses high when byte is done

);
    tx transmitter(
        .clk(clk)
        .rst(rst),  
        .tx_start(tx_start),
        .i_tx_data(i_tx_data),
        .o_tx(o_tx),
        .o_tx_done(o_tx_done)
    );

    rx receiver(
        .clk(clk),
        .rst(rst),
        .i_rx(i_rx),
        .o_rx_data(o_rx_data),
        .o_rx_done(o_rx_done)
    );

endmodule