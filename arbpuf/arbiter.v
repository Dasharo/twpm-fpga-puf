(* keep_hierarchy = "yes" *)
module arbiter (
    input  wire        x,
    input  wire        y,
    input  wire [31:0] challenge_i,
    output wire        resp_o
);

    wire [31:0] wa;
    wire [31:0] wb;
    wire        q_n;

    switch a0(x, y, challenge_i[0], wa[0], wb[0]);
    switch a1(wa[0], wb[0], challenge_i[1], wa[1], wb[1]);
    switch a2(wa[1], wb[1], challenge_i[2], wa[2], wb[2]);
    switch a3(wa[2], wb[2], challenge_i[3], wa[3], wb[3]);
    switch a4(wa[3], wb[3], challenge_i[4], wa[4], wb[4]);
    switch a5(wa[4], wb[4], challenge_i[5], wa[5], wb[5]);
    switch a6(wa[5], wb[5], challenge_i[6], wa[6], wb[6]);
    switch a7(wa[6], wb[6], challenge_i[7], wa[7], wb[7]);
    switch a8(wa[7], wb[7], challenge_i[8], wa[8], wb[8]);
    switch a9(wa[8], wb[8], challenge_i[9], wa[9], wb[9]);
    switch a10(wa[9], wb[9], challenge_i[10], wa[10], wb[10]);
    switch a11(wa[10], wb[10], challenge_i[11], wa[11], wb[11]);
    switch a12(wa[11], wb[11], challenge_i[12], wa[12], wb[12]);
    switch a13(wa[12], wb[12], challenge_i[13], wa[13], wb[13]);
    switch a14(wa[13], wb[13], challenge_i[14], wa[14], wb[14]);
    switch a15(wa[14], wb[14], challenge_i[15], wa[15], wb[15]);
    switch a16(wa[15], wb[15], challenge_i[16], wa[16], wb[16]);
    switch a17(wa[16], wb[16], challenge_i[17], wa[17], wb[17]);
    switch a18(wa[17], wb[17], challenge_i[18], wa[18], wb[18]);
    switch a19(wa[18], wb[18], challenge_i[19], wa[19], wb[19]);
    switch a20(wa[19], wb[19], challenge_i[20], wa[20], wb[20]);
    switch a21(wa[20], wb[20], challenge_i[21], wa[21], wb[21]);
    switch a22(wa[21], wb[21], challenge_i[22], wa[22], wb[22]);
    switch a23(wa[22], wb[22], challenge_i[23], wa[23], wb[23]);
    switch a24(wa[23], wb[23], challenge_i[24], wa[24], wb[24]);
    switch a25(wa[24], wb[24], challenge_i[25], wa[25], wb[25]);
    switch a26(wa[25], wb[25], challenge_i[26], wa[26], wb[26]);
    switch a27(wa[26], wb[26], challenge_i[27], wa[27], wb[27]);
    switch a28(wa[27], wb[27], challenge_i[28], wa[28], wb[28]);
    switch a29(wa[28], wb[28], challenge_i[29], wa[29], wb[29]);
    switch a30(wa[29], wb[29], challenge_i[30], wa[30], wb[30]);
    switch a31(wa[30], wb[30], challenge_i[31], wa[31], wb[31]);

    LUT4 #(.init(16'b0000000000000111)) nand0(
        .Z(resp_o),
        .A(wa[31]),
        .B(q_n),
        .C(1'b0),
        .D(1'b0)
    );

    LUT4 #(.init(16'b0000000000000111)) nand1(
        .Z(q_n),
        .A(wb[31]),
        .B(resp_o),
        .C(1'b0),
        .D(1'b0)
    );

endmodule
