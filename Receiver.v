module Receiver(
  input uart_rx,
  input bot_clk,
  input reset,
  output reg rx_status,
  output reg[7:0] rx_data
);
  reg[4:0] cnt=0;
  reg[3:0] num=0;
  reg start=0;
  reg[7:0] memory;

  always@(posedge bot_clk or negedge reset)
  begin
    if(~reset)
    begin
      cnt<=0;
      rx_data<=0;
      rx_status<=0;
      start<=0;
      memory<=0;
      num<=0;
    end
    else
      begin
        if(~(uart_rx||start))
          begin
            start<=1;
            cnt<=0;
          end
        else if(rx_status)
          begin
            num<=0;
            start<=0;
          end
        if(start)
          begin
            if(num==0)
              begin
                if(cnt==5'd23)
                  begin
                    num<=1;
                    memory[0]<=uart_rx;
                    cnt<=0;
                  end
                else
                  cnt<=cnt+1'b1;
              end
            else if(cnt==5'd15)
              begin
                case(num)
                4'd1:  memory[1]<=uart_rx;
                4'd2:  memory[2]<=uart_rx;
                4'd3:  memory[3]<=uart_rx;
                4'd4:  memory[4]<=uart_rx;
                4'd5:  memory[5]<=uart_rx;
                4'd6:  memory[6]<=uart_rx;
                4'd7:  memory[7]<=uart_rx;
                endcase
                num<=num+1'b1;
                if(num<4'd10)
                  cnt<=0;
              end
            else
              cnt<=cnt+1'b1;
          end


        if(num==4'd8)
          begin
            if(cnt==5'd7)
              begin
                rx_data<=memory;
                rx_status<=1;
                num<=4'd0;
                memory<=0;
              end
          end
        else
          rx_status<=0;
      end
  end
endmodule
