module E_REG(
    input clk,
    input reset,
    input RegWrite_D,
    input [1:0] RegDst_D,
    input [1:0] WriteSel_D,
    input ALUSrc_D,
    input [3:0] ALUCtrl_D,
    input MemWrite_D,
    input MemtoReg_D,
    input [3:0] MDUOp_D,
    input MDUStart_D,
    //control
    input [31:0] RD1_D,
    input [31:0] RD2_D,
    input [4:0] Rs_D,
    input [4:0] Rt_D,
    input [4:0] Rd_D,
    input [31:0] SignImm_D,
    input [31:0] PC_D,
    input [31:0] Instr_D,
    //data

    output reg RegWrite_E,
    output reg [1:0] RegDst_E,
    output reg [1:0] WriteSel_E,
    output reg ALUSrc_E,
    output reg [3:0] ALUCtrl_E,
    output reg MemWrite_E,
    output reg MemtoReg_E,
    output reg [3:0] MDUOp_E,
    output reg MDUStart_E,
    //control
    output reg [31:0] RD1_E,
    output reg [31:0] RD2_E,
    output reg [4:0] Rs_E,
    output reg [4:0] Rt_E,
    output reg [4:0] Rd_E,
    output reg [31:0] SignImm_E,
    output reg [31:0] PC_E,
    output reg [31:0]Instr_E
    //data
);
    initial begin 
        RegWrite_E <= 0;
        RegDst_E <= 0;
        WriteSel_E <= 0;
        ALUSrc_E <= 0;
        ALUCtrl_E <= 0;
        MemWrite_E <= 0;
        MemtoReg_E <= 0;
        MDUOp_E <= 0;
        MDUStart_E <= 0;
        RD1_E <= 0;
        RD2_E <= 0;
        Rs_E <= 0;
        Rt_E <= 0;
        Rd_E <= 0;
        SignImm_E <= 0;
        PC_E <= 0;
        Instr_E <= 0;
    end
    always @(posedge clk) begin
        if(reset) begin
            RegWrite_E <= 0;
            RegDst_E <= 0;
            WriteSel_E <= 0;
            ALUSrc_E <= 0;
            ALUCtrl_E <= 0;
            MemWrite_E <= 0;
            MemtoReg_E <= 0;
            MDUOp_E <= 0;
            MDUStart_E <= 0;
            RD1_E <= 0;
            RD2_E <= 0;
            Rs_E <= 0;
            Rt_E <= 0;
            Rd_E <= 0;
            SignImm_E <= 0;
            PC_E <= 0;
            Instr_E <= 0;
        end
        else begin
            RegWrite_E <= RegWrite_D;
            RegDst_E <= RegDst_D;
            WriteSel_E <= WriteSel_D;
            ALUSrc_E <= ALUSrc_D;
            ALUCtrl_E <= ALUCtrl_D;
            MemWrite_E <= MemWrite_D;
            MemtoReg_E <= MemtoReg_D;
            MDUOp_E <= MDUOp_D;
            MDUStart_E <= MDUStart_D;
            RD1_E <= RD1_D;
            RD2_E <= RD2_D;
            Rs_E <= Rs_D;
            Rt_E <= Rt_D;
            Rd_E <= Rd_D;
            SignImm_E <= SignImm_D;
            PC_E <= PC_D;
            Instr_E <= Instr_D;
        end
    end


endmodule