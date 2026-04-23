// Parallel ADC latch; one-cycle sample_ready pulse on adc_valid
module adc_interface (
    input  wire        clk,
    input  wire        rst,
    input  wire [11:0] adc_data_in,
    input  wire        adc_valid,
    output reg  [11:0] adc_data,
    output reg         sample_ready
);

always @(posedge clk) begin
    if (rst) begin
        adc_data     <= 12'd0;
        sample_ready <= 1'b0;
    end else if (adc_valid) begin
        adc_data     <= adc_data_in;
        sample_ready <= 1'b1;
    end else begin
        sample_ready <= 1'b0;
    end
end

endmodule
