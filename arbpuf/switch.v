(* keep_hierarchy = "yes" *)
module switch(
    input  wire       x,
    input  wire       y,
    input  wire       challenge,
    output wire       w,
    output wire       z
);

mux2x1 upper(x, y, challenge, w);
mux2x1 lower(y, x, challenge, z);

endmodule
