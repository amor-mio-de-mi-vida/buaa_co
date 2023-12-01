`timescale  1ns / 1ps
`include "./mips.v"

module tb_mips;

// mips Parameters
parameter PERIOD  = 10;


// mips Inputs
reg   clk                                  = 0 ;
reg   reset                                = 0 ;

// mips Outputs



initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

// initial
// begin
//     #(PERIOD*2) rst_n  =  1;
// end

mips  u_mips (
    .clk                     ( clk     ),
    .reset                   ( reset   )
);

initial
begin
    $dumpfile("mips_tb.vcd");
    $dumpvars;

    #500;
    $finish;
end

endmodule