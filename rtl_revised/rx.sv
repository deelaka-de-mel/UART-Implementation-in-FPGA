module rx#(
    parameter int BAUD=9600,
    parameter CLK_FREQ= 50_000_000
)(
    input logic     clk, rst,
	input logic		 i_rx,			// serial input line
    output logic [7:0] o_rx_data,    // byte received       
    output logic  o_rx_done     // pulses high when byte is done
);
    parameter CLKS_PER_BIT = CLK_FREQ/BAUD;
    parameter FRAME_LENGTH = 8;

    logic [$clog2(CLKS_PER_BIT)-1:0] clk_count;
    logic [$clog2(FRAME_LENGTH)-1:0] bit_count;
    logic [7:0] rx_data;
    logic done;
    logic pre_count;

    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter STOP  = 2'b11;

    logic [1:0] state = IDLE;
    logic [1:0] next_state;

    always_comb begin
        case(state)
            IDLE: next_state = (!i_rx)? START : IDLE;
            START: next_state = (pre_count)? DATA : START;
            DATA: next_state = (done)? STOP : DATA;
            STOP : next_state = IDLE;
        endcase

    end

    always_ff @(posedge clk) begin
        
        if (rst) begin
            state<=IDLE;
        end

        else begin
            state <= next_state;
            case(state) 
                IDLE: begin 
                    o_rx_done<=0;
                    clk_count <=0;
                    bit_count<=0;
                    pre_count <=0;
                    done <=0;

                end

                START: begin
                    if (clk_count < CLKS_PER_BIT/2) clk_count <= clk_count+1;
                    else begin
                        clk_count<=0;
                        pre_count <=1;
                    end
                end

                DATA: begin
                    if (clk_count < CLKS_PER_BIT/2) clk_count <= clk_count+1;
                    else begin
                        if (bit_count<FRAME_LENGTH) begin
                            rx_data[bit_count] <= i_rx;
                            bit_count <= bit_count+1;
                            clk_count <=0;
                        end

                        else done <= 1;
                    end

                end

                STOP : begin
                    
                end
            endcase
        end


    end

    assign o_rx_data = rx_data;


endmodule