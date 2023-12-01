module D_NPC(
    input reset,
    input [31:0] PC_D,
    input [31:0] PC_F,
    input Branch_or_not,
    input [31:0] instr,
    input [31:0] Ext_out,
    input [31:0] RD1_D,
    input Jump,
    input Jr,
    input Stall,
    output [31:0] NPC_D
);
    reg [31:0] npc;  
    
    assign NPC_D = (Branch_or_not==0&&Jump==0 && !Stall) ? PC_F + 4 :  // 非跳转的正常情况
                   (Branch_or_not==1&&Jump==0 && !Stall) ? PC_D + 4 + (Ext_out << 2) :   // 类beq的I型指令  
                   (Jump == 1 && Jr == 0 && !Stall) ? {PC_D[31:28],instr[25:0],1'b0,1'b0} :   // j型指令
                   (Jump == 1 && Jr == 1 && !Stall) ? RD1_D   // jr指令
                   : PC_F - 4;

endmodule