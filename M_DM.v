`define dm_cap 3072
module M_DM(
    input clk,
    input reset,
    input [31:0] ALUOut,
    input [31:0] WriteData,
    input MemWrite,
    input [31:0] pc,
    output [31:0] ReadData
);
    reg [31:0] dm_reg [0:`dm_cap-1];
    integer i;
    
    initial begin
        for(i=0;i<`dm_cap;i=i+1)
            dm_reg[i] = 0; 
    end

    always @(posedge clk) begin
        if(reset)begin
            for(i=0;i<`dm_cap;i=i+1)
            dm_reg[i] <= 0;             
        end

        else begin
            if(MemWrite)begin
                dm_reg[ALUOut[13:2]] <= WriteData; 
                $display("%d@%h: *%h <= %h", $time, pc, ALUOut, WriteData);             
            end
        end
    end

    assign ReadData = dm_reg[ALUOut[13:2]];

endmodule