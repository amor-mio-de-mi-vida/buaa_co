`define im_cap 4096
module F_IFU(
    input clk,
    input reset,
    input WE,
    input [31:0] npc,
    output [31:0] Instr_F,
    output reg [31:0] PC_F
);
    reg [31:0] im_reg [0:`im_cap-1];

    initial begin
        PC_F <= 32'h0000_3000;
        $readmemh("code.txt", im_reg);
    end

  always @(posedge clk) begin
    if(reset)
        PC_F <= 32'h0000_3000;
    else
        if(WE)
            PC_F <= npc;   
  end

    assign Instr_F = im_reg[PC_F[15:2]-3072];

endmodule