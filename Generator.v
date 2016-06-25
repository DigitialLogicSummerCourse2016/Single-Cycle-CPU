module Generator(
input sys_clk,
input reset,
output reg bot_clk,
output reg smp_clk
);
reg [8:0]   to_smp,ctr1;
reg [12:0]  to_Baud,ctr2;

initial
begin
    to_smp=9'b1_0100_010;    ctr1=9'b0;
    to_Baud=13'b1_0100_0101_100;    ctr2=13'b0;
    smp_clk=0;
    bot_clk=0;
end
always @(posedge sys_clk or negedge reset)
begin
    if(~reset)
    begin
        ctr1=9'b0;
        ctr2=13'b0;
    end
    else
    begin
    if(ctr1==to_smp)
            begin
                smp_clk<=~smp_clk;
                ctr1<=9'b0+1'b1;
            end
        else
            ctr1<=ctr1+1'b1;
    if(ctr2==to_Baud)
            begin
                bot_clk<=~bot_clk;
                ctr2<=13'b0+1'b1;
            end
        else
            ctr2<=ctr2+1'b1;
    end
end
endmodule
