(* dont_touch = "true" *)
module mux2x1(
    input  wire a,
    input  wire b,
    input  wire sel,
    output wire out
);

// assign out = sel ? b : a;

wire sn, sa, sb;

not n1(sn, sel);
and a1(sa, a, sel);
and a2(sb, b, sn);
or o1(out, sa, sb);

endmodule
