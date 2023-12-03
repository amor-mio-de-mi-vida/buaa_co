`define lw 6'b100011
`define lh 6'b100001 
`define lb 6'b100000

module M_EXT(
    input [31:0] readAddr,
    input [31:0] readData,
    input [31:0] instr,
    input [31:0] pc,
    output [31:0] out
);

    assign out = (instr[31:26] == `lw) ? readData :
                 (instr[31:26] == `lh && readAddr[1] == 0) ? {{16{readData[15]}}, readData[15:0]} :
                 (instr[31:26] == `lh && readAddr[1] == 1) ? {{16{readData[31]}}, readData[31:16]} :
                 (instr[31:26] == `lb && readAddr[1:0] == 0) ? {{24{readData[7]}}, readData[7:0]} :
                 (instr[31:26] == `lb && readAddr[1:0] == 1) ? {{24{readData[15]}}, readData[15:8]} :
                 (instr[31:26] == `lb && readAddr[1:0] == 2) ? {{24{readData[23]}}, readData[23:16]} :
                 (instr[31:26] == `lb && readAddr[1:0] == 3) ? {{24{readData[31]}}, readData[31:24]} :
                 0;
endmodule