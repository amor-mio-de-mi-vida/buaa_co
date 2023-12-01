`define beq 6'b000100
`define bgez 6'b000001
`define bgtz 6'b000111
`define blez 6'b000110
`define bltz 6'b000001
`define bne 6'b000101
//opcode
`define Bgez 000001
`define Bltz 000000

module D_CMP(
    input [31:0] left,
    input [31:0] right,
    input [31:0] instr,
    input Branch,
    output Branch_or_not
);

    assign Branch_or_not = (Branch && left==right) ? 1'b1 : 1'b0;

endmodule