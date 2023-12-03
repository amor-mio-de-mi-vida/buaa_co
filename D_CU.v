//opcode
`define R 6'b000000
`define ori 6'b001101
`define lb 6'b100000 // TODO
`define lh 6'b100001 // TODO
`define lw 6'b100011
`define sb 6'b101000 // TODO
`define sh 6'b101001 // TODO
`define sw 6'b101011
`define beq 6'b000100
`define bne 6'b000101 // TODO
`define lui 6'b001111
`define jal 6'b000011
`define addi 6'b001000 // TODO
`define andi 6'b001100 // TODO
//func
`define add 6'b100000
`define sub 6'b100010
`define and 6'b100100 // TODO
`define or 6'b100101 // TODO
`define slt 6'b101010 // TODO
`define sltu 6'b101011 // TODO
`define mult 6'b011000 // TODO
`define multu 6'b011001 // TODO
`define div 6'b011010 // TODO
`define divu 6'b011011 // TODO
`define mfhi 6'b010000 // TODO
`define mflo 6'b010010 // TODO
`define mthi 6'b010001 // TODO
`define mtlo 6'b010011 // TODO
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
`define mdu_out 2'b11
`define pc_8 2'b10
`define ext_out 2'b01
`define dm_result 2'b00

//AluSrc
`define R_Alu 1'b0
`define I_Alu 1'b1

//ALUCtrl
`define AND 4'b0000
`define OR 4'b0001
`define ADD 4'b0010
`define SUB 4'b0110
`define SLT 4'b0111
`define SLTU 4'b0011

//MDUOp
`define MDU_NOP 4'b0000
`define MDU_MULT 4'b0001
`define MDU_MULTU 4'b0010 
`define MDU_DIV 4'b0011 
`define MDU_DIVU 4'b0100 
`define MDU_MFHI 4'b0101 
`define MDU_MFLO 4'b0110 
`define MDU_MTHI 4'b0111 
`define MDU_MTLO 4'b1000 

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
    output [3:0] MDUOp,
    output MDUStart,
    output Branch,
    output MemWrite,
    output MemtoReg,
    output Jump,
    output Jr
);

    wire [1:0] ALUOp;

    // 决定是否写寄存器
    assign RegWrite = ((opcode == `R && func == `mflo) ||
                       (opcode == `R && func == `mfhi) ||
                       (opcode == `R && func!=`jr) ||
                       (opcode== `R && func!=`R) ||
                       opcode == `ori ||
                       opcode == `addi ||
                       opcode == `andi ||
                       opcode == `lw ||
                       opcode == `lh ||
                       opcode == `lb ||
                       opcode == `lui ||
                       opcode == `jal) ? 1'b1 : 1'b0;

    // 决定按照哪种规则扩展
    assign ExtSel = (opcode == `lui) ? `Lui_ext : 
                    (opcode == `ori || opcode == `andi) ? `Zero_ext : `Sign_ext;

    // 决定写哪个寄存器
    assign RegDst = (opcode ==  `jal) ? `ra :
                    (opcode == `R) ? `rd : `rt;

    // 决定写寄存器的时候写哪个值
    assign WriteSel = ((opcode == `R && func == `mflo) || (opcode == `R && func == `mfhi)) ? `mdu_out :
                      (opcode == `jal) ? `pc_8 :
                      (opcode == `lui) ? `ext_out : `dm_result ;

    // 决定SrcB的选择
    assign ALUSrc = (opcode == `ori ||
                     opcode == `addi ||
                     opcode == `andi ||
                     opcode == `lw ||
                     opcode == `lh ||
                     opcode == `lb ||
                     opcode == `sw ||
                     opcode == `sh || 
                     opcode == `sb) ? `I_Alu : `R_Alu;

    assign ALUOp = (opcode == `ori) ? 2'b11 :
                   (opcode == `R) ? 2'b10 :
                   (opcode == `beq) ? 2'b01 : 2'b00;

    // 决定ALU执行哪种运算
    assign ALUCtrl = (opcode == `R && func == `or) ? `OR : 
                     (opcode == `R && func == `and || opcode == `andi) ? `AND :
                     (opcode == `R && func == `sltu) ? `SLTU :
                     (opcode == `R && func == `slt) ? `SLT : 
                     (ALUOp == 2'b00 || (ALUOp == 2'b10 && func == `add) || opcode == `addi) ? `ADD :
                     (ALUOp == 2'b01 || (ALUOp == 2'b10 && func == `sub)) ?  `SUB : `OR;

    assign MDUOp = (opcode == `R && func == `mult) ? `MDU_MULT :
                   (opcode == `R && func == `multu) ? `MDU_MULTU :
                   (opcode == `R && func == `div) ? `MDU_DIV :
                   (opcode == `R && func == `divu) ? `MDU_DIVU :
                   (opcode == `R && func == `mfhi) ? `MDU_MFHI :
                   (opcode == `R && func == `mflo) ? `MDU_MFLO :
                   (opcode == `R && func == `mthi) ? `MDU_MTHI :
                   (opcode == `R && func == `mtlo) ? `MDU_MTLO :
                   `MDU_NOP;

    assign MDUStart = (opcode == `R && func == `mult || opcode == `R && func == `multu || 
                        opcode == `R && func == `div || opcode == `R && func == `divu) ? 1'b1 : 1'b0;

    assign Branch = (opcode == `beq || opcode == `bne) ? 1'b1 : 1'b0;

    // 决定是否写内存的值
    assign MemWrite = (opcode == `sw || opcode == `sh || opcode == `sb) ? 1'b1 : 1'b0;  

    // 决定load类指令               
    assign MemtoReg = (opcode == `lw || opcode == `lh || opcode == `lb) ? 1'b1 : 1'b0;

    assign Jump = (opcode == `jal ||(opcode == `R && func == `jr)) ? 1'b1 : 1'b0;
    
    assign Jr = (opcode == `R && func == `jr) ? 1'b1 : 1'b0;
 
endmodule