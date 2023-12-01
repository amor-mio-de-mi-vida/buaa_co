module W_REG(
    input clk,
    input reset,
    input RegWrite_M,
    input MemtoReg_M,
    input [1:0] WriteSel_M,
    input [31:0] ReadData_M,
    input [31:0] ALUOut_M,
    input [4:0] WriteReg_M,
    input [31:0] PC_M,
    input [31:0] SignImm_M,
    input [31:0] Instr_M,

    output reg RegWrite_W,
    output reg MemtoReg_W,
    output reg [1:0] WriteSel_W,
    output reg [31:0] ReadData_W,
    output reg [31:0] ALUOut_W,
    output reg [4:0] WriteReg_W,
    output reg [31:0] SignImm_W,
    output reg [31:0] PC_W,
    output  reg [31:0] Instr_W
);
    initial begin
        RegWrite_W <= 0;
        MemtoReg_W <= 0;
        WriteSel_W <= 0;
        ReadData_W <= 0;
        ALUOut_W <= 0;
        WriteReg_W <= 0;
        SignImm_W <= 0;
        PC_W <= 0;
        Instr_W <= 0;
    end

    always @(posedge clk) begin
        if(reset) begin
            RegWrite_W <= 0;
            MemtoReg_W <= 0;
            WriteSel_W <= 0;
            ReadData_W <= 0;
            ALUOut_W <= 0;
            WriteReg_W <= 0;
            SignImm_W <= 0;
            PC_W <= 0;
            Instr_W <= 0;
        end
        else begin
            RegWrite_W <= RegWrite_M;
            MemtoReg_W <= MemtoReg_M;
            WriteSel_W <= WriteSel_M;
            ReadData_W <= ReadData_M;
            ALUOut_W <= ALUOut_M;
            WriteReg_W <= WriteReg_M;
            SignImm_W <= SignImm_M;
            PC_W <= PC_M;
            Instr_W <= Instr_M;
        end
    end


endmodule