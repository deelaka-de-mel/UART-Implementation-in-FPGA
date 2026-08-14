module uart_tb();

// 1. Declare signals
reg clk = 0;
reg i_rx = 1;  // start idle HIGH
wire [7:0] o_rx_data;
wire o_rx_done;

// 2. Generate clock
always #10 clk = ~clk;

//instantiate receiver
	rx dut (
    .clk(clk),
    .i_rx(i_rx),
    .o_rx_data(o_rx_data),
    .o_rx_done(o_rx_done)
);

// 4. Send byte 0b10100101 (0xA5)
initial begin
    // start bit
    i_rx <= 1'b0;
    #104167;
    
    // data bits D0-D7 (LSB first!)
    // 0xA5 = 10100101 in binary
    // LSB first means i send: 1,0,1,0,0,1,0,1
    i_rx <= 1'b1;  // D0
    #104167;
    i_rx <= 1'b0;  // D1
    #104167;
	 i_rx <= 1'b1;  // D2
    #104167;
	 i_rx <= 1'b0;  // D3
    #104167;
	 i_rx <= 1'b0;  // D4
    #104167;
	 i_rx <= 1'b1;  // D5
    #104167;
	 i_rx <= 1'b0;  // D6
    #104167;
	 i_rx <= 1'b1;  // D7
    #104167;
    
    // stop bit
    i_rx <= 1'b1;
    #104167;
	 
	@(posedge o_rx_done);  // wait until receiver signals done
	#104167;
	$display("Received: 0x%h, Expected: 0xA5", o_rx_data);
	if (o_rx_data == 8'hA5)
		 $display("PASS");
	else
		 $display("FAIL");
	$finish;
end

endmodule