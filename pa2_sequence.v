module pa2_sequence(
	input i_clk,
	input i_rst_n,
	input i_load,
	input i_reload,
	input i_start_read,
	input signed [3:0] i_data, //nhan data tu sw lan luot

	output [1:0] o_result,
	output reg signed [7:0] o_data //ket qua x, x1, x2 
	
);

	//Tin hieu noi bo
	reg signed [3:0] reg_A, reg_B, reg_C; //nhan dư lieu tu sw va luu vao day
	reg signed [7:0] reg_X, reg_X1, reg_X2; //reg luu ket qua x, x1, x2
	reg [3:0] state;
	reg [31:0] display_state;
	wire [7:0] core_o_X, core_o_
	localparam	GET_A = 4'b0001;
	localparam	GET_B = 4'b0010;
	localparam	GET_C = 4'b0011;
	localparam	CALC = 4'b0100;
	localparam	FINISH = 4'b0101;
	localparam	READ_X = 4'b0110;
	localparam	READ_X1 = 4'b0111;
	localparam	READ_X2 = 4'b1000;
	
	//Connect to pa1
pa1_combination pa1instant (
	//Cac ket noi dieu khien
	.i_enable (i_start_read),
	
	//cac ket noi du lieu vao
	.i_A (reg_A),
	.i_B (reg_B),
	.i_C (reg_C),
	
	//cac ket noi du lieu ra
	.o_result (o_result),
	.o_X 	(core_o_X),
	.o_X1	(core_o_X1),
	.o_X2	(core_o_X2)
);
	
	//FSM control
always @(posedge i_clk or negedge i_rst_n)begin
	 if(!i_rst_n)begin
		state <= IDLE;
		reg_A <= 0;
		reg_B <= 0;
		reg_C <= 0;
		reg_X <= 0;
		reg_X1 <= 0;
		reg_X2 <= 0;
	 end else case (state)
		IDLE: begin
		reg_A <= 0;
		reg_B <= 0;
		reg_C <= 0;
		reg_X <= 0;
		reg_X1 <= 0;
		reg_X2 <= 0;	
		o_result <= 0;		
			if(~i_load)begin
				state <= GET_A;
				reg_A <= i_data;
			end 
		end
		
		GET_A: begin
			if(~i_load)begin
				state <= GET_B;
				reg_B <= i_data;
			end else if (~i_reload)begin
				reg_A <= 0;
				state <= IDLE;
			end
		end
		
		GET_B: begin
			if(~i_load)begin
				state <= GET_C;
				reg_C <= i_data;
			end else if (~i_reload)begin
				reg_B <= 0;
				state <= GET_A;
			end
		end
		
		GET_C: begin
			if(~i_start_read)begin
				state <= CALC;
			end else if (~i_reload)begin
				reg_C <= 0;
				state <= GET_B;
			end
		end
		
		CALC: begin
			state <= FINISH;
			reg_X <= core_o_X;
			reg_X1 <= core_o_X1;
			reg_X2 <= core_o_X2;			
		end
		
		FINISH: begin
			if(~i_start_read)begin
				if (o_result == 2'b00)begin
					state <= READ_X;
				end else if (o_result == 2'b01)begin
					state <= READ_X;
				end else if (o_result == 2'b10)begin
					state <= READ_X;
				end else if (o_result == 2'b11) begin
					state <= READ_X1;
				end										
			end
		end
		
		READ_X: begin
			o_data <= reg_X;
			if(~i_start_read)begin
				state <= IDLE;
			end
		end
				
		READ_X1: begin
			o_data <= reg_X1;
			if(~i_start_read)begin
				state <= READ_X2;				
			end
		end
		
		READ_X2: begin
			o_data <= reg_X2;
			if(~i_start_read)begin
				state <= IDLE;
			end
		end
	 endcase
end

always @(*) begin
    case (state)
			IDLE : 	display_state = "IDLE";
			GET_A: 	display_state = "GET_A";
			GET_B: 	display_state = "GET_B";
			GET_C: 	display_state = "GET_C";
			CALC: 	display_state = "CALC";
			FINISH: display_state = "FINISH";
			READ_X: display_state = "READ_X";
			READ_X1:display_state = "READ_X1";
			READ_X2:display_state = "READ_X2";
    endcase
end

endmodule
	