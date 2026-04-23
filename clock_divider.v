// Generates one-cycle sample_tick at SAMPLE_RATE from CLK_FREQ
module clock_divider #(
    parameter CLK_FREQ    = 10_000_000,
    parameter SAMPLE_RATE = 500
)(
    input  wire clk,
    input  wire rst,
    output reg  sample_tick
);

localparam integer DIV_COUNT = CLK_FREQ / SAMPLE_RATE;
localparam integer CNT_W     = $clog2(DIV_COUNT);

reg [CNT_W-1:0] counter;

always @(posedge clk) begin
    if (rst) begin
        counter     <= {CNT_W{1'b0}};
        sample_tick <= 1'b0;
    end else if (counter == DIV_COUNT - 1) begin
        counter     <= {CNT_W{1'b0}};
        sample_tick <= 1'b1;
    end else begin
        counter     <= counter + 1'b1;
        sample_tick <= 1'b0;
    end
end

endmodule
