module seq(
    input logic [7:0] data_in,
    input logic data_valid,
    input logic clk, rst,
    output logic pattern_detected
);

    typedef enum logic [2:0] {
    IDLE = 3'b000,   
    A_1 = 3'b001,
    A_2 = 3'b010,
    X_1  = 3'b011,
    Y_1  = 3'b100,
    } state_t;

    state_t state, next_state;

    logic [7:0] A = 8'd1;
    logic [7:0] X = 8'd2;
    logic [7:0] Y = 8'd3;
    logic detected;

    always_comb begin

        case(state)

            IDLE: begin
                if (data_valid) begin
                    if (data_in==A) next_state = A_1;
                    else next_state = IDLE;
                end

                else next_state = IDLE;
            end
            
            A_1: begin
                if (data_valid) begin
                    if (data_in==A) next_state = A_2;
                    else next_state = IDLE;
                end

                else next_state = A_1;
            end
            
            A_2: begin
                if (data_valid) begin
                    if (data_in==A) next_state = A_2;
                    else if (data_in==X) next_state = X_1;
                    else next_state = IDLE;
                end

                else next_state = A_2;
            end

            X_1: begin
                if (data_valid) begin
                    if (data_in==Y) next_state = Y_1;
                    else next_state = IDLE;
                end

                else next_state = X_1;
            end


            Y_1: next_state = IDLE;
        endcase

    end

    always_ff @(posedge clk) begin
        
        if (rst) begin
            state <= IDLE;
            detected <=0
        end

        else begin
            state <= next_state;
            case(state) 
                IDLE: detected <= 0;
                Y_1 : detected <= 1;
            endcase
        end

    end

    assign pattern_detected = detected;

endmodule