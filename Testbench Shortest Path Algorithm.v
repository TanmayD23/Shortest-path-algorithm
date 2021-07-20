`timescale 10us/1us
module stimulus();
 reg [3:0]In;
 reg clock;
 reg [2:0]pts;
 wire led,io_sel,tk_inp,start,reset;
 wire [2:0]out;
 initial
 clock=1'b0;
 initial
 #1500 $finish;
 always
 #0.5 clock=~clock;
 debouncer D1(In,io_sel,tk_inp,start,reset,clock);
 comparator c1(pts,io_sel,tk_inp,led,start,clock,out,reset);
 initial
 begin
     $monitor("led=%b, io_sel=%b, tk_inp=%b, start=%b, reset=%b, clock=%b, out=%b",led,io_sel,tk_inp,start,reset,clock,out);
     $dumpfile("spa.vcd");
     $dumpvars(0,stimulus);
     In=4'b0000;
     pts=3'd0;
     #3 In=4'b0010;
     #3 pts=3'd7;
     #3 In=4'b0001;
     #3 In=4'b0011;
     #2 In=4'b1000;
     #5 In=4'b0000;
     #500 In=4'b0100;
     #2 In=4'b0000;
     #2 In=4'b0100;
     #2 In=4'b0000;
     #2 In=4'b0100;
     #2 In=4'b0000;
     #2 In=4'b0100;
     #2 In=4'b0000;
     #2 In=4'b0100;
 end
endmodule