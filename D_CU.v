//opcode
`define R 6'b000000
`define ori 6'b001101
`define lw 6'b100011
`define sw 6'b101011
`define beq 6'b000100
`define lui 6'b001111
`define jal 6'b000011
//func
`define add 6'b100000
`define sub 6'b100010
`define jr 6'b001000

//ExtSel
`define Sign_ext 2'b00
`define Zero_ext 2'b01
`define Lui_ext 2'b10

//RegDst
`define ra 2'b10
`define rd 2'b01
`define rt 2'b00

//WriteSel 
`define pc_8 2'b10
`define ext_out 2'b01
`define dm_result 2'b00

//AluSrc
`define R_Alu 1'b0
`define I_Alu 1'b1

//ALUCtrl
`define ADD 4'b0010
`define SUB 4'b0110
`define OR 4'b0001

module D_CU(
    input [5:0] opcode,
    input [5:0] func,
    input [31:0] instr,
    output RegWrite,
    output [1:0] ExtSel,
    output [1:0] RegDst,
    output [1:0] WriteSel,
    output ALUSrc,
    output [3:0] ALUCtrl,
    output Branch,
    output MemWrite,
    output MemtoReg,
    output Jump,
    output Jr
);

    wire [1:0] ALUOp;

    assign RegWrite = ((opcode == `R && func!=`jr) ||
                        (opcode== `R && func!=`R) ||
                        opcode == `ori ||
                       opcode == `lw ||
                       opcode == `lui ||
                       opcode == `jal) ? 1'b1 : 1'b0;

    assign ExtSel = (opcode == `lui) ? `Lui_ext : 
                    (opcode == `ori) ? `Zero_ext : `Sign_ext;

    assign RegDst = (opcode ==  `jal) ? `ra :
                    (opcode == `R) ? `rd : `rt;

    assign WriteSel = (opcode == `jal) ? `pc_8 :
                      (opcode == `lui) ? `ext_out : `dm_result ;

    assign ALUSrc = (opcode == `ori ||
                     opcode == `lw ||
                     opcode == `sw) ? `I_Alu : `R_Alu;

    assign ALUOp = (opcode == `ori) ? 2'b11 :
                   (opcode == `R) ? 2'b10 :
                   (opcode == `beq) ? 2'b01 : 2'b00;

    assign ALUCtrl = (ALUOp == 2'b00 || (ALUOp == 2'b10 && func == `add)) ? `ADD :
                     (ALUOp == 2'b01 || (ALUOp == 2'b10 && func == `sub)) ?  `SUB : `OR;

    assign Branch = (opcode == `beq) ? 1'b1 : 1'b0;

    assign MemWrite = (opcode == `sw) ? 1'b1 : 1'b0;  
                   
    assign MemtoReg = (opcode == `lw) ? 1'b1 : 1'b0;

    assign Jump = (opcode == `jal ||(opcode == `R && func == `jr)) ? 1'b1 : 1'b0;
    
    assign Jr = (opcode == `R && func == `jr) ? 1'b1 : 1'b0;
 
endmodule