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
    input [3:0] MDUOp_D,
    input [4:0] Rs_E,
    input [4:0] Rt_E,
    input [4:0] Rs_D,
    input [4:0] Rt_D,
    input Rs_D_valid,
    input Rt_D_valid,
    input Jump_D,
    input Jr_D,
    input Branch_D,
    input MDU_busy,
    input MDU_start,

    output [3:0] ForwardAE,
    output [3:0] ForwardBE,
    output [3:0] ForwardAD,
    output [3:0] ForwardBD,
    output FlushE,
    output StallD,
    output StallF
);  
    wire lwstall;
    wire branchstall;
    wire jrstall;

    assign ForwardAE = ((Rs_E != 0) && (Rs_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b11) ? 4'b0111 : //转发M级MDUOut
                       ((Rs_E != 0) && (Rs_E == WriteReg_E) && RegWrite_E===1'b1 && WriteSel_E == 2'b10) ? 4'b0110 : //转发E级PC+8
                       ((Rs_E != 0) && (Rs_E == WriteReg_E) && RegWrite_E===1'b1 && WriteSel_E == 2'b01) ? 4'b0101 : //转发E级SignImm
                       ((Rs_E != 0) && (Rs_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b00) ? 4'b0100 : //转发M级ALUOut
                       ((Rs_E != 0) && (Rs_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b10) ? 4'b0011 : //转发M级PC+8                   
                       ((Rs_E != 0) && (Rs_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b01) ? 4'b0010 : //转发M级SignImm                   
                       ((Rs_E != 0) && (Rs_E == WriteReg_W) && RegWrite_W===1'b1 ) ? 4'b0001 :   // 转发W级Result_W
                        4'b0000;
    
    assign ForwardBE = ((Rt_E != 0) && (Rt_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b11) ? 4'b0111 : //转发M级MDUOut
                       ((Rt_E != 0) && (Rt_E == WriteReg_E) && RegWrite_E===1'b1 && WriteSel_E == 2'b10) ? 4'b0110 : //转发E级PC+8
                       ((Rt_E != 0) && (Rt_E == WriteReg_E) && RegWrite_E===1'b1 && WriteSel_E == 2'b01) ? 4'b0101 : //转发E级SignImm
                       ((Rt_E != 0) && (Rt_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b00) ? 4'b0100 : //转发M级ALUOut
                       ((Rt_E != 0) && (Rt_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b10) ? 4'b0011 : //转发M级PC+8                   
                       ((Rt_E != 0) && (Rt_E == WriteReg_M) && RegWrite_M===1'b1 && WriteSel_M == 2'b01) ? 4'b0010 : //转发M级SignImm                   
                       ((Rt_E != 0) && (Rt_E == WriteReg_W) && RegWrite_W===1'b1 ) ? 4'b0001 :   // 转发W级Result_W
                        4'b0000;
    
    assign ForwardAD = ((Rs_D != 0) && (Rs_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b11) ? 4'b0110 : //转发M级 MDUOut
                       ((Rs_D != 0) && (Rs_D == WriteReg_E) && RegWrite_E && WriteSel_E == 2'b01) ? 4'b0101 : //转发E级 SignImm
                       ((Rs_D != 0) && (Rs_D == WriteReg_E) && RegWrite_E && WriteSel_E == 2'b10) ? 4'b0100 : //转发E级 PC+8
                       ((Rs_D != 0) && (Rs_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b00) ? 4'b0011 : //转发M级 ALUout
                       ((Rs_D != 0) && (Rs_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b10) ? 4'b0010 : //转发M级 PC+8
                       ((Rs_D != 0) && (Rs_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b01) ? 4'b0001 : //转发M级 SignImm
                       4'b0000;

    assign ForwardBD = ((Rt_D != 0) && (Rt_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b11) ? 4'b0110 : //转发M级 MDUOut
                       ((Rt_D != 0) && (Rt_D == WriteReg_E) && RegWrite_E && WriteSel_E == 2'b01) ? 4'b0101 : //转发E级 SignImm
                       ((Rt_D != 0) && (Rt_D == WriteReg_E) && RegWrite_E && WriteSel_E == 2'b10) ? 4'b0100 : //转发E级 PC+8
                       ((Rt_D != 0) && (Rt_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b00) ? 4'b0011 : //转发M级 ALUout
                       ((Rt_D != 0) && (Rt_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b10) ? 4'b0010 : //转发M级 PC+8
                       ((Rt_D != 0) && (Rt_D == WriteReg_M) && RegWrite_M && WriteSel_M == 2'b01) ? 4'b0001 : //转发M级 SignImm
                       4'b0000;
 
    assign lwstall =  (((Rs_D == Rt_E) && Rs_D_valid ) || ((Rt_D == Rt_E) && Rt_D_valid)) && MemtoReg_E;

    assign branchstall = (Branch_D && RegWrite_E && (WriteReg_E == Rs_D || WriteReg_E == Rt_D)) || //解决b类和ALU计算类指令的冲突
                         (Branch_D && MemtoReg_M && (WriteReg_M == Rs_D || WriteReg_M == Rt_D));   //解决b类和load类指令的冲突
    
    assign jrstall = (Jump_D && Jr_D && RegWrite_E && (WriteReg_E == Rs_D)) ||  
                     (Jump_D && Jr_D && MemtoReg_M && (WriteReg_M == Rs_D)) ;

    assign mulstall = (MDU_busy || MDU_start) && MDUOp_D != 0;

    assign StallF = lwstall || branchstall || jrstall || mulstall;
    assign StallD = lwstall || branchstall || jrstall || mulstall;
    assign FlushE = lwstall || branchstall || jrstall || mulstall;
    
endmodule