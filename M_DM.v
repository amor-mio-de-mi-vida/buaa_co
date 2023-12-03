`define dm_cap 3072
`define sb 6'b101000 // TODO
`define sh 6'b101001 // TODO
`define sw 6'b101011
module M_DM(
    input clk,
    input reset,
    input [31:0] ALUOut,
    input [31:0] WriteData,
    input MemWrite,
    input [31:0] pc,
    input [31:0] instr,
    // output [31:0] ReadData
    output [3:0] m_data_byteen,
    output [31:0] m_data_wdata
);
    // reg [31:0] dm_reg [0:`dm_cap-1];
    // integer i;
    
    // initial begin
    //     for(i=0;i<`dm_cap;i=i+1)
    //         dm_reg[i] = 0; 
    // end

    // always @(posedge clk) begin
    //     if(reset)begin
    //         for(i=0;i<`dm_cap;i=i+1)
    //         dm_reg[i] <= 0;             
    //     end

    //     else begin
    //         if(MemWrite)begin
    //             dm_reg[ALUOut[13:2]] <= WriteData; 
    //             $display("%d@%h: *%h <= %h", $time, pc, ALUOut, WriteData);             
    //         end
    //     end
    // end

    // assign ReadData = dm_reg[ALUOut[13:2]];

    assign m_data_byteen = (MemWrite == 1'b0) ? 4'b0000 :
                           (instr[31:26] == `sw) ? 4'b1111 : // sw
                           (instr[31:26] == `sh && ALUOut[1] == 0) ? 4'b0011 : // sh
                           (instr[31:26] == `sh && ALUOut[1] == 1) ? 4'b1100 : // sh
                           (instr[31:26] == `sb && ALUOut[1:0] == 0) ? 4'b0001 : // sb
                           (instr[31:26] == `sb && ALUOut[1:0] == 1) ? 4'b0010 : // sb
                           (instr[31:26] == `sb && ALUOut[1:0] == 2) ? 4'b0100 : // sb
                           (instr[31:26] == `sb && ALUOut[1:0] == 3) ? 4'b1000 : // sb
                           4'b0000;

    assign m_data_wdata = (instr[31:26] == `sw) ? WriteData :
                          (instr[31:26] == `sh) ? {WriteData[15:0],WriteData[15:0]} :
                          (instr[31:26] == `sb) ? {WriteData[7:0],WriteData[7:0],WriteData[7:0],WriteData[7:0]} : WriteData;
endmodule