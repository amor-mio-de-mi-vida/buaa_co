`define AND 4'b0000
`define OR 4'b0001
`define ADD 4'b0010
`define SUB 4'b0110
`define SLT 4'b0111
`define SLTU 4'b0011
`define SLL 4'b1000

module E_ALU(
    input [3:0] ALUCtrl,
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [4:0] shamt,
    output [31:0] ALUOut,
    output Zero,
    output Overflow
);

    reg [32:0] temp;
    reg [31:0] result;
    reg flag;

    assign Zero = (ALUOut == 32'b0)?1'b1 : 1'b0;
    assign ALUOut = result;
    assign Overflow = flag;

  always @(*) begin
    case (ALUCtrl)
        
        `AND: begin
          result = SrcA & SrcB;
          flag = 1'b0;
        end

        `OR: begin
          result = SrcA | SrcB;
          flag = 1'b0;
        end

        `ADD: begin
        temp = {SrcA[31], SrcA} + {SrcB[31], SrcB};
        result = SrcA + SrcB;
        if (temp[32] != temp[31])
          flag = 1'b1;
        else  
          flag = 1'b0;
        end
       
        `SUB:  begin
        temp = {SrcA[31], SrcA} - {SrcB[31], SrcB};
        result = SrcA - SrcB;
        if (temp[32] != temp[31])
          flag = 1'b1;
        else
          flag = 1'b0;
        end
        
        `SLT : begin
          result = ($signed(SrcA) < $signed(SrcB)) ? 1 : 0; 
        end

        `SLTU : begin
          result = (SrcA < SrcB) ? 1: 0;
        end

        `SLL : begin
          result = SrcB << shamt;
        end

        default:   begin
            result = 0;
            flag = 0;
        end
    endcase
  end

endmodule