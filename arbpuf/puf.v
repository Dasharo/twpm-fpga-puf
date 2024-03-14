module puf (
    input  wire        enable,
    input  wire [31:0] challenge_i,
    output wire [95:0] id_o
);

wire [95:0] A;
wire [95:0] B;

arbiter arb0 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[0]) );
arbiter arb1 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[1]) );
arbiter arb2 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[2]) );
arbiter arb3 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[3]) );
arbiter arb4 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[4]) );
arbiter arb5 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[5]) );
arbiter arb6 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[6]) );
arbiter arb7 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[7]) );
arbiter arb8 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[8]) );
arbiter arb9 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[9]) );
arbiter arb10 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[10]) );
arbiter arb11 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[11]) );
arbiter arb12 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[12]) );
arbiter arb13 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[13]) );
arbiter arb14 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[14]) );
arbiter arb15 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[15]) );
arbiter arb16 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[16]) );
arbiter arb17 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[17]) );
arbiter arb18 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[18]) );
arbiter arb19 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[19]) );
arbiter arb20 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[20]) );
arbiter arb21 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[21]) );
arbiter arb22 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[22]) );
arbiter arb23 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[23]) );
arbiter arb24 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[24]) );
arbiter arb25 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[25]) );
arbiter arb26 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[26]) );
arbiter arb27 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[27]) );
arbiter arb28 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[28]) );
arbiter arb29 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[29]) );
arbiter arb30 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[30]) );
arbiter arb31 ( .x(enable), .y(enable), .challenge_i(challenge_i), .resp_o(id_o[31]) );

assign id_o[95:32] = 64'bz;

endmodule
