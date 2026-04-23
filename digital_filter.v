// 8-tap LP moving average then 64-tap HP subtraction — removes noise and baseline drift
module digital_filter (
    input  wire        clk,
    input  wire        rst,
    input  wire        sample_valid,
    input  wire signed [31:0] sample_in,
    output reg         out_valid,
    output reg  signed [31:0] sample_out
);

// Low-pass: 8-sample running sum, divide by 8 (shift 3)
reg signed [31:0] sr8 [0:7];
reg signed [34:0] sum8;
wire signed [31:0] lp_out;

assign lp_out = $signed(sum8[34:3]);

always @(posedge clk) begin
    if (rst) begin
        sum8    <= 35'd0;
        sr8[0] <= 32'd0; sr8[1] <= 32'd0;
        sr8[2] <= 32'd0; sr8[3] <= 32'd0;
        sr8[4] <= 32'd0; sr8[5] <= 32'd0;
        sr8[6] <= 32'd0; sr8[7] <= 32'd0;
    end else if (sample_valid) begin
        sum8   <= sum8 - sr8[7] + sample_in;
        sr8[7] <= sr8[6]; sr8[6] <= sr8[5]; sr8[5] <= sr8[4];
        sr8[4] <= sr8[3]; sr8[3] <= sr8[2]; sr8[2] <= sr8[1];
        sr8[1] <= sr8[0]; sr8[0] <= sample_in;
    end
end

// High-pass: subtract 64-sample slow average (shift 6) from lp_out
reg signed [37:0] sum64;
reg signed [31:0] sr64 [0:63];
wire signed [31:0] slow_avg;
wire signed [31:0] hp_out;
reg [5:0]          sr64_wr;

assign slow_avg = $signed(sum64[37:6]);
assign hp_out   = lp_out - slow_avg;

always @(posedge clk) begin : blk_hp
    integer i;
    if (rst) begin
        sum64   <= 38'd0;
        sr64_wr <= 6'd0;
        for (i = 0; i < 64; i = i + 1) sr64[i] <= 32'd0;
    end else if (sample_valid) begin
        sum64         <= sum64 - sr64[sr64_wr] + lp_out;
        sr64[sr64_wr] <= lp_out;
        sr64_wr       <= sr64_wr + 6'd1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        sample_out <= 32'd0;
        out_valid  <= 1'b0;
    end else begin
        out_valid  <= sample_valid;
        sample_out <= hp_out;
    end
end

endmodule
