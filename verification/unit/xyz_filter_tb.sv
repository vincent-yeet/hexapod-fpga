`timescale 1ns/1ps


module xyz_filter_tb;
    // Start clock
    logic aclk = 0;
    always #5 aclk = ~aclk;

    // DUT input signals
    logic areset_n;

    logic [191:0] s_axis_tdata;
    logic         s_axis_tvalid;
    logic         s_axis_tready;

    logic [191:0] m_axis_tdata;
    logic         m_axis_tvalid;
    logic         m_axis_tready;

    // Instantiate DUT
    xyz_filter #(
        .x_min(-100), .x_max(100),
        .y_min(-200), .y_max(200),
        .z_min(-300), .z_max(300)
    ) dut (
        .*
    );

    function automatic logic [191:0] make_point(
        input integer x,
        input integer y,
        input integer z,
        input logic valid_flag
    );
        logic [191:0] point;

        // Initialize point to zeros then assign the necessary bit fields
        point = '0;
        point[31:0] = x;
        point[63:32] = y;
        point[95:64] = z;

        // Assign distinct, arbitrary, nonzero values to each bit field
        point[159:96] = 64'h123456789abcdef0;
        point[167:160] = 8'h42;
        point[175:168] = 8'h12;
        point[183:176] = 8'h01;
        point[184] = valid_flag;
        return point;

    endfunction

    task automatic check_point(
        input logic [191:0] point,
        input logic         expect_keep
    );
        begin
            // Drive at falling edge to avoid race conditions
            @(negedge aclk);
            s_axis_tdata = point;
            s_axis_tvalid = 1'b1;

            // Hold input high until accepted by filter
            do begin
                @(posedge aclk);
            end while (!s_axis_tready);

            // Allow combinational logic to exectue and settle
            #1

            if (m_axis_tvalid !== expect_keep)
                $fatal(1, "Incorrect keep/drop");

            if (expect_keep && m_axis_tdata !== point)
                $fatal(1, "Data mismatch in kept point");

            @(negedge aclk);
            s_axis_tvalid = 1'b0;

            // Confirm behavior after output consumed and no new input
            @(posedge aclk);
            #1

            if (m_axis_tvalid !== 1'b0)
                $fatal(1, "Unexpected behavior after input became idle");
        end
    endtask

    initial begin
        $dumpfile("build/xyz_filter_tb.vcd");
        $dumpvars(0, xyz_filter_tb);

        // Initialize inputs
        areset_n      = 1'b0;
        s_axis_tvalid = 1'b0;
        m_axis_tready = 1'b1;
        s_axis_tdata  = '0;

        // Test reset
        repeat(2) @(posedge aclk);
        #1;

        if (m_axis_tvalid !== 1'b0)
            $fatal(1, "Reset did not output tvalid");

        // Release reset and do some basic filter tests
        @(negedge aclk);
        areset_n = 1'b1;

        check_point(make_point(0, 0, 0, 1), 1);
        check_point(make_point(-50, -150, -250, 1), 1);
        check_point(make_point(101, 0, 0, 1), 0);
        check_point(make_point(0, 0, 0, 0), 0);

        $display("PASS: Basic filter tests");
        $finish;
    end

    // Timeout Loop
    initial begin
        #10000;
        $fatal(1, "Simuation timeout");
    end

endmodule
