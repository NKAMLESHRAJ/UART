`timescale 1ns / 1ps

module baud_rate_generator 
( 
input fclk,
input [2:0]sel,
output bclk,bx8clk
);
wire clk;
reg [3:0]n=3;//n=fclk/(BRmax*c*2) where c=8
reg [1:0]count=0;
//reg clk_div;
//wire clkdiv;
reg [7:0]counter=0; 
reg [2:0]counter_div_by_c=0; 
//100mhz to 1.8432mhz
input_clock_1point8432mhz_frequency clk1(.clock(fclk), .clk(clk) );//1.8432mhz clock
//clk_div 33.3% duty cycle
always @ (posedge clk)
begin 
if(count<n)
count<=count+1;
else
count<=0;
end
//clkdiv 50% duty cycle
//always @ (negedge clk)
//begin 
//clk_div<=count[1];
//end
//assign clkdiv=count[1]|clk_div;
//frequency selector
always @(posedge count[1])
begin
counter<=counter+1;
end
//bx8clk signal
assign bx8clk=counter[sel];
//bclk clock divided by c
always @(posedge counter[sel])
begin
counter_div_by_c<=counter_div_by_c+1;
end
assign bclk=counter_div_by_c[2];
endmodule
