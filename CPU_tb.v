module CPU_tb();

	reg reset;
	reg clk;
	wire [7:0] switch;
	reg uart_rx;
	wire  [7:0] led;
	wire  [11:0] digi;
	wire  uart_tx;

	SC_CPU CPU1(.reset(reset),.clk(clk),.switch(switch),.uart_rx(uart_rx),.led(led),
		.digi(digi),.uart_tx(uart_tx));

	initial begin
	reset <= 1'b1;
	clk <= 1'b0;
	uart_rx <= 1'b1;
end

always #1 clk <= ~clk;

initial begin
	#5  reset <= 1'b0;
	#10 reset <= 1'b1;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#416660 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
	#20833 uart_rx <= ~uart_rx;
end

endmodule
