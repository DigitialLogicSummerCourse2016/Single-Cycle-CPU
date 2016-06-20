module CPU(
	input reset,
	input clk,
	input [7:0] switch,
	input uart_rx,
	output [7:0] led,
	output [11:0] digi,
	output uart_tx,
	output reg signal
	);
    always@(posedge clk or negedge reset)
    begin
        if(~reset)
            signal<=0;
        else
            signal<=~signal;
    end
	parameter ILLOP = 32'h80000004;
	parameter XADR = 32'h80000008;

	wire [4:0] Xp = 5'd26;
	wire [4:0] Ra = 5'd31;

	reg[31:0] PC;
	wire[31:0] PC_next;

	wire [31:0] PC_plus_4;
	assign PC_plus_4 = PC + 32'd4;
	assign PCSupervisor = PC[31];

	wire[31:0] Instrument;

	wire[2:0] PCSrc;
	wire[1:0] RegDst;
	wire[5:0] ALUFun;
	wire[4:0] ALUOp;
	wire[1:0] MemToReg;
	wire RegWr, ALUSrc1, ALUSrc2, Sign, MemWr, MemRd, EXTOp, LUOp;
	wire IRQ;

	wire[31:0] DMData; wire [31:0] DMData1; wire [31:0] DMData2;

	wire[25:0] JT;		assign JT = Instrument[25:0];
	wire[4:0] Shamt;	assign Shamt = Instrument[10:6];
	wire[4:0] Rd;		assign Rd = Instrument[15:11];
	wire[4:0] Rt;		assign Rt = Instrument[20:16];
	wire[4:0] Rs;		assign Rs = Instrument[25:21];

	wire[4:0] AddrC; wire[31:0] DataBusA; wire [31:0] DataBusB; wire [31:0] DataBusC;

	wire[31:0] LUOpout;	wire[31:0] ExtImm;

	always@(negedge reset or posedge clk)
	begin
		if(~reset)
			PC <= 32'h00000000;
		else begin
			PC <= PC_next;
		end
	end

	assign AddrC = (RegDst==2'b00)? Rd:
	               (RegDst==2'b01)? Rt:
	               (RegDst==2'b10)? Ra:
	               (RegDst==2'b11)? Xp: 5'd0;

	assign LUOpout = LUOp? {Instrument[15:0],16'h0000} : ExtImm;
	assign ExtImm = {EXTOp?{16{Instrument[15]}}:16'h0000,Instrument[15:0]};

	wire[31:0] PreConBA;
	assign PreConBA = {ExtImm[29:0],2'b00};
	wire[31:0] ConBA;
	assign ConBA = PC_plus_4 + PreConBA;

	wire[31:0] A,B,ALUOut;
	wire Zero;
	assign A = ALUSrc1? Shamt[4:0]:DataBusA;
	assign B = ALUSrc2? LUOpout:DataBusB;

	assign DMData = (ALUOut[31:28] == 4'b0100) ? DMData2 : DMData1;
	assign DataBusC = (MemToReg==2'b00)? ALUOut:
					  (MemToReg==2'b01)? DMData:
					  (MemToReg==2'b10)? PC_plus_4:PC;

	assign PC_next = (PCSrc==3'b000)? PC_plus_4:
									 (PCSrc==3'b001)? ALUOut[0]? {PC[31], ConBA[30:0]}:PC_plus_4 :
									 (PCSrc==3'b010)? {PC[31],3'b0,JT,2'b0}:
									 (PCSrc==3'b011)? DataBusA:
									 (PCSrc==3'b100)? ILLOP:
									 (PCSrc==3'b101)? XADR:XADR;

	wire MemWr1,MemWr2;
	assign MemWr1 = (ALUOut[31:28] == 4'b0100) ? 1'b0 : MemWr;
	assign MemWr2 = (ALUOut[31:28] == 4'b0100) ? MemWr : 1'b0;

	wire [11:0] DIGI;
	assign digi = ~DIGI;

 	ROM ROM1(.addr(PC[30:0]),.data(Instrument));

	RegisterFile Register(.reset(reset), .clk(clk), .WrC(RegWr),
		.AddrA(Rs), .AddrB(Rt),
		.AddrC(AddrC), .WriteDataC(DataBusC), .ReadDataA(DataBusA),
		.ReadDataB(DataBusB));

	ALU ALU1(.A(A),.B(B),.ALUFun(ALUFun),.Sign(Sign),.Z(ALUOut),.zero(Zero));

	Controller control1(.Instruction(Instrument),.IRQ(IRQ),.PCSrc(PCSrc),.RegDst(RegDst),
		.ALUFun(ALUFun),.MemToReg(MemToReg),.RegWr(RegWr),.ALUSrc1(ALUSrc1),.ALUSrc2(ALUSrc2),
		.MemWr(MemWr),.MemRd(MemRd),.EXTOp(EXTOp),.LUOp(LUOp),.Sign(Sign),.PCSupervisor(PCSupervisor));

	DataMemory DM1(.reset(reset), .clk(clk), .Address(ALUOut[31:0]), .Write_data(DataBusB),
		.Read_data(DMData1), .MemRead(MemRd), .MemWrite(MemWr1));

	//UART and Peripheral
	Peripheral Perip1(.reset(reset),.clk(clk),.MemRead(MemRd),.MemWrite(MemWr2),
		.Address(ALUOut[31:0]),.Write_data(DataBusB),.Read_data(DMData2),.led(led),
		.switch(switch),.digi(DIGI),.irqout(IRQ),.uart_tx(uart_tx),.uart_rx(uart_rx));

endmodule
