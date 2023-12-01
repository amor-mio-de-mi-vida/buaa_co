module D_GRF(
    input clk,
    input reset,
    input WE,
    input [4:0] A1,
    input [4:0] A2,

    input [4:0] A3,
    input [31:0] WD3,
    input [31:0] pc,
    input [31:0] instr,

    output [31:0] RD1,
    output [31:0] RD2
);
    reg [31:0] grf_reg [0:31];
    integer i;

    initial begin
        for(i=0;i<31;i=i+1)
            grf_reg[i] <= 0;
    end

    always @(posedge clk) begin
        if(reset) begin
            for(i=0;i<31;i=i+1)
                grf_reg[i] <= 0;
        end
        else begin
            if(WE && A3) begin
                grf_reg[A3] <= WD3;
                $display("%d@%h: $%d <= %h", $time, pc, A3, WD3);
            end
        end
    end
    
    assign RD1 = (A1 == A3 && A3 && WE) ? WD3 : grf_reg[A1];
    assign RD2 = (A2 == A3 && A3 && WE) ? WD3 : grf_reg[A2];


endmodule