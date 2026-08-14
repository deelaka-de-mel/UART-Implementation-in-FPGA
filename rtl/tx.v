module tx (
    input       clk,
    input       i_tx_start,   // pulse high to send
    input [7:0] i_tx_data,    // byte to transmit
    output reg  o_tx,         // serial output line
    output reg  o_tx_done     // pulses high when done
);

parameter CLKS_PER_BIT = 5208;	//baudrate = 9600 bps

// States
parameter IDLE  = 2'b00;
parameter START = 2'b01;
parameter DATA  = 2'b10;
parameter STOP  = 2'b11;

reg [1:0]  state     = IDLE;
reg [12:0] clk_count = 0;   // counts up to CLKS_PER_BIT
reg [2:0]  bit_index = 0;   // counts 0 to 7

always @(posedge clk) begin
    case (state)

        IDLE: begin
				o_tx_done <= 1'b0;
            o_tx   <= 1'b1;  // line held high in idle
            if (i_tx_start) begin
                state <= START;
            end
        end

        START: begin
            o_tx <= 1'b0;    // pull line low
            if (clk_count < CLKS_PER_BIT) begin
                clk_count <= clk_count + 1;
            end else begin
                clk_count <= 0;
                state     <= DATA;
            end
        end

        DATA: begin
            o_tx <= i_tx_data[bit_index];  
            
				if (clk_count<CLKS_PER_BIT) begin
					clk_count<=clk_count+1;
				end
				else begin
					clk_count<=0;
					if (bit_index==7) begin
						bit_index <=0;
						state<=STOP;
					end
					else begin
						bit_index <= bit_index+1;
					end
				end
        end

        STOP: begin
				o_tx <= 1'b1;    // pull line high
            if (clk_count < CLKS_PER_BIT) begin
                clk_count <= clk_count + 1;
            end else begin
					o_tx_done <= 1'b1;
               clk_count <= 0;
               state     <= IDLE;
            end
        end

    endcase
end
endmodule