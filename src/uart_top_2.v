module uart_top_2 (
	input        clk,        // 50MHz onboard clock
   input        i_rx,       // UART input from GPIO pin
   output       o_tx,       // UART output to GPIO pin
	input 		 i_tx_start,
	output [7:0] rx_LED,
	input [3:0]  sw,
	output [6:0] hex0, 
   output [6:0] hex1    
	);
	

wire [7:0] rx_data;
wire [7:0] tx_data = 8'b10101010;
wire [3:0] lower_nibble = rx_data[3:0];
wire [3:0] upper_nibble = rx_data[7:4];

//Loop through 
reg [25:0] sec_counter = 0;  // 26 bits needed to count to 50,000,000
wire sec_tick = (sec_counter == 26'd49_999_999); //counting starts from 0 to 49,999,999

always @(posedge clk) begin
    if (sec_tick)
        sec_counter <= 0;
    else
        sec_counter <= sec_counter + 1;
end

reg [7:0] tx_byte = 8'h00;

always @(posedge clk) begin
    if (sec_tick)
        tx_byte <= tx_byte + 1;  // increments every second
end
//

// Edge detection
reg  prev_start = 0;
wire tx_pulse   = (~i_tx_start) & ~prev_start;

always @(posedge clk)
    prev_start <= ~i_tx_start;
//
	 
tx uart_tx_inst (
    .clk        (clk),
    .i_tx_start (sec_tick),  //changed from ~i_tx_start
    .i_tx_data  (tx_byte),
    .o_tx       (o_tx),
    .o_tx_done  ()
);
	
rx uart_rx_inst (
    .clk      (clk),
    .i_rx     (i_rx),
    .o_rx_data(rx_data),
    .o_rx_done()
);

function [6:0] hex_to_seg;
    input [3:0] digit;
    begin
        case (digit)
            4'h0: hex_to_seg = 7'b1000000;
            4'h1: hex_to_seg = 7'b1111001;
            4'h2: hex_to_seg = 7'b0100100;
            4'h3: hex_to_seg = 7'b0110000;
            4'h4: hex_to_seg = 7'b0011001;
            4'h5: hex_to_seg = 7'b0010010;
            4'h6: hex_to_seg = 7'b0000010;
            4'h7: hex_to_seg = 7'b1111000;
            4'h8: hex_to_seg = 7'b0000000;
            4'h9: hex_to_seg = 7'b0011000;
            4'hA: hex_to_seg = 7'b0001000;
            4'hB: hex_to_seg = 7'b0000011;
            4'hC: hex_to_seg = 7'b1000110;
            4'hD: hex_to_seg = 7'b0100001;
            4'hE: hex_to_seg = 7'b0000110;
            4'hF: hex_to_seg = 7'b0001110;
            default: hex_to_seg = 7'b1111111;
        endcase
    end
endfunction

assign hex0 = ~hex_to_seg(lower_nibble);
assign hex1 = hex_to_seg(upper_nibble);

assign rx_LED = tx_byte;

endmodule