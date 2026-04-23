// Single-entry handshake buffer; drops if full, sticky sample_dropped flag
module ecg_sampler #(
    parameter DATA_WIDTH = 12
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  sample_tick,
    input  wire [DATA_WIDTH-1:0] adc_data,
    input  wire                  adc_valid,
    output wire                  adc_ready,
    output reg  [DATA_WIDTH-1:0] sample_out,
    output reg                   sample_valid,
    input  wire                  sample_ready,
    output reg                   sample_dropped
);

assign adc_ready = ~sample_valid;

always @(posedge clk) begin
    if (rst) begin
        sample_out     <= {DATA_WIDTH{1'b0}};
        sample_valid   <= 1'b0;
        sample_dropped <= 1'b0;
    end else begin
        if (sample_valid && sample_ready) begin
            sample_valid   <= 1'b0;
            sample_dropped <= 1'b0;
        end
        if (adc_valid && sample_tick && adc_ready) begin
            sample_out   <= adc_data;
            sample_valid <= 1'b1;
        end
        if (adc_valid && sample_tick && ~adc_ready)
            sample_dropped <= 1'b1;
    end
end

endmodule
