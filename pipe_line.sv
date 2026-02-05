module pipeline_reg #(
    parameter DATA_WIDTH = 32
)(
    input clk,
    input rst_n,

    input in_valid,
    output in_ready,
    input  [DATA_WIDTH-1:0] in_data,

    output out_valid,
    input  out_ready,
    output [DATA_WIDTH-1:0] out_data
);

    reg [DATA_WIDTH-1:0] data_q;
    reg  valid_q;

    // Ready when empty OR downstream ready
    assign in_ready  = (~valid_q) || out_ready;
    assign out_valid = valid_q;
    assign out_data  = data_q;

    always @(posedge clk) begin
        if (!rst_n) begin
            valid_q <= 1'b0;
        end
        else begin
            if (in_ready && in_valid) begin
                data_q  <= in_data;
                valid_q <= 1'b1;
            end
            else if (out_ready && out_valid) begin
                valid_q <= 1'b0;
            end
        end
    end

endmodule
