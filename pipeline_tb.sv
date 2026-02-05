module tb;

    reg clk;
    reg rst_n;

    // Inputs to DUT → reg
    reg        in_valid;
    reg [31:0] in_data;
    reg        out_ready;

    // Outputs from DUT → wire
    wire       in_ready;
    wire       out_valid;
    wire [31:0] out_data;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // DUT
    pipeline_reg dut (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .in_data(in_data),
        .out_valid(out_valid),
        .out_ready(out_ready),
        .out_data(out_data)
    );

    // Dump for waveform
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        // Initialize
        rst_n      = 0;
        in_valid  = 0;
        out_ready = 0;
        in_data   = 0;

        // Release reset
        #20 rst_n = 1;

        // Send data
        @(posedge clk);
        in_valid = 1;
        in_data  = 32'hA5A5A5A5;

        // Apply backpressure
        out_ready = 0;
        repeat (3) @(posedge clk);

        // Release backpressure
        out_ready = 1;
        @(posedge clk);

        // Stop sending
        in_valid = 0;

        // Finish
        #40 $finish;
    end

    // Monitor (unchanged behavior)
    initial begin
        $monitor("T=%0t | in_v=%b in_r=%b in_d=%h | out_v=%b out_r=%b out_d=%h",
                  $time, in_valid, in_ready, in_data,
                  out_valid, out_ready, out_data);
    end

endmodule
