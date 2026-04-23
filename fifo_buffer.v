// Synchronous FIFO — 64-deep, registered read, sticky overflow flag
module fifo_buffer #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 64
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] din,
    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] dout,
    output wire                  full,
    output wire                  empty,
    output reg                   overflow
);

localparam ADDR_W = 6; // log2(64)

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
reg [ADDR_W:0]       wr_ptr;
reg [ADDR_W:0]       rd_ptr;

assign empty = (wr_ptr == rd_ptr);
assign full  = (wr_ptr[ADDR_W] != rd_ptr[ADDR_W]) &&
               (wr_ptr[ADDR_W-1:0] == rd_ptr[ADDR_W-1:0]);

always @(posedge clk) begin
    if (rst) begin
        wr_ptr   <= 7'd0;
        rd_ptr   <= 7'd0;
        dout     <= {DATA_WIDTH{1'b0}};
        overflow <= 1'b0;
    end else begin
        if (wr_en) begin
            if (!full) begin
                mem[wr_ptr[ADDR_W-1:0]] <= din;
                wr_ptr <= wr_ptr + 1'b1;
            end else begin
                overflow <= 1'b1;
            end
        end
        if (rd_en && !empty) begin
            dout   <= mem[rd_ptr[ADDR_W-1:0]];
            rd_ptr <= rd_ptr + 1'b1;
        end
    end
end

endmodule
