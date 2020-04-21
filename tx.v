`timescale 1ns / 1ps

module tx
    (
    //baud rate generator input 
    input fclk,[2:0]sel,
    //uart tx input
    input txd_startH,rst_n,[7:0]DBUS,
    //uart tx output 
    output txd_doneH,
    //uart rx output
    output rxd_readyH,
    output [7:0]RDR
    );
    wire bclk,bx8clk;
    wire txd,rxd;
  assign rxd=txd;  
//fclk input to transmitter   
baud_rate_generator brg (.fclk(fclk),.sel(sel),.bclk(bclk),.bx8clk(bx8clk));
//uart transmitter
uart_transmitter utx(.DBUS(DBUS),.sysclk(fclk),.txd_startH(txd_startH),.rst_n(rst_n),.bclk(bclk),.txd(txd),.txd_doneH(txd_doneH));
 //uart reciever
 uart_reciever urx (.sysclk(fclk),.rxd(rxd),.rst_n(rst_n),.bx8clk(bx8clk),.RDR(RDR),.rxd_readyH(rxd_readyH));  
endmodule
