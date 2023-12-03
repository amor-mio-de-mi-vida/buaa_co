`include "./D_CMP.v"
`include "./D_NPC.v"
`include "./D_EXT.v"
`include "./D_GRF.v"
`include "./D_CU.v"

module D(
    input clk,
    input reset,
    input [3:0] ForwardAD,
    input [3:0] ForwardBD,
    input Stall,
    input [31:0] ALUOut_M,
    input [31:0] MDUOut_M,
    input [31:0] Result_W,
    input [31:0] Instr_D,
    input [31:0] PC_D,
    input [31:0] PC_E,
    input [31:0] PC_F,
    input [31:0] PC_M,
    
    input [31:0] PC_W,
    input RegWrite_W,
    input [4:0] WriteReg_W,
    input [31:0] SignImm_E,
    input [31:0] SignImm_M,

    output RegWrite_D,
    output MemtoReg_D,
    output MemWrite_D,
    output [3:0] ALUCtrl_D,
    output [3:0] MDUOp_D,
    output MDUStart_D,
    output ALUSrc_D,
    output [1:0] RegDst_D,
    output [1:0] WriteSel_D,
    output [31:0] npc,

    output [31:0] RD1_D,
    output [31:0] RD2_D,
    output [4:0] Rs_D,
    output [4:0] Rt_D,
    output [4:0] Rd_D,
    output [31:0] SignImm_D,
    output Branch_or_not,
    output Branch_D,
    output Jump_D,
    output Jr_D
);
    wire Branch;
    wire [31:0] RD1_D;
    wire [31:0] RD2_D;
    wire [4:0] Rs_D;
    wire [4:0] Rt_D;
    wire [4:0] Rd_D;
    wire [31:0] SignImm_D;
    wire Jump;
    wire Jr;
    wire RegWrite; 
    wire [31:0] Ext_out;
    
    assign RD1_D = left;
    assign RD2_D = right;
    assign Rs_D = Instr_D[25:21];
    assign Rt_D = Instr_D[20:16];
    assign Rd_D = Instr_D[15:11];
    assign SignImm_D = Ext_out;

    assign npc = NPC_D;
    assign RegWrite_D = RegWrite;
    assign MemtoReg_D = MemtoReg;
    assign MemWrite_D = MemWrite;
    assign ALUCtrl_D = ALUCtrl;
    assign MDUOp_D = MDUOp;
    assign MDUStart_D = MDUStart;
    assign ALUSrc_D = ALUSrc;
    assign RegDst_D = RegDst;
    assign WriteSel_D = WriteSel;
    assign Jump_D = Jump;
    assign Jr_D = Jr;
    assign Branch_D = Branch;

/////////////////////   CMP   //////////////////////
    wire Branch_or_not;
    wire [31:0] left;
    wire [31:0] right;
    
    assign left = (ForwardAD == 4'b0110) ? MDUOut_M :
                  (ForwardAD == 4'b0101) ? SignImm_E : 
                  (ForwardAD == 4'b0100) ? PC_E + 8 : 
                  (ForwardAD == 4'b0011) ? ALUOut_M : 
                  (ForwardAD == 4'b0010) ? PC_M + 8: 
                  (ForwardAD == 4'b0001) ? SignImm_M : RD1;

    assign right =(ForwardBD == 4'b0110) ? MDUOut_M :
                  (ForwardBD == 4'b0101) ? SignImm_E : 
                  (ForwardBD == 4'b0100) ? PC_E + 8 : 
                  (ForwardBD == 4'b0011) ? ALUOut_M : 
                  (ForwardBD == 4'b0010) ? PC_M + 8: 
                  (ForwardBD == 4'b0001) ? SignImm_M : RD2;

D_CMP  u_D_CMP (
    .left                    ( left           [31:0] ),
    .right                   ( right          [31:0] ),
    .instr                   ( Instr_D        [31:0] ),
    .Branch                  ( Branch                ),

    .Branch_or_not           ( Branch_or_not         )
);

/////////////////////   NPC   ////////////////////////
    wire [31:0] NPC_D;
D_NPC  u_D_NPC (
    .reset                   ( reset                 ),
    .PC_D                    ( PC_D           [31:0] ),
    .PC_F                    ( PC_F           [31:0] ),
    .Branch_or_not           ( Branch_or_not         ),
    .instr                   ( Instr_D        [31:0] ),
    .Ext_out                 ( Ext_out        [31:0] ),
    .RD1_D                   ( left           [31:0] ),
    .Jump                    ( Jump                  ),
    .Jr                      ( Jr                    ),
    .Stall                   ( Stall                 ),
    
    .NPC_D                   ( NPC_D          [31:0] )
);

/////////////////////   EXT   //////////////////////////
   wire [15:0] imm;
   assign imm = Instr_D[15:0];
D_EXT  u_D_EXT (
    .imm                     ( imm      [15:0] ),
    .ExtSel                  ( ExtSel   [1:0]),

    .Ext_out                 ( Ext_out  [31:0] )
);
/////////////////////   GRF   ///////////////////////////
    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [4:0] A1;
    wire [4:0] A2;
    wire [4:0] A3;
    wire [31:0] WD3;
    assign A1 = Instr_D[25:21];
    assign A2 = Instr_D[20:16];
    assign A3 = WriteReg_W;
    assign WD3 = Result_W;    

D_GRF  u_D_GRF (
    .clk                     ( clk           ),
    .reset                   ( reset         ),
    .WE                      ( RegWrite_W    ),
    .A1                      ( A1     [4:0]  ),
    .A2                      ( A2     [4:0]  ),
    .A3                      ( A3     [4:0]  ),
    .WD3                     ( WD3    [31:0] ),
    .pc                      ( PC_W   [31:0] ),
    .instr                   ( Instr_D[31:0] ),

    .RD1                     ( RD1    [31:0] ),
    .RD2                     ( RD2    [31:0] )
);
/////////////////////   CU   ////////////////////////////
    wire [1:0] ExtSel;
    wire [1:0] RegDst;
    wire [1:0] WriteSel;
    wire ALUSrc;
    wire [3:0] ALUCtrl;
    wire [3:0] MDUOp;
    wire MDUStart;
    wire MemWrite;
    wire  MemtoReg;


    wire [5:0] opcode;
    wire [5:0] func;
    assign opcode = Instr_D[31:26];
    assign func = Instr_D[5:0];

D_CU  u_D_CU (
    .opcode                  ( opcode    [5:0] ),
    .func                    ( func      [5:0] ),
    .instr                   ( Instr_D   [31:0]),

    .RegWrite                ( RegWrite        ),
    .ExtSel                  ( ExtSel    [1:0] ),
    .RegDst                  ( RegDst    [1:0] ),
    .WriteSel                ( WriteSel  [1:0] ),
    .ALUSrc                  ( ALUSrc          ),
    .ALUCtrl                 ( ALUCtrl   [3:0] ),
    .MDUOp                   ( MDUOp     [3:0] ),
    .MDUStart                ( MDUStart        ),
    .Branch                  ( Branch          ),
    .MemWrite                ( MemWrite        ),
    .MemtoReg                ( MemtoReg        ),
    .Jump                    ( Jump            ),
    .Jr                      ( Jr              )
);

//////////////////////////////////////////////////////////
endmodule