`timescale 1ns / 1ps

module uart_reciever
    (
input sysclk,   
input rxd,
input rst_n,
input bx8clk,
output reg [7:0]RDR,
output reg rxd_readyH
    );   
    //edge detector
    reg bx8clk_delayed;
    wire bx8clk_rising;
    //rx data counter signals
    reg clr1,inc1,clr2,inc2;
    reg [3:0]ct1,ct2;
    //shift register
    reg load_RDR,shiftRSR;
    //8-bit shift register 
    reg [7:0]RSR;//,RDR_dataloader;
    //fsm states
    reg [1:0]pstate;
    reg [1:0]nstate;
    parameter idle=2'b00;
    parameter start_detected=2'b01;
    parameter recv_data=2'b10;
    //transmission done
    reg ok_en;

//positive edge detector
always @ (posedge sysclk)
begin
if (!rst_n)
bx8clk_delayed<=0;
else  
bx8clk_delayed<=bx8clk;
end

assign bx8clk_rising = bx8clk & (~ bx8clk_delayed);

//FSM
always @(posedge sysclk)
begin
if (!rst_n)
pstate<=idle; 
else
pstate<=nstate;
end 

always @(pstate,rxd,bx8clk_rising,ct1,ct2)
begin

case(pstate)
idle:
begin
 if(!rxd)
 begin
    load_RDR=0;
    ok_en=0;
    clr1=1;
    clr2=1;
    inc1=0;
    inc2=0;
    ok_en=0;
    shiftRSR=0;
    nstate=start_detected;
 end
 else
    begin
    load_RDR=0;
    ok_en=0;
    clr1=0;
    clr2=0;
    inc1=0;
    inc2=0;
    ok_en=0;
    shiftRSR=0;
    nstate=idle;
    end
end
start_detected:
begin
if(bx8clk_rising)
    begin
    if(rxd)
        begin
        load_RDR=0;
        ok_en=0;
        clr1=1;
        clr2=1;
        inc1=0;
        inc2=0;
        ok_en=0;
        shiftRSR=0; 
        nstate=idle;
        end
    else
        begin
        if(ct1!=3) 
            begin
            load_RDR=0;
            ok_en=0;
            clr1=0;
            clr2=1; 
            inc1=1;
            inc2=0;
            ok_en=0;
            shiftRSR=0;
            nstate=start_detected;
            end
        else 
            begin
            load_RDR=0;
            ok_en=0;
            clr1=1;
            clr2=1;
            inc1=0;
            inc2=0;
            ok_en=0;
            shiftRSR=0;
            nstate=recv_data;
            end 
        end
    end
else
    begin
    load_RDR=0;
    ok_en=0;
    clr1=0;
    clr2=0;
    inc1=0;
    inc2=0;
    ok_en=0;
    shiftRSR=0;
    nstate=start_detected;
    end
end
recv_data:
begin
if(bx8clk_rising)
    begin
    load_RDR=0;
    ok_en=0;
    clr1=0;
    clr2=0;
    inc1=1;
    inc2=0;
    ok_en=0;
    shiftRSR=0;
    if(ct1!=7)
        begin 
        load_RDR=0;
        ok_en=0;
        clr1=0;
        clr2=0;
        inc1=1;
        inc2=0;
        ok_en=0;
        shiftRSR=0;
        nstate=recv_data;
        end
    else
    begin
        if(ct2!=8)
            begin
            load_RDR=0;
            ok_en=0;
            clr1=1;
            clr2=0;
            inc1=0;
            inc2=1; 
            ok_en=0;
            shiftRSR=1;
            nstate=recv_data;
            end
        else
        begin
            if(!rxd)
                begin
                load_RDR=0;
                ok_en=0;
                clr1=1;
                clr2=1;
                inc1=0;
                inc2=0;
                shiftRSR=0;
                nstate=idle;
                end
            else
                begin
                load_RDR=1;
                ok_en=1;
                clr1=1;
                clr2=1;
                inc1=0;
                inc2=0;
                shiftRSR=0;
                nstate=idle;
                end
            end
        end
    end
    else
    begin
    load_RDR=0;
    ok_en=0;
    clr1=0;
    clr2=0;
    inc1=0;
    inc2=0;
    ok_en=0;
    shiftRSR=0;
    nstate=recv_data;
    end
end
    default:begin
    load_RDR=0;
    ok_en=0;
    clr1=1;
    clr2=1;
    inc1=0;
    inc2=0;
    ok_en=0; 
    shiftRSR=0;   
    nstate=idle;
    end
endcase
end 
//transission done 
always @ (posedge sysclk)
begin
rxd_readyH<=ok_en;
end
//recieved bit counter 
always @(posedge sysclk)
begin
if(clr1)
    begin
    ct1<=0;
    end
else 
    begin
    if(inc1)
    begin
        ct1<=ct1+1;
    end 
    end
end
//bit cell counter
always @(posedge sysclk)
begin
if(clr2)
    begin
    ct2<=0;
    end
else 
    begin
    if(inc2)
    begin
        ct2<=ct2+1;
    end 
    end
end
//data shift register 
always @(posedge sysclk)
begin
if(shiftRSR)
    begin
    RSR<={rxd,RSR[7:1]};
    end
else 
    begin
    if(load_RDR)
    begin
    RDR<=RSR;
    end
    end
end
endmodule

////8 bit shift register deals data bit transmittion
//always @(posedge sysclk)
//begin
//if(load_RDR)
//    begin    
//    RDR<=RDR_dataloader;
//    end
//end

