`define MDU_NOP 4'b0000
`define MDU_MULT 4'b0001
`define MDU_MULTU 4'b0010 
`define MDU_DIV 4'b0011 
`define MDU_DIVU 4'b0100 
`define MDU_MFHI 4'b0101 
`define MDU_MFLO 4'b0110 
`define MDU_MTHI 4'b0111 
`define MDU_MTLO 4'b1000 

module E_MDU(
    input clk,
    input reset,
    input start,
    input [31:0] A,
    input [31:0] B,
    input [3:0] MDUOp,

    output [31:0] out,
    output reg busy
);

    reg [31:0] HI;
    reg [31:0] LO;
    reg [31:0] HI_temp;
    reg [31:0] LO_temp;
    reg [4:0] max;
    reg [4:0] cnt;

always @(posedge clk) begin
    if (reset) begin
        HI <= 0;
        LO <= 0;
        HI_temp <= 0;
        LO_temp <= 0;
    end
    else if (busy == 0) begin // the first circle
        case (MDUOp)
            `MDU_MTHI: HI <= A;
            `MDU_MTLO: LO <= A;
            `MDU_MULT : begin
                {HI_temp, LO_temp} <= $signed(A) * $signed(B);
                max <= 5;
            end
            `MDU_MULTU : begin
                {HI_temp, LO_temp} <= A * B;
                max <= 5;
            end
            `MDU_DIV: begin
                {HI_temp, LO_temp} <= {$signed(A) % $signed(B), $signed(A) / $signed(B)};
                max <= 10;
            end
            `MDU_DIVU: begin
                {HI_temp, LO_temp} <= {A % B, A / B};
                max <= 10;
            end 
        endcase
    end
    else begin 
        if (cnt == max - 1) begin
            HI <= HI_temp;
            LO <= LO_temp;
            // $display("%d MDU over!! HI is %d, LO is %d", $time, HI, LO);
        end
        else begin
            HI <= HI;
            LO <= LO;
        end
    end
end

// cnt and busy
always @(posedge clk) begin
    if (reset) begin
        cnt <= 0;
        busy <= 0;
    end
    else if (start) begin
        busy <= 1'b1;
    end 
    else if (~start && busy) begin
        if (cnt == max - 1) begin
            cnt <= 0;
            busy <= 0;
        end
        else 
            cnt <= cnt + 1;
    end
end

    assign out = (MDUOp == `MDU_MFHI) ? HI :
                 (MDUOp == `MDU_MFLO) ? LO : 0;

endmodule