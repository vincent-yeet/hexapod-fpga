module xyz_filter #(
    parameter signed x_min = -32'sd10000,
    parameter signed x_max = 32'sd10000,
    parameter signed y_min = -32'sd10000,
    parameter signed y_max = 32'sd10000,
    parameter signed z_min = -32'sd10000,
    parameter signed z_max = 32'sd10000
) (
    input  logic         aclk,
    input  logic         areset_n,

    // AXI Connection to point sampler
    input  logic [191:0] s_axis_tdata,
    input  logic         s_axis_tvalid,
    output logic         s_axis_tready,

    // AXI Connection to next pipeline stage
    output logic [191:0] m_axis_tdata,
    output logic         m_axis_tvalid,
    input  logic         m_axis_tready
);

// Decode point position
logic signed [31:0] x_pos;
logic signed [31:0] y_pos;
logic signed [31:0] z_pos;
logic               point_valid;  
assign x_pos       = s_axis_tdata[31:0];
assign y_pos       = s_axis_tdata[63:32];
assign z_pos       = s_axis_tdata[95:64];
assign point_valid = s_axis_tdata[184];

// Filtering logic
logic keep_point;
assign keep_point = point_valid &&
                    (x_pos >= x_min) && (x_pos <= x_max) &&
                    (y_pos >= y_min) && (y_pos <= y_max) &&
                    (z_pos >= x_min) && (z_pos <= z_max);

// AXI logic
// Output is buffered (register). Accept filtered input
// When the register is empty or is about to be consumed.
assign s_axis_tready = !m_axis_tvalid || m_axis_tready;
always_ff @(posedge aclk) begin
    if (!areset_n) begin
        m_axis_tvalid <= 1'b0;
    end else if (s_axis_tready) begin
        if (m_axis_tready && keep_point) begin
            m_axis_tdata <= s_axis_tdata;
            m_axis_tvalid <= 1'b1;
        end else begin
            m_axis_tvalid <= 1'b0;
        end
    end
end


endmodule