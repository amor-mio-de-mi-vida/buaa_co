`include "./Hazard.v"
`include "./F_IFU.v"
`include "./D_REG.v"
`include "./D.v"
`include "./E_REG.v"
`include "./E_ALU.v"
`include "./M_REG.v"
`include "./M_DM.v"
`include "./W_REG.v"

module mips(
    input clk,
    input reset
);
    
////////////////////////////////   冲突处理   ///////////////////////////////////
    wire [2:0] ForwardAE;
    wire [2:0] ForwardAD;
    wire [2:0] ForwardBE;
    wire [2:0] ForwardBD;
    wire FlushE;
    wire StallD;
    wire StallF;
    wire [31:0] npc_D;

Hazard  u_Hazard (
    .RegWrite_W              ( RegWrite_W        ),
    .RegWrite_M              ( RegWrite_M        ),
    .MemtoReg_M              ( MemtoReg_M        ),
    .RegWrite_E              ( RegWrite_E        ),
    .MemtoReg_E              ( MemtoReg_E        ),
    .WriteReg_W              ( WriteReg_W  [4:0] ),
    .WriteReg_M              ( WriteReg_M  [4:0] ),
    .WriteReg_E              ( WriteReg_E  [4:0] ),
    .WriteSel_E              ( WriteSel_E  [1:0] ),
    .WriteSel_M              ( WriteSel_M  [1:0] ),
    .Rs_E                    ( Rs_E        [4:0] ),
    .Rt_E                    ( Rt_E        [4:0] ),
    .Rs_D                    ( Rs_D        [4:0] ),
    .Rt_D                    ( Rt_D        [4:0] ),
    .Rs_D_valid              ( Rs_D_valid        ),
    .Rt_D_valid              ( Rt_D_valid        ),
    .Jump_D                  ( Jump_D            ),
    .Jr_D                    ( Jr_D              ),
    .Branch_D                ( Branch_D          ),

    .ForwardAE               ( ForwardAE   [2:0] ),
    .ForwardBE               ( ForwardBE   [2:0] ),
    .ForwardAD               ( ForwardAD   [2:0] ),
    .ForwardBD               ( ForwardBD   [2:0] ),
    .FlushE                  ( FlushE            ),
    .StallD                  ( StallD            ),
    .StallF                  ( StallF            )
);

////////////////////////////////   F级   ///////////////////////////////////
    wire WE_F;
    wire [31:0] Instr_F;
    wire [31:0] PC_F;
    assign WE_F = !StallF;

F_IFU  u_F_IFU (
    .clk                     ( clk             ),
    .reset                   ( reset           ),
    .WE                      ( WE_F            ),
    .npc                     ( npc_D    [31:0] ),

    .Instr_F                 ( Instr_F  [31:0] ),
    .PC_F                    ( PC_F     [31:0] )
);
///////////////////////////////   D级   ////////////////////////////////////
    wire WE_D;
    wire [31:0] PC_D;
    wire [31:0] Instr_D;


    assign WE_D = !StallD;
    assign Rs_D_valid = (Instr_D[31:26]==`lui || Instr_D[31:26]==`jal) ? 1'b0 : 1'b1 ;
    assign Rt_D_valid = ((Instr_D[31:26]==`R &&Instr_D[5:0]!=`jr) || Instr_D[31:26]==`beq || Instr_D[31:26]==`sw)? 1'b1 : 1'b0 ;

D_REG  u_D_REG (
    .clk                     ( clk             ),
    .PC_F                    ( PC_F     [31:0] ),
    .Instr_F                 ( Instr_F  [31:0] ),
    .WE                      ( WE_D            ),
    .reset                   ( reset           ),
                        
    .PC_D                    ( PC_D     [31:0] ),
    .Instr_D                 ( Instr_D  [31:0] )
);

    wire RegWrite_D;
    wire MemtoReg_D;
    wire MemWrite_D;
    wire [3:0] ALUCtrl_D;
    wire ALUSrc_D;
    wire [1:0] RegDst_D;
    wire [1:0] WriteSel_D;
    wire [31:0] RD1_D;
    wire [31:0] RD2_D;
    wire [4:0] Rs_D;
    wire [4:0] Rt_D;
    wire [4:0] Rd_D;
    wire [31:0] SignImm_D;
    wire Branch_or_not;

D  u_D (
    .clk                     ( clk                ),
    .reset                   ( reset              ),
    .ForwardAD               ( ForwardAD   [2:0]  ),
    .ForwardBD               ( ForwardBD   [2:0]  ),
    .Stall                   ( StallD             ),
    .ALUOut_M                ( ALUOut_M    [31:0] ),
    .Result_W                ( Result_W    [31:0] ),
    .Instr_D                 ( Instr_D     [31:0] ),
    .PC_D                    ( PC_D        [31:0] ),
    .PC_E                    ( PC_E        [31:0] ),
    .PC_F                    ( PC_F        [31:0] ),
    .PC_M                    ( PC_M        [31:0] ),
    .PC_W                    ( PC_W        [31:0] ),
    .RegWrite_W              ( RegWrite_W         ),
    .WriteReg_W              ( WriteReg_W  [4:0]  ),
    .SignImm_E               ( SignImm_E   [31:0] ),
    .SignImm_M               ( SignImm_M   [31:0] ),

    .RegWrite_D              ( RegWrite_D         ),
    .MemtoReg_D              ( MemtoReg_D         ),
    .MemWrite_D              ( MemWrite_D         ),
    .ALUCtrl_D               ( ALUCtrl_D   [3:0]  ),
    .ALUSrc_D                ( ALUSrc_D           ),
    .RegDst_D                ( RegDst_D    [1:0]  ),
    .WriteSel_D              ( WriteSel_D  [1:0]  ),
    .npc                     ( npc_D       [31:0] ),
    .RD1_D                   ( RD1_D       [31:0] ),
    .RD2_D                   ( RD2_D       [31:0] ),
    .Rs_D                    ( Rs_D        [4:0]  ),
    .Rt_D                    ( Rt_D        [4:0]  ),
    .Rd_D                    ( Rd_D        [4:0]  ),
    .SignImm_D               ( SignImm_D   [31:0] ),
    .Branch_or_not           ( Branch_or_not      ),
    .Branch_D                ( Branch_D           ),
    .Jump_D                  ( Jump_D             ),
    .Jr_D                    ( Jr_D               )    
);
////////////////////////////////   E级   ///////////////////////////////
    wire [1:0] RegDst_E;
    wire [1:0] WriteSel_E;
    wire ALUSrc_E;
    wire [3:0] ALUCtrl_E;
    wire MemWrite_E;
    wire [31:0] RD1_E;
    wire [31:0] RD2_E;
    wire [4:0] Rs_E;
    wire [4:0] Rt_E;
    wire [4:0] Rd_E;
    wire [31:0] SignImm_E;
    wire [31:0] PC_E;
    wire [31:0] Instr_E;
    wire reset_E;
    assign reset_E = reset || FlushE;

E_REG  u_E_REG (
    .clk                     ( clk                ),
    .reset                   ( reset_E            ),
    .RegWrite_D              ( RegWrite_D         ),
    .RegDst_D                ( RegDst_D    [1:0]  ),
    .WriteSel_D              ( WriteSel_D  [1:0]  ),
    .ALUSrc_D                ( ALUSrc_D           ),
    .ALUCtrl_D               ( ALUCtrl_D   [3:0]  ),
    .MemWrite_D              ( MemWrite_D         ),
    .MemtoReg_D              ( MemtoReg_D         ),
    .RD1_D                   ( RD1_D       [31:0] ),
    .RD2_D                   ( RD2_D       [31:0] ),
    .Rs_D                    ( Rs_D        [4:0]  ),
    .Rt_D                    ( Rt_D        [4:0]  ),
    .Rd_D                    ( Rd_D        [4:0]  ),
    .SignImm_D               ( SignImm_D   [31:0] ),
    .PC_D                    ( PC_D        [31:0] ),
    .Instr_D                 ( Instr_D     [31:0] ),

    .RegWrite_E              ( RegWrite_E         ),
    .RegDst_E                ( RegDst_E    [1:0]  ),
    .WriteSel_E              ( WriteSel_E  [1:0]  ),
    .ALUSrc_E                ( ALUSrc_E           ),
    .ALUCtrl_E               ( ALUCtrl_E   [3:0]  ),
    .MemWrite_E              ( MemWrite_E         ),
    .MemtoReg_E              ( MemtoReg_E         ),
    .RD1_E                   ( RD1_E       [31:0] ),
    .RD2_E                   ( RD2_E       [31:0] ),
    .Rs_E                    ( Rs_E        [4:0] ),
    .Rt_E                    ( Rt_E        [4:0] ),
    .Rd_E                    ( Rd_E        [4:0] ),
    .SignImm_E               ( SignImm_E   [31:0] ),
    .PC_E                    ( PC_E        [31:0] ),
    .Instr_E                 ( Instr_E     [31:0] )
);

    wire [31:0] ALUOut_E;
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [31:0] WriteData_E;
    wire [4:0] WriteReg_E;

    assign SrcA = (ForwardAE == 3'b110) ? PC_E + 8: 
                  (ForwardAE == 3'b101) ? SignImm_E : 
                  (ForwardAE == 3'b100) ? ALUOut_M :
                  (ForwardAE == 3'b011) ? PC_M + 8 : 
                  (ForwardAE == 3'b010) ? SignImm_M : 
                  (ForwardAE == 3'b001) ? Result_W :  RD1_E;

    assign WriteData_E = (ForwardBE == 3'b110) ? PC_E + 8: 
                         (ForwardBE == 3'b101) ? SignImm_E : 
                         (ForwardBE == 3'b100) ? ALUOut_M :
                         (ForwardBE == 3'b011) ? PC_M + 8 : 
                         (ForwardBE == 3'b010) ? SignImm_M : 
                         (ForwardBE == 3'b001) ? Result_W :  RD2_E;

    assign SrcB = (ALUSrc_E == 1'b0) ? WriteData_E : SignImm_E;

    assign WriteReg_E = (RegDst_E == 2'b00) ? Rt_E :
                        (RegDst_E == 2'b01) ? Rd_E : 
                        (RegDst_E == 2'b10) ? 31 : 0;

E_ALU  u_E_ALU (
    .ALUCtrl                 ( ALUCtrl_E [3:0]  ),
    .SrcA                    ( SrcA      [31:0] ),
    .SrcB                    ( SrcB      [31:0] ),

    .ALUOut                  ( ALUOut_E  [31:0] )
);

////////////////////////////////   M级   ///////////////////////////////
    wire MemWrite_M;
    wire [1:0] WriteSel_M;
    wire [31:0] ALUOut_M;
    wire [31:0] WriteData_M;
    wire [4:0] WriteReg_M;
    wire [31:0] PC_M;
    wire [31:0] SignImm_M;
    wire [31:0] Instr_M;

M_REG  u_M_REG (
    .clk                     ( clk                 ),
    .reset                   ( reset               ),
    .RegWrite_E              ( RegWrite_E          ),
    .MemtoReg_E              ( MemtoReg_E          ),
    .MemWrite_E              ( MemWrite_E          ),
    .WriteSel_E              ( WriteSel_E   [1:0]  ),
    .ALUOut_E                ( ALUOut_E     [31:0] ),
    .WriteData_E             ( WriteData_E  [31:0] ),
    .WriteReg_E              ( WriteReg_E   [4:0]  ),
    .PC_E                    ( PC_E         [31:0] ),
    .SignImm_E               ( SignImm_E    [31:0] ),
    .Instr_E                 ( Instr_E      [31:0] ),

    .RegWrite_M              ( RegWrite_M          ),
    .MemtoReg_M              ( MemtoReg_M          ),
    .MemWrite_M              ( MemWrite_M          ),
    .WriteSel_M              ( WriteSel_M   [1:0]  ),
    .ALUOut_M                ( ALUOut_M     [31:0] ),
    .WriteData_M             ( WriteData_M  [31:0] ),
    .WriteReg_M              ( WriteReg_M   [4:0]  ),
    .PC_M                    ( PC_M         [31:0] ),
    .SignImm_M               ( SignImm_M    [31:0] ),
    .Instr_M                 ( Instr_M      [31:0] )
);
    wire [31:0] ReadData_M;

M_DM  u_M_DM (
    .clk                     ( clk               ),
    .reset                   ( reset             ),
    .ALUOut                  ( ALUOut_M   [31:0] ),
    .WriteData               ( WriteData_M[31:0] ),
    .MemWrite                ( MemWrite_M        ),
    .pc                      ( PC_M       [31:0] ),

    .ReadData                ( ReadData_M [31:0] )
);
////////////////////////////////   W级   ///////////////////////////////
    wire MemtoReg_W;
    wire [1:0] WriteSel_W;
    wire [31:0] ReadData_W;
    wire [31:0] ALUOut_W;
    wire [4:0] WriteReg_W;
    wire [31:0] SignImm_W;
    wire [31:0] PC_W;
    wire [31:0] Instr_W;
    wire [31:0] Result1_W;
    wire [31:0] Result_W;

    assign Result1_W = (MemtoReg_W == 1'b0) ? ALUOut_W : ReadData_W;
    
    assign Result_W = (WriteSel_W == 2'b00) ? Result1_W : 
                      (WriteSel_W == 2'b01) ? SignImm_W : 
                      (WriteSel_W == 2'b10) ? PC_W + 8 : 0;
W_REG  u_W_REG (
    .clk                     ( clk                ),
    .reset                   ( reset              ),
    .RegWrite_M              ( RegWrite_M         ),
    .MemtoReg_M              ( MemtoReg_M         ),
    .WriteSel_M              ( WriteSel_M  [1:0]  ),
    .ReadData_M              ( ReadData_M  [31:0] ),
    .ALUOut_M                ( ALUOut_M    [31:0] ),
    .WriteReg_M              ( WriteReg_M  [4:0]  ),
    .PC_M                    ( PC_M        [31:0] ),
    .SignImm_M               ( SignImm_M   [31:0] ),
    .Instr_M                 ( Instr_M     [31:0] ),

    .RegWrite_W              ( RegWrite_W         ),
    .MemtoReg_W              ( MemtoReg_W         ),
    .WriteSel_W              ( WriteSel_W  [1:0]  ),
    .ReadData_W              ( ReadData_W  [31:0] ),
    .ALUOut_W                ( ALUOut_W    [31:0] ),
    .WriteReg_W              ( WriteReg_W  [4:0]  ),
    .SignImm_W               ( SignImm_W   [31:0] ),
    .PC_W                    ( PC_W        [31:0] ),
    .Instr_W                 ( Instr_W     [31:0] )
);


endmodule