module M_REG(
    input clk,
    input reset,
    input RegWrite_E,
    input MemtoReg_E,
    input MemWrite_E,
    input [1:0] WriteSel_E,
    //control
    input [31:0] ALUOut_E,
    input [31:0] WriteData_E,
    input [4:0] WriteReg_E,
    input [31:0] PC_E,
    input [31:0] SignImm_E,
    input [31:0] Instr_E,
    //data
    output reg RegWrite_M,
    output reg MemtoReg_M,
    output reg MemWrite_M,
    output reg [1:0] WriteSel_M,
    //contorl
    output reg [31:0] ALUOut_M,
    output reg [31:0] WriteData_M,
    output reg [4:0] WriteReg_M,
    output reg [31:0] PC_M,
    output reg [31:0] SignImm_M,
    output reg [31:0] Instr_M
);

  initial begin
    RegWrite_M <= 0;
    MemtoReg_M <= 0;
    MemWrite_M <= 0;
    WriteSel_M <= 0;
    ALUOut_M <= 0;
    WriteData_M <= 0;
    WriteReg_M <= 0;
    PC_M <= 0;
    SignImm_M <= 0;
    Instr_M <= 0;
  end
  always @(posedge clk) begin
    if(reset) begin
      RegWrite_M <= 0;
      MemtoReg_M <= 0;
      MemWrite_M <= 0;
      WriteSel_M <= 0;
      ALUOut_M <= 0;
      WriteData_M <= 0;
      WriteReg_M <= 0;
      PC_M <= 0;
      SignImm_M <= 0;
      Instr_M <= 0;
    end
    else begin
      RegWrite_M <= RegWrite_E;
      MemtoReg_M <= MemtoReg_E;
      MemWrite_M <= MemWrite_E;
      WriteSel_M <= WriteSel_E;
      ALUOut_M <= ALUOut_E;
      WriteData_M <= WriteData_E;
      WriteReg_M <= WriteReg_E;
      PC_M <= PC_E;
      SignImm_M <= SignImm_E;
      Instr_M <= Instr_E;
    end
  end

endmodule