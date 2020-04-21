`timescale 1ns / 1ps

module uart_transmitter
    (
input [7:0]DBUS, 
input sysclk,
input txd_startH,
input rst_n,
input bclk,
output reg txd,
output reg txd_doneH
    );   
    //edge detector
    reg bclk_delayed;
    wire bclk_rising;
    //tx data counted
    reg clr,inc;
    reg [3:0]bct;
    //shift register
    reg loadTSR,start,shift;
    //9-bit shift register TSR
    reg [7:0]TSR;
    //fsm states
    reg [1:0]pstate;
    reg [1:0]nstate;
    parameter idle=2'b00;
    parameter synch=2'b01;
    parameter tdata=2'b10;
    //transmission done
    reg txd_done;

//positive edge detector
always @ (posedge sysclk)
begin
if (!rst_n)
bclk_delayed<=0;
else 
bclk_delayed<=bclk;
end

assign bclk_rising = bclk & (~ bclk_delayed);

//FSM
always @(posedge sysclk)
begin
if (!rst_n)
pstate<=idle;
else
pstate<=nstate;
end

always @(pstate,txd_startH,bclk_rising,bct)
begin

case(pstate)
idle :
begin
    if(txd_startH)
        begin
        start=0;
        loadTSR=1;
        txd_done=0;
        clr=1;
        shift=0;
        inc=0;
        nstate=synch;
        end
    else 
        begin
        start=0;
        loadTSR=0;
        txd_done=0;
        clr=1;
        shift=0;
        inc=0;
        nstate=idle;
    end
end
synch :
begin
    if(bclk_rising)
        begin
        start=1;
        loadTSR=0;
        txd_done=0;
        clr=1;
        shift=0;
        inc=0;
        nstate=tdata;
        end
    else 
        begin
        start=0;
        loadTSR=0;
        txd_done=0;
        clr=1;
        shift=0;
        inc=0;
        nstate=synch;
        end
end
tdata :
begin
    if(bclk_rising)
        begin
        if (bct!=9)begin
        start=0;
        loadTSR=0;
        txd_done=0;
        clr=0;
        shift=1;
        inc=1;
        nstate=tdata;
        end
        else
        begin
        start=0;
        loadTSR=0;
        txd_done=1;
        clr=1;
        shift=0;
        inc=0;
        nstate=idle;
        end
        end
    else
    begin
        start=0;
        loadTSR=0;
        txd_done=0;
        clr=0;
        shift=0;
        inc=0;
        nstate=tdata;
    end
end
    default:begin
        start=0;
        loadTSR=0;
        txd_done=0;
        clr=1;
        shift=0;
        inc=0;
        nstate=idle;
    end
endcase
end 

//transission done 
always @ (posedge sysclk)
begin
txd_doneH<=txd_done;
end

//transmitted bit counter 
always @(posedge sysclk)
begin
if(clr)
    begin
    bct<=0;
    end
else 
    begin
    if(inc)
    begin
        bct<=bct+1;
    end 
    end
end

//8 bit shift register deals data bit transmittion
always @(posedge sysclk)
begin
if(loadTSR)
    begin
    TSR<=DBUS;
    end
else 
    begin
    if(start)
    begin
    txd<=1'b0;
    end
    else 
    begin
        if (shift)
        begin
        TSR<={1'b1,TSR[7:1]};
        txd<=TSR[0];
        end
    end
    end
end 
endmodule