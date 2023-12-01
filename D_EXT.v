`define sign_ext 2'b00
`define zero_ext 2'b01
`define lui_ext 2'b10 

module D_EXT(
    input [15:0] imm,
    input [1:0] ExtSel,
    output [31:0] Ext_out
);
    assign Ext_out = (ExtSel == `sign_ext)? {{16{imm[15]}},imm} :
                     (ExtSel == `zero_ext)? {{16{1'b0}}, imm} :
                     (ExtSel == `lui_ext)? {imm, {16{1'b0}}} : 0;

endmodule