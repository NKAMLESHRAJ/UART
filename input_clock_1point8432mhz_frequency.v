`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2020 04:12:14 PM
// Design Name: 
// Module Name: input_clock_1point8432mhz_frequency
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module input_clock_1point8432mhz_frequency
(
input clock, //1mhz
output clk  //1.8432mhz
    );
    
    reg[5:0]count=0;
    
    always @ (posedge clock)
    begin
    if(count<55)
    count<=count+1;
    else
    count<={6{1'b0}};
    end
    
    assign clk=count[5];
    
endmodule