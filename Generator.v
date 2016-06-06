module Generator(
input sys_clk,
input reset,
output reg bot_clk = 0
);
reg [7:0] status = 0;
always @(posedge sys_clk or negedge reset)
begin
    if(~reset)
    begin
        bot_clk <= 0;
        status <= 0;
    end
    else
    begin
    if(status == 8'd163) begin bot_clk <= ~bot_clk; status <= 0; end
    else status <= status + 1;
    end
end
endmodule
