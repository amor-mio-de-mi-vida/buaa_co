module D_REG(
    input clk,
    input [31:0] PC_F,
    input [31:0] Instr_F,
    input WE,
    input reset,
    output reg [31:0] PC_D,
    output reg [31:0] Instr_D
);

    initial begin
        PC_D <= 12288;
        Instr_D <= 0;
    end
    
    always @(posedge clk) begin
        if(reset) begin
            PC_D <= 12288;
            Instr_D <= 0;
        end 

        else begin
                if(WE) begin
                    PC_D <= PC_F;
                    Instr_D <= Instr_F;
                end
            end
        end 

endmodule    