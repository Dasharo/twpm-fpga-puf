module top (clk_i, rstn_i, uart0_rxd_i, uart0_txd_o, led_r, led_g, led_b);

parameter PUF_REGS_BASE_ADDRESS = 32'hF0001800;
parameter PUF_REGS_ADDR_WIDTH   = 11;
parameter PUF_REG_CTRL          = 2'b00;
parameter PUF_REG_CHALLENGE     = 2'b01;
parameter PUF_REG_ID0           = 2'b10;
parameter PUF_REG_ID1           = 2'b11;
parameter DEFAULT_READ_VALUE    = 32'hBAD_FAB_AC; // Bad FPGA Access

input  wire         clk_i;
input  wire         rstn_i;

input  wire         uart0_rxd_i;
output wire         uart0_txd_o;

output wire         led_r;
output wire         led_g;
output wire         led_b;

wire        [ 31:0] wb_adr;    // address
reg         [ 31:0] wb_dat_rd; // read data
wire        [ 31:0] wb_dat_wr; // write data
wire                wb_we;     // write enable
wire        [  3:0] wb_sel;    // byte enable
wire                wb_stb;    // strobe
wire                wb_cyc;    // cycle valid
reg                 wb_ack;    // transfer ack
reg                 wb_err;    // transfer error
wire                wb_clk;    // wishbone clock

assign              wb_clk = clk_i;

`ifdef USE_ARB_PUF
wire                hits_puf   = (wb_adr[31:PUF_REGS_ADDR_WIDTH] === PUF_REGS_BASE_ADDRESS[31:PUF_REGS_ADDR_WIDTH]);

reg                 puf_en = 0;
reg          [31:0] puf_challenge;
wire         [95:0] puf_id;
`endif

wire                cpu_led_r;
wire                cpu_led_g;
wire                cpu_led_b;

neorv32_wrapper cpu (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .uart0_rxd_i(uart0_rxd_i),
    .uart0_txd_o(uart0_txd_o),
    .wb_adr_o(wb_adr),
    .wb_dat_i(wb_dat_rd),
    .wb_dat_o(wb_dat_wr),
    .wb_we_o(wb_we),
    .wb_sel_o(wb_sel),
    .wb_stb_o(wb_stb),
    .wb_cyc_o(wb_cyc),
    .wb_ack_i(wb_ack),
    .wb_err_i(wb_err),
    .led_r(cpu_led_r),
    .led_g(cpu_led_g),
    .led_b(cpu_led_b)
);

`ifdef USE_ARB_PUF
puf puf_inst (
    .enable(puf_en),
    .challenge_i(puf_challenge),
    .id_o(puf_id)
);
`endif

always @(negedge wb_clk or negedge rstn_i) begin
    if (~rstn_i) begin
        wb_ack <= 1'b0;
        wb_err <= 1'b0;
    end
`ifdef USE_ARB_PUF
    else if (hits_puf) begin
        wb_ack <= wb_cyc & wb_stb & (~wb_ack);
        wb_err <= 1'b0;
    end
`endif
end

`ifdef USE_ARB_PUF
always @* begin
    if (hits_puf) begin
        case (wb_adr[3:2])
            PUF_REG_CTRL:             wb_dat_rd <= {30'h0, 1'b1, puf_en};
            PUF_REG_CHALLENGE:        wb_dat_rd <= puf_challenge;
            PUF_REG_ID0:              wb_dat_rd <= puf_id[31:0];
            PUF_REG_ID1:              wb_dat_rd <= puf_id[63:32];
            default:                  wb_dat_rd <= DEFAULT_READ_VALUE;
        endcase
    end
end

always @(posedge wb_clk or negedge rstn_i) begin
    if (~rstn_i) begin
        puf_en <= 0;
    end else if (wb_cyc && wb_we && hits_puf) begin
        case (wb_adr[3:2])
            PUF_REG_CTRL: puf_en <= wb_dat_wr[0];
            PUF_REG_CHALLENGE: puf_challenge <= wb_dat_wr;
        endcase
    end
end
`else
// Silence warnings
always @*
    wb_dat_rd <= 32'b0;
`endif

assign led_r = cpu_led_r;
assign led_g = cpu_led_g;
assign led_b = cpu_led_b;

endmodule
