(* keep_hierarchy = "yes" *)
module switch(
    input  wire       x,
    input  wire       y,
    input  wire       challenge,
    output wire       w,
    output wire       z
);

// mux2x1 upper(.a(in[0]), .b(in[1]), .sel(challenge), .out(out[0]));
// mux2x1 lower(.a(in[1]), .b(in[0]), .sel(challenge), .out(out[1]));

wire w1, w2;
wire z1, z2;

mux2x1 upper(x, y, challenge, w1);
mux2x1 lower(y, x, challenge, z1);

not n1(w2, w1);
not n2(w, w2);
not n7(z2, z1);
not n8(z, z2);

endmodule
