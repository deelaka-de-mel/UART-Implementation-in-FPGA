module uart_tx#(
	parameter int BAUD=9600,
    parameter CLK_FREQ= 50_000_000
	)
    (
    input logic tx_start, 
    input logic rst,
    input logic clk,
    input logic [7:0] i_tx_data,

    output logic o_tx,
    output logic o_tx_done
    );

    parameter CLKS_PER_BIT = CLK_FREQ/BAUD;
    parameter FRAME_LENGTH = 8;

    logic [$clog2(CLKS_PER_BIT)-1:0] clk_count;
    logic [$clog2(FRAME_LENGTH):0] bit_count;
    logic done;

    typedef enum logic [1:0] {
    IDLE  = 2'b00,
    START = 2'b01,
    DATA  = 2'b10,
    STOP  = 2'b11
    } state_t;

    state_t state , next_state;

    always_comb begin
        case(state)
            IDLE: next_state = (tx_start)? START : IDLE;
            START: next_state = DATA;
            DATA : next_state = (done)? STOP : DATA;
            STOP : next_state = IDLE;
        endcase 
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            o_tx_done <= '0;
            clk_count<=0;
            bit_count <=0;
            o_tx <= 1;
        end
        
        else begin
            state <= next_state
            case(state)
                IDLE: begin 
                    o_tx <= '1;
                    done<=0;
                    clk_count<=0;
                    bit_count <=0;
                    o_tx_done<=0;
                end
                
                START: o_tx <= '0;

                DATA: begin
                    o_tx <= i_tx_data[bit_count];
                    if (clk_count < CLKS_PER_BIT) begin
                        clk_count <= clk_count + 1;
                    end
                    else begin
                        bit_count <= bit_count + 1;
                    end

                    if (bit_count == FRAME_LENGTH) done <= '1;
                end

                STOP : begin
                    o_tx_done <= '1;
                    o_tx <= '0;
                end
            endcase
        end

    end

endmodule