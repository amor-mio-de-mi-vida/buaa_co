module Hazard(
    input  RegWrite_W,
    input  RegWrite_M,
    input  MemtoReg_M,
    input  RegWrite_E,
    input  MemtoReg_E,

    input [4:0] WriteReg_W,
    input [4:0] WriteReg_M,
    input [4:0] WriteReg_E,
    input [1:0] WriteSel_E,
    input [1:0] WriteSel_M,
    input [4:0] Rs_E,
    input [4:0] Rt_E,
    input [4:0] Rs_D,
    input [4:0] Rt_D,
    input Rs_D_valid,
    input Rt_D_valid,
    input Jump_D,
    input Jr_D,
    input Branch_D,

    output [2:0] ForwardAE,
    output [2:0] ForwardBE,
    output [2:0] ForwardAD,
    output [2:0] ForwardBD,
    output FlushE,
    output StallD,
    output StallF
);  
    wire lwstall;
    wire branchstall;
    wire jrstall;

    assign ForwardAE = ((Rs_E != 0) && (Rs_E == WriteReg_E) && RegWrite_E===1'b1 && WriteSel_E == 2'b10) ? 3'b110 : //转发E级PC+8
                       ((Rs_E != 0) && (Rs_E == WriteReg_E) && RegWrite_E===1'b1 && WriteSel_E == 2'b01) ? 3'b101 : //转发E级SignImm
                       ((Rs_E != 0) && (Rs_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b00) ? 3'b100 : //转发M级ALUOut
                       ((Rs_E != 0) && (Rs_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b10) ? 3'b011 : //转发M级PC+8                   
                       ((Rs_E != 0) && (Rs_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b01) ? 3'b010 : //转发M级SignImm                   
                       ((Rs_E != 0) && (Rs_E == WriteReg_W) && RegWrite_W===1'b1 ) ? 3'b001 :   // 转发W级Result_W
                        3'b000;
    
    assign ForwardBE = ((Rt_E != 0) && (Rt_E == WriteReg_E) && RegWrite_E===1'b1 && WriteSel_E == 2'b10) ? 3'b110 : //转发E级PC+8
                       ((Rt_E != 0) && (Rt_E == WriteReg_E) && RegWrite_E===1'b1 && WriteSel_E == 2'b01) ? 3'b101 : //转发E级SignImm
                       ((Rt_E != 0) && (Rt_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b00) ? 3'b100 : //转发M级ALUOut
                       ((Rt_E != 0) && (Rt_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b10) ? 3'b011 : //转发M级PC+8                   
                       ((Rt_E != 0) && (Rt_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b01) ? 3'b010 : //转发M级SignImm                   
                       ((Rt_E != 0) && (Rt_E == WriteReg_W) && RegWrite_W===1'b1 ) ? 3'b001 :   // 转发W级Result_W
                        3'b000;
    
    assign ForwardAD = ((Rs_D != 0) && (Rs_D == WriteReg_E) && RegWrite_E && WriteSel_E == 2'b01) ? 3'b101 : //转发E级 SignImm
                       ((Rs_D != 0) && (Rs_D == WriteReg_E) && RegWrite_E && WriteSel_E == 2'b10) ? 3'b100 : //转发E级 PC+8
                       ((Rs_D != 0) && (Rs_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b00) ? 3'b011 : //转发M级 ALUout
                       ((Rs_D != 0) && (Rs_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b10) ? 3'b010 : //转发M级 PC+8
                       ((Rs_D != 0) && (Rs_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b01) ? 3'b001 : //转发M级 SignImm
                       3'b000;

    assign ForwardBD = ((Rt_D != 0) && (Rt_D == WriteReg_E) && RegWrite_E && WriteSel_E == 2'b01) ? 3'b101 : //转发E级 SignImm
                       ((Rt_D != 0) && (Rt_D == WriteReg_E) && RegWrite_E && WriteSel_E == 2'b10) ? 3'b100 : //转发E级 PC+8
                       ((Rt_D != 0) && (Rt_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b00) ? 3'b011 : //转发M级 ALUout
                       ((Rt_D != 0) && (Rt_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b10) ? 3'b010 : //转发M级 PC+8
                       ((Rt_D != 0) && (Rt_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b01) ? 3'b001 : //转发M级 SignImm
                       3'b000;
 
    assign lwstall =  (((Rs_D == Rt_E) && Rs_D_valid ) || ((Rt_D == Rt_E) && Rt_D_valid)) && MemtoReg_E;

    assign branchstall = (Branch_D && RegWrite_E && (WriteReg_E == Rs_D || WriteReg_E == Rt_D)) || //解决beq类和ALU计算类指令的冲突
                         (Branch_D && MemtoReg_M && (WriteReg_M == Rs_D || WriteReg_M == Rt_D));   //解决beq类和lw类指令的冲突
    
    assign jrstall = (Jump_D && Jr_D && RegWrite_E && (WriteReg_E == Rs_D)) ||  
                     (Jump_D && Jr_D && MemtoReg_M && (WriteReg_M == Rs_D)) ;

    assign StallF = lwstall || branchstall || jrstall;
    assign StallD = lwstall || branchstall || jrstall;
    assign FlushE = lwstall || branchstall || jrstall;
    
endmodule