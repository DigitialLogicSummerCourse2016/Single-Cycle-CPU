module Sender(
  input tx_en,
  input bot_clk,
  input[7:0] tx_data,
  input reset,
  output reg uart_tx,
  output reg tx_status
);
  reg[3:0] cnt=0;
  reg[3:0] num=0;

  initial uart_tx<=1;

  always@(posedge bot_clk or negedge reset)
  begin
    if(~reset)
      begin
        cnt<=0;
        tx_status<=1;
        uart_tx<=1;
        cnt<=0;
        num<=0;
      end
    else
      begin
        if(tx_en) begin tx_status<=0; num<=0; end
        else if(num==4'd10)  tx_status<=1;

        if(~tx_status)
        begin
          if(cnt==4'd15)
          begin
            case(num)
              5'd0:  uart_tx<=0;
              5'd1:  uart_tx<=tx_data[0];
              5'd2:  uart_tx<=tx_data[1];
              5'd3:  uart_tx<=tx_data[2];
              5'd4:  uart_tx<=tx_data[3];
              5'd5:  uart_tx<=tx_data[4];
              5'd6:  uart_tx<=tx_data[5];
              5'd7:  uart_tx<=tx_data[6];
              5'd8:  uart_tx<=tx_data[7];
              5'd9:  uart_tx<=1;
            endcase
            num<=num+1'b1;
            cnt<=0;
          end
          else
            cnt<=cnt+1'b1;
       	end
   	  else
 	      begin
 	        if(num==4'd10)
 	          begin
 	            num<=0;
 	            uart_tx<=1;
 	          end
 	      end
 	  end
  end
endmodule
