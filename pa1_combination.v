module pa1_combination (

	//pa1
	input i_enable,
	input signed [3:0] i_A, i_B, i_C,
	output reg signed [1:0] o_result,
	output reg signed [7:0] o_X1, o_X2,
	
	 output [6:0]  HEX0,   // X1 mag
    output [6:0]  HEX1,   // X1 sign
    output [6:0]  HEX2,   // X2 mag
    output [6:0]  HEX3    // X2 sign
	
);

	//tin hieu noi bo
	reg signed [1:0] temp_result;
	reg signed [7:0] temp_X1, temp_X2;
	reg [31:0] display_state;
	
	wire signed [15:0] delta;
	wire signed [7:0] sqrt;
	
	assign delta = (i_B*i_B) - (4*i_A*i_C);

	 
	 //===================================================================
	// FUNCTION ĐỊNH NGHĨA BÊN TRONG MODULE
	// <--- Chức năng này bây giờ là cục bộ (local) của module pa1_combination
	//===================================================================
	function [7:0] integer_sqrt;
		input [15:0] num;
		
		reg [15:0] temp;
		reg [7:0] res;
		integer i;
		
		begin
			res = 0;
			temp = 0;
			
			for (i = 8; i > 0; i = i - 1) begin
				temp = {temp[13:0], num[(2*i)-1 -: 2]};
				if (temp >= ({res, 2'b01})) begin
					temp = temp - {res, 2'b01};
					res = {res[6:0], 1'b1};
				end else begin
					res = {res[6:0], 1'b0};
				end
			end
			
			integer_sqrt = res; // Gán giá trị trả về cho function
		end
	endfunction
	//===================================================================
	
	// Tính căn bậc hai bằng cách gọi function cục bộ
	// <--- Vẫn gọi function như bình thường
	assign sqrt = integer_sqrt(delta);
	
always @(*) begin
		// Giá trị mặc định để tránh latch khi i_enable = 1 (không kích hoạt)
        temp_result = 2'b00; // Vô nghiệm
        temp_X1 = 0;
        temp_X2 = 0;
		
		if(~i_enable) begin
			//trương hop a = 0 pt bac 1: Bx + C = 0
			if (i_A == 0)begin
				if (i_B != 0) begin
					temp_result = 2'b01; //1 nghiem
					temp_X1 = $signed(-i_C)/$signed(i_B);
				end else begin
					temp_result = 2'b00;
					temp_X1 = 0;
				end
			end 
			
			
			else begin
				//trương hop a != 0 pt bac 2: Ax^2 + Bx + C = 0
				if(delta < 0) begin
					temp_result = 2'b00; //vo nghiem
					temp_X1 = 0;
				end else if(delta == 0) begin
					temp_result = 2'b10; //nghiem kep
					temp_X1 = $signed(-i_B) / $signed(i_A << 1);
				end else begin
					temp_result = 2'b11; //2 nghiem phan biet
					// Mở rộng dấu i_B từ 4-bit lên 8-bit để cộng/trừ với sqrt_result (8-bit)
//					temp_X1 = ($signed( { {4{i_B[3]}}, i_B } ) + sqrt) / $signed(i_A << 1);
//					temp_X2 = ($signed( { {4{i_B[3]}}, i_B } ) - sqrt) / $signed(i_A << 1);
					temp_X1 = ($signed(-i_B) + sqrt) / $signed(i_A << 1);
					temp_X2 = ($signed(-i_B) - sqrt) / $signed(i_A << 1);
				end
			end
		end 
		
	end
	

//===================================================================
// KHỐI CHỐT TÍN HIỆU - SỬ DỤNG LATCH CÓ CHỦ ĐÍCH
// Latching Block - Using an Intentional Latch
//===================================================================
// Lưu ý: Tín hiệu ra vẫn phải là 'reg' vì nó được gán trong khối always.
// Khối always này nhạy cảm với MỌI sự thay đổi của tín hiệu đầu vào.
 // Khối Latch để chốt kết quả từ temp_* ra o_*
    always @(*) begin
        if (~i_enable) begin
            o_result = temp_result;
            case (temp_result)
                2'b01: o_X1 = temp_X1;
                2'b10: o_X1 = temp_X1;
                2'b11: begin
                    o_X1 = temp_X1;
                    o_X2 = temp_X2;
                end
                default: begin
                    o_X1 = 8'd0;
                    o_X2 = 8'd0;
                end
            endcase
        end
        // Khi i_enable = 1, không có 'else', Latch sẽ giữ giá trị
    end
	 
		// Tạo một thực thể của display_7seg để kết nối logic tính toán với các đèn LED
//===================================================================
    // ===== KHỐI LOGIC SỬA LỖI: Chuyển đổi từ Bù 2 sang Dấu-Độ Lớn =====
    //===================================================================
    // Logic cho X1
    wire       x1_sign         = o_X1[7];                      // Bit dấu là bit cao nhất của số bù 2
    wire [7:0] x1_abs_val      = (x1_sign) ? -o_X1 : o_X1;     // Lấy giá trị tuyệt đối
    wire [4:0] x1_display_data = {x1_sign, x1_abs_val[3:0]};   // Ghép lại thành {dấu, độ lớn 4-bit}

    // Logic cho X2
    wire       x2_sign         = o_X2[7];
    wire [7:0] x2_abs_val      = (x2_sign) ? -o_X2 : o_X2;
    wire [4:0] x2_display_data = {x2_sign, x2_abs_val[3:0]};

    //===================================================================
    // Display Driver Instantiation
    //===================================================================
    display_7seg quad_display (
        .X1_out(x1_display_data),   // <--- ĐÃ SỬA: Dùng dữ liệu đã chuyển đổi
        .X2_out(x2_display_data),   // <--- ĐÃ SỬA: Dùng dữ liệu đã chuyển đổi

        .seg1(HEX1),                // X1 sign
        .seg2(HEX0),                // X1 magnitude
        .seg3(HEX3),                // X2 sign
        .seg4(HEX2)                 // X2 magnitude
    );
	 
	 
//always @(*) begin
//    case (o_result)
//			00: 	display_state = "Vo Nghiem";
//			01: 	display_state = "1 Nghiem";
//			10: 	display_state = "Nghiem Kep";
//			11: 	display_state = "2 Nghiem";
//    endcase
//end	 
	 
endmodule