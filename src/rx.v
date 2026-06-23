module rx (
    input       clk,
	 input 		 i_rx,			// serial input line
    output [7:0] o_rx_data,    // byte received       
    output reg  o_rx_done     // pulses high when byte is done
);

parameter CLKS_PER_BIT = 5208;

// States
parameter IDLE  = 2'b00;
parameter START = 2'b01;
parameter DATA  = 2'b10;
parameter STOP  = 2'b11;

reg [7:0] rx_data = 0;  // internal shift register
reg [1:0]  state     = IDLE;
reg [12:0] clk_count = 0;   // counts up to CLKS_PER_BIT
reg [2:0]  bit_index = 0;   // counts 0 to 7

always @(posedge clk) begin
   case (state)
	
	IDLE: begin
		o_rx_done <= 1'b0;
		if (i_rx==1'b0) begin
			state <= START;
		end
	end
	
	START: begin
		if (clk_count<CLKS_PER_BIT/2) begin
			clk_count<=clk_count+1;
		end
		else begin
			if (i_rx==1'b0) begin
				state <= DATA;
				clk_count<=1'b0;
			end
			else begin
				state <= IDLE;
				clk_count<=0;
			end
		end
	end
	
	DATA: begin
		if (clk_count< CLKS_PER_BIT-1) begin
			clk_count<=clk_count+1;
		end
		else begin
			clk_count<=0;
			rx_data[bit_index] <= i_rx;
			if (bit_index==7) begin
			bit_index<=0;
			state <= STOP;
			end
			else begin
			bit_index<=bit_index+1;
			end
		end
	end
	
	STOP: begin
		if (clk_count < CLKS_PER_BIT) begin
			clk_count <= clk_count + 1;
		end
		else begin
			o_rx_done<=1'b1;
			clk_count <= 0;
			state     <= IDLE;
		end
	end
	 
   endcase
end

assign o_rx_data = rx_data;

endmodule