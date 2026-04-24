`timescale 1ns / 1ps

module traffic_case4 (
    input wire clk,
    input wire rst,
    input wire a1, a2, a3,
    input wire b1, b2, b3,
    input wire c1, c2, c3,
    input wire d1, d2, d3,
    input wire sa, sb, sc, sd,
    output reg [2:0] A,
    output reg [2:0] B,
    output reg [2:0] C,
    output reg [2:0] D
);

parameter RED    = 3'b001;
parameter YELLOW = 3'b010;
parameter GREEN  = 3'b100;

parameter IDLE     = 4'd0,
          A_GREEN  = 4'd1, A_YELLOW = 4'd2,
          B_GREEN  = 4'd3, B_YELLOW = 4'd4,
          C_GREEN  = 4'd5, C_YELLOW = 4'd6,
          D_GREEN  = 4'd7, D_YELLOW = 4'd8;

// State registers
reg [3:0] state;
reg [1:0] cycle_count;
reg reverse_mode;
reg [1:0] reverse_step;
reg [5:0] count;
reg [1:0] selected_road;

// Emergency tracking
reg emergency_being_served;
reg [1:0] served_emergency_dir;

// Clock divider
reg [26:0] clk_div;
wire slow_clk;

always @(posedge clk or posedge rst) begin
    if (rst)
        clk_div <= 0;
    else
        clk_div <= clk_div + 1;
end

assign slow_clk = clk_div[24];

// Input synchronization
reg a1_ff1, a2_ff1, a3_ff1;
reg b1_ff1, b2_ff1, b3_ff1;
reg c1_ff1, c2_ff1, c3_ff1;
reg d1_ff1, d2_ff1, d3_ff1;
reg sa_ff1, sb_ff1, sc_ff1, sd_ff1;

reg a1_s, a2_s, a3_s;
reg b1_s, b2_s, b3_s;
reg c1_s, c2_s, c3_s;
reg d1_s, d2_s, d3_s;
reg sa_s, sb_s, sc_s, sd_s;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        a1_ff1<=0; a2_ff1<=0; a3_ff1<=0;
        b1_ff1<=0; b2_ff1<=0; b3_ff1<=0;
        c1_ff1<=0; c2_ff1<=0; c3_ff1<=0;
        d1_ff1<=0; d2_ff1<=0; d3_ff1<=0;
        sa_ff1<=0; sb_ff1<=0; sc_ff1<=0; sd_ff1<=0;

        a1_s<=0; a2_s<=0; a3_s<=0;
        b1_s<=0; b2_s<=0; b3_s<=0;
        c1_s<=0; c2_s<=0; c3_s<=0;
        d1_s<=0; d2_s<=0; d3_s<=0;
        sa_s<=0; sb_s<=0; sc_s<=0; sd_s<=0;
    end else begin
        a1_ff1<=a1; a2_ff1<=a2; a3_ff1<=a3;
        b1_ff1<=b1; b2_ff1<=b2; b3_ff1<=b3;
        c1_ff1<=c1; c2_ff1<=c2; c3_ff1<=c3;
        d1_ff1<=d1; d2_ff1<=d2; d3_ff1<=d3;
        sa_ff1<=sa; sb_ff1<=sb; sc_ff1<=sc; sd_ff1<=sd;

        a1_s<=a1_ff1; a2_s<=a2_ff1; a3_s<=a3_ff1;
        b1_s<=b1_ff1; b2_s<=b2_ff1; b3_s<=b3_ff1;
        c1_s<=c1_ff1; c2_s<=c2_ff1; c3_s<=c3_ff1;
        d1_s<=d1_ff1; d2_s<=d2_ff1; d3_s<=d3_ff1;
        sa_s<=sa_ff1; sb_s<=sb_ff1; sc_s<=sc_ff1; sd_s<=sd_ff1;
    end
end

// Density calculation
wire [5:0] A_den = (a1_s&a2_s&a3_s) ? 30 :
                   ((a1_s&a2_s)|(a2_s&a3_s)|(a1_s&a3_s)) ? 20 :
                   (a1_s|a2_s|a3_s) ? 10 : 0;

wire [5:0] B_den = (b1_s&b2_s&b3_s) ? 30 :
                   ((b1_s&b2_s)|(b2_s&b3_s)|(b1_s&b3_s)) ? 20 :
                   (b1_s|b2_s|b3_s) ? 10 : 0;

wire [5:0] C_den = (c1_s&c2_s&c3_s) ? 30 :
                   ((c1_s&c2_s)|(c2_s&c3_s)|(c1_s&c3_s)) ? 20 :
                   (c1_s|c2_s|c3_s) ? 10 : 0;

wire [5:0] D_den = (d1_s&d2_s&d3_s) ? 30 :
                   ((d1_s&d2_s)|(d2_s&d3_s)|(d1_s&d3_s)) ? 20 :
                   (d1_s|d2_s|d3_s) ? 10 : 0;

// Emergency detection
wire emergency_active = sa_s | sb_s | sc_s | sd_s;
reg [1:0] emergency_dir;

always @(*) begin
    if (sa_s) emergency_dir = 2'd0;
    else if (sc_s) emergency_dir = 2'd2;
    else if (sb_s) emergency_dir = 2'd1;
    else if (sd_s) emergency_dir = 2'd3;
    else emergency_dir = 2'd0;
end

// Scheduler
reg [1:0] next_road;
reg [5:0] max_den;
reg [3:0] candidates;

always @(*) begin
    max_den = A_den;
    if (C_den > max_den) max_den = C_den;
    if (B_den > max_den) max_den = B_den;
    if (D_den > max_den) max_den = D_den;

    candidates = 4'b0000;
    if (A_den == max_den) candidates[0] = 1;
    if (C_den == max_den) candidates[2] = 1;
    if (B_den == max_den) candidates[1] = 1;
    if (D_den == max_den) candidates[3] = 1;

    if (candidates[0]) next_road = 2'd0;
    else if (candidates[2]) next_road = 2'd2;
    else if (candidates[1]) next_road = 2'd1;
    else next_road = 2'd3;
end

// FSM
always @(posedge slow_clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        count <= 0;
    end else begin
        case (state)
            IDLE: begin
                count <= 0;
                selected_road <= next_road;
                case (selected_road)
                    2'd0: state <= A_GREEN;
                    2'd1: state <= B_GREEN;
                    2'd2: state <= C_GREEN;
                    2'd3: state <= D_GREEN;
                endcase
            end

            A_GREEN: begin
                if (count < A_den) count <= count + 1;
                else begin count <= 0; state <= A_YELLOW; end
            end

            A_YELLOW: begin
                if (count < 5) count <= count + 1;
                else begin count <= 0; state <= IDLE; end
            end

            default: state <= IDLE;
        endcase
    end
end

// Output logic
always @(*) begin
    A = RED; B = RED; C = RED; D = RED;

    case (state)
        A_GREEN:  A = GREEN;
        A_YELLOW: A = YELLOW;
        B_GREEN:  B = GREEN;
        B_YELLOW: B = YELLOW;
        C_GREEN:  C = GREEN;
        C_YELLOW: C = YELLOW;
        D_GREEN:  D = GREEN;
        D_YELLOW: D = YELLOW;
    endcase
end

endmodule
