`timescale 1ps/1ps
module debouncer(in,io_sel,tk_inp,start,reset,clk);
 input [3:0]in;
 input clk;
 output reg io_sel,tk_inp,start,reset;
 always@(posedge clk)
 begin
     io_sel<=in[0];
     tk_inp<=in[1];
     start<=in[2];
     reset<=in[3];
 end
endmodule

module comparator(pts,io_sel,tk_inp,led,start,clk,out,reset);
 input clk,start,reset;
 output reg [2:0]out;
 input [2:0]pts;
 input io_sel,tk_inp;
 output reg led;
 reg stop,op;
 reg [2:0]p_state;
 reg [2:0]i_state,f_state;
 reg [2:0]n_state[7:0];
 reg [2:0]prev_st[7:0];
 reg [5:0]dist0[7:0];
 reg [5:0]dist1[7:0];
 reg [5:0]dist2[7:0];
 reg [5:0]dist3[7:0];
 reg [5:0]dist4[7:0];
 reg [5:0]dist5[7:0];
 reg [5:0]dist6[7:0];
 reg [5:0]dist7[7:0];
 reg [5:0]dt[7:0];
 reg [2:0]path[7:0];
 reg [3:0]a,count,cnt,ct;
 reg [2:0]ctr;
  always@(posedge tk_inp)
 begin
     if(io_sel==1'b0)
       i_state=pts;
     else if(io_sel==1'b1)
       f_state=pts;
 end
 always@(posedge clk)
 begin
     dist0[0]<=6'd0; dist0[1]<=6'd1; dist0[2]<=6'd2; dist0[3]<=6'd5; dist0[4]<=6'd20; dist0[5]<=6'd20; dist0[6]<=6'd20; dist0[7]<=6'd20;
     dist1[0]<=6'd1; dist1[1]<=6'd0; dist1[2]<=6'd20; dist1[3]<=6'd20; dist1[4]<=6'd4; dist1[5]<=6'd11; dist1[6]<=6'd20; dist1[7]<=6'd20;
     dist2[0]<=6'd2; dist2[1]<=6'd20; dist2[2]<=6'd0; dist2[3]<=6'd20; dist2[4]<=6'd9; dist2[5]<=6'd5; dist2[6]<=6'd16; dist2[7]<=6'd20;
     dist3[0]<=6'd5; dist3[1]<=6'd20; dist3[2]<=6'd20; dist3[3]<=6'd0; dist3[4]<=6'd20; dist3[5]<=6'd20; dist3[6]<=6'd2; dist3[7]<=6'd20;
     dist4[0]<=6'd20; dist4[1]<=6'd4; dist4[2]<=6'd9; dist4[3]<=6'd20; dist4[4]<=6'd0; dist4[5]<=6'd20; dist4[6]<=6'd20;dist4[7]<=6'd18;
     dist5[0]<=6'd20; dist5[1]<=6'd11; dist5[2]<=6'd5; dist5[3]<=6'd20; dist5[4]<=6'd20; dist5[5]<=6'd0; dist5[6]<=6'd20; dist5[7]<=6'd13;
     dist6[0]<=6'd20; dist6[1]<=6'd20; dist6[2]<=6'd16; dist6[3]<=6'd2;dist6[4]<=6'd20; dist6[5]<=6'd20; dist6[6]<=6'd0; dist6[7]<=6'd2;
     dist7[0]<=6'd20; dist7[1]<=6'd20; dist7[2]<=6'd20; dist7[3]<=6'd20; dist7[4]<=6'd18; dist7[5]<=6'd13; dist7[6]<=6'd2; dist7[7]<=6'd0;
     n_state[0]<=3'd0; n_state[1]<=3'd1; n_state[2]<=3'd2; n_state[3]<=3'd3; n_state[4]<=3'd4; n_state[5]<=3'd5; n_state[6]<=3'd6; n_state[7]<=3'd7;
 end
 always@(posedge clk)
 begin
     if(reset==1'b1)
     begin
         cnt<=4'd1;
         a<=4'd0;
         ctr<=2'd1;
         count<=4'd0;
         prev_st[0]<=i_state;
         dt[0]<=6'd20;dt[1]<=6'd20;dt[2]<=6'd20;dt[3]<=6'd20;dt[4]<=6'd20;dt[5]<=6'd20;dt[6]<=6'd20;dt[7]<=6'd20;
         p_state<=i_state;
         stop<=1'b0;
         led<=1'b0;
         dt[p_state]<=6'd0;
         path[0]<=f_state;
         op<=1'b0;
     end 
     if(cnt==4'd8)
     begin
         op<=1'b1;
         cnt<=4'd1;
         a<=4'd0;
         count<=4'd0;
         p_state<=f_state;
     end
     if(stop==1'b0 && reset==1'b0)
     begin
         case(p_state)
             3'd0 : begin
                 if(a<4'd8)
                 begin
                     if(count<cnt+1)
                     begin
                         if(n_state[a]!=prev_st[count] && op==1'b0)
                         begin
                             if(dt[a]>(dist0[a]+dt[0]))
                             begin
                                 dt[a]<=dist0[a]+dt[0];
                             end                            
                         end
                         else if(op==1'b1 && n_state[a]!=path[count])
                         begin
                             if((dt[0]-dt[a])==dist0[a])
                             begin                               
                                 p_state<=n_state[a];
                                 path[cnt]<=n_state[a];
                                 if(n_state[a]==i_state)begin stop<=1'b1; end
                             end
                         end
                         count<=count+1;
                     end
                     else if(count==cnt+1)
                     begin
                         count<=0;
                         a<=a+1;
                     end
                 end
                 else if(a==4'd8)
                 begin
                     a<=0;
                     cnt<=cnt+1;
                     if(op==1'b0)
                     begin
                         prev_st[cnt]<=p_state;
                         p_state<=3'd1;
                     end
                     
                 end
             end
             3'd1 : begin
                 if(a<4'd8)
                 begin
                     if(count<cnt+1)
                     begin                        
                         if(n_state[a]!=prev_st[count] && op==1'b0)
                         begin
                             if(dt[a]>dist1[a]+dt[1])
                             begin
                                 dt[a]<=dist1[a]+dt[1];
                             end                            
                         end
                         else if(op==1'b1 && n_state[a]!=path[count])
                         begin
                             if((dt[1]-dt[a])==dist1[a])
                             begin                                 
                                 p_state<=n_state[a];
                                 path[cnt]<=n_state[a];
                                 if(n_state[a]==i_state)begin stop<=1'b1; end
                             end
                         end
                         count<=count+1;
                     end
                     else if(count==cnt+1)
                     begin
                         count<=0;
                         a<=a+1;
                     end
                 end
                 else if(a==4'd8)
                 begin
                     a<=0;
                     cnt<=cnt+1;
                     if(op==1'b0)
                     begin
                         prev_st[cnt]<=p_state;
                         p_state<=3'd2;
                     end
                 end
             end
             3'd2 : begin
                 if(a<4'd8)
                 begin
                     if(count<cnt+1)
                     begin
                         if(n_state[a]!=prev_st[count] && op==1'b0)
                         begin
                             if(dt[a]>dist2[a]+dt[2])
                             begin
                                 dt[a]<=dist2[a]+dt[2];
                             end                            
                         end
                         else if(op==1'b1 && n_state[a]!=path[count])
                         begin
                             if((dt[2]-dt[a])==dist2[a])
                             begin                              
                                 p_state<=n_state[a];
                                 path[cnt]<=n_state[a];
                                 if(n_state[a]==i_state)begin stop<=1'b1; end
                             end
                         end
                         count<=count+1;
                     end
                     else if(count==cnt+1)
                     begin
                         count<=0;
                         a<=a+1;
                     end
                 end
                 else if(a==4'd8)
                 begin
                     a<=0;
                     cnt<=cnt+1;
                     if(op==1'b0)
                     begin
                         prev_st[cnt]<=p_state;
                         p_state<=3'd3;
                     end
                 end
             end
             3'd3 : begin
                 if(a<4'd8)
                 begin
                     if(count<cnt+1)
                     begin
                         if(n_state[a]!=prev_st[count] && op==1'b0)
                         begin
                             if(dt[a]>dist3[a]+dt[3])
                             begin
                                 dt[a]<=dist3[a]+dt[3];
                             end                            
                         end
                         else if(op==1'b1 && n_state[a]!=path[count])
                         begin
                             if((dt[3]-dt[a])==dist3[a])
                             begin                                
                                 p_state<=n_state[a];
                                 path[cnt]<=n_state[a];
                                 if(n_state[a]==i_state)begin stop<=1'b1; end
                             end
                         end
                         count<=count+1;
                     end
                     else if(count==cnt+1)
                     begin
                         count<=0;
                         a<=a+1;
                     end
                 end
                 else if(a==4'd8)
                 begin
                     a<=0;
                     cnt<=cnt+1;
                     if(op==1'b0)
                     begin
                         prev_st[cnt]<=p_state;
                         p_state<=3'd4;
                     end
                 end
             end
             3'd4 : begin
                if(a<4'd8)
                 begin
                     if(count<cnt+1)
                     begin
                         if(n_state[a]!=prev_st[count] && op==1'b0)
                         begin
                             if(dt[a]>dist4[a]+dt[4])
                             begin
                                 dt[a]<=dist4[a]+dt[4];
                             end                            
                         end
                         else if(op==1'b1 && n_state[a]!=path[count])
                         begin
                             if((dt[4]-dt[a])==dist4[a])
                             begin                                
                                 p_state<=n_state[a];
                                 path[cnt]<=n_state[a];
                                 if(n_state[a]==i_state)begin stop<=1'b1; end
                             end
                         end
                         count<=count+1;
                     end
                     else if(count==cnt+1)
                     begin
                         count<=0;
                         a<=a+1;
                     end
                 end
                 else if(a==4'd8)
                 begin
                     a<=0;
                     cnt<=cnt+1;
                     if(op==1'b0)
                     begin
                         prev_st[cnt]<=p_state;
                         p_state<=3'd5;
                     end
                 end
             end
             3'd5 : begin
                 if(a<4'd8)
                 begin
                     if(count<cnt+1)
                     begin
                         if(n_state[a]!=prev_st[count] && op==1'b0)
                         begin
                             if(dt[a]>dist5[a]+dt[5])
                             begin
                                 dt[a]<=dist5[a]+dt[5];
                             end                            
                         end
                         else if(op==1'b1 && n_state[a]!=path[count])
                         begin
                             if((dt[5]-dt[a])==dist5[a])
                             begin
                                 p_state<=n_state[a];
                                 path[cnt]<=n_state[a];                         
                                 if(n_state[a]==i_state)begin stop<=1'b1; end
                             end
                         end
                         count<=count+1;
                     end
                     else if(count==cnt+1)
                     begin
                         count<=0;
                         a<=a+1;
                     end
                 end
                 else if(a==4'd8)
                 begin
                     a<=0;
                     cnt<=cnt+1;
                     if(op==1'b0)
                     begin
                         prev_st[cnt]<=p_state;
                         p_state<=3'd6;
                     end
                 end
             end
             3'd6 : begin
                 if(a<4'd8)
                 begin
                     if(count<cnt+1)
                     begin
                         if(n_state[a]!=prev_st[count] && op==1'b0)
                         begin
                             if(dt[a]>dist6[a]+dt[6])
                             begin
                                 dt[a]<=dist6[a]+dt[6];
                             end                            
                         end
                         else if(op==1'b1 && n_state[a]!=path[count])
                         begin
                             if((dt[6]-dt[a])==dist6[a])
                             begin
                                 p_state<=n_state[a];
                                 path[cnt]<=n_state[a];                             
                                 if(n_state[a]==i_state)begin stop<=1'b1; end
                             end
                         end
                         count<=count+1;
                     end
                     else if(count==cnt+1)
                     begin
                         count<=0;
                         a<=a+1;
                     end
                 end
                 else if(a==4'd8)
                 begin
                     a<=0;
                     cnt<=cnt+1;
                     if(op==1'b0)
                     begin
                         prev_st[cnt]<=p_state;
                         p_state<=3'd7;
                     end
                 end
             end
             3'd7 : begin
                 if(a<4'd8)
                 begin
                     if(count<cnt+1)
                     begin
                         if(n_state[a]!=prev_st[count] && op==1'b0)
                         begin
                             if(dt[a]>dist7[a]+dt[7])
                             begin
                                 dt[a]<=dist7[a]+dt[7];
                             end                            
                         end
                         else if(op==1'b1 && n_state[a]!=path[count])
                         begin
                             if((dt[7]-dt[a])==dist7[a])
                             begin
                                 p_state<=n_state[a];
                                 path[cnt]<=n_state[a];
                                 if(n_state[a]==i_state)begin stop<=1'b1; end
                             end
                         end
                         count<=count+1;
                     end
                     else if(count==cnt+1)
                     begin
                         count<=0;
                         a<=a+1;
                     end
                 end
                 else if(a==4'd8)
                 begin
                     a<=0;
                     cnt<=cnt+1;
                     if(op==1'b0)
                     begin
                         prev_st[cnt]<=p_state;
                         p_state<=3'd0;
                     end
                 end
             end
         endcase
     end
     else if(stop==1'b1 && reset==1'b0)
     begin
         if(ctr==2'd1) begin ctr<=ctr+1; led<=1'b1; end
         if(ctr==2'd2 && start==1'b1)
         begin
            ctr<=2'd0;
         end
     end
 end

 always@(posedge start)
 begin
     if(ctr==2'd2) begin ct=0; end
     if(ct<cnt+4'd1)
     begin
         out<=path[ct];
     end
     ct=ct+1;
 end
endmodule

module Top(pts,led,out,clk,IN);
 input [2:0]pts;
 input [3:0]IN;
 input clk;
 output led;
 output [2:0]out;
 debouncer D1(IN,io_sel,tk_inp,start,reset,clk);
 comparator c1(pts,io_sel,tk_inp,led,start,clk,out,reset);
endmodule