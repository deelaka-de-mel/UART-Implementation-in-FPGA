module uart_tx_rx_tb();

// Testbench drives these
reg clk;
reg i_tx_start;
reg [7:0] i_tx_data;

// Module outputs — testbench just reads these
wire o_tx ;       // serial connection between TX and RX
wire o_tx_done;        // TX done flag
wire [7:0] o_rx_data ;  // received byte
wire o_rx_done ;        // RX done flag

// Instantiate transmitter
tx uart_tx_inst (
    .clk(clk),
    .i_tx_start(i_tx_start),
    .i_tx_data(i_tx_data),
    .o_tx(o_tx),
    .o_tx_done(o_tx_done)
);

// Instantiate receiver
rx uart_rx_inst (
    .clk(clk),
    .i_rx(o_tx),      
    .o_rx_data(o_rx_data),
    .o_rx_done(o_rx_done)
);

// Clock generation
always #10 clk = ~clk;

initial begin
    // Initialise signals
    clk         = 0;
    i_tx_start  = 0;
    i_tx_data   = 8'h00;
    
    // Wait a few cycles then send 0xA5
    #100;
    i_tx_data  = 8'hA5;   //
	 #5
    i_tx_start = 1'b1;   // trigger the transmitter
    #20;                     // hold for one clock cycle
    i_tx_start = 1'b0;   // release trigger
    
    // Wait for reception to complete
    @(posedge o_rx_done);        
    
    if (o_rx_data == 8'hA5)
        $display("PASS: Received 0x%h", o_rx_data);
    else
        $display("FAIL: Received 0x%h, Expected 0xA5", o_rx_data);
    
    $finish;
end

endmodule