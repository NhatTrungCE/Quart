`timescale 1ns / 1ps

module tb_pa1_combination();

    // Inputs -> phải là kiểu 'reg' trong testbench
    reg               i_enable;
    reg signed [3:0]  i_A;
    reg signed [3:0]  i_B;
    reg signed [3:0]  i_C;
	 
    // Outputs -> phải là kiểu 'wire' trong testbench
    wire signed [1:0] o_result;
    wire signed [7:0] o_X1;
    wire signed [7:0] o_X2;
	 
	 // Đây là các dây tín hiệu để bắt lấy kết quả 7 đoạn
    wire [6:0] HEX0, HEX1, HEX2, HEX3;
	 
// ===== BỔ SUNG 1: Khai báo reg để lưu ký tự đã giải mã =====
    reg [7:0] decoded_HEX0, decoded_HEX1, decoded_HEX2, decoded_HEX3;

    
        // Khởi tạo module cần test (Device Under Test - DUT)
    pa1_combination dut (
        .i_enable(i_enable),
        .i_A(i_A),
        .i_B(i_B),
        .i_C(i_C),
        .o_result(o_result),
        .o_X1(o_X1),
        .o_X2(o_X2),
		  .HEX3(HEX3),
        .HEX2(HEX2),
        .HEX1(HEX1),
        .HEX0(HEX0)
    );

// ===== BỔ SUNG 2: Function giải mã ngược (đặt ở đây) =====
    function [7:0] seven_seg_to_char;
        input [6:0] seg_pattern;
        begin
            case (seg_pattern)
                7'b1000000: seven_seg_to_char = "0"; 
					 7'b1111001: seven_seg_to_char = "1";
                7'b0100100: seven_seg_to_char = "2"; 
					 7'b0110000: seven_seg_to_char = "3";
                7'b0011001: seven_seg_to_char = "4"; 
					 7'b0010010: seven_seg_to_char = "5";
                7'b0000010: seven_seg_to_char = "6"; 
					 7'b1111000: seven_seg_to_char = "7";
                7'b0000000: seven_seg_to_char = "8"; 
					 7'b0010000: seven_seg_to_char = "9";
                7'b0111111: seven_seg_to_char = "-"; 
					 7'b1111111: seven_seg_to_char = " ";
                default:    seven_seg_to_char = "E";
            endcase
        end
    endfunction	 

// ===== BỔ SUNG 3: Khối always để tự động gọi function =====
    // Khối này sẽ chạy mỗi khi giá trị của HEX thay đổi
    always @(*) begin
        decoded_HEX1 = seven_seg_to_char(HEX1); // Dấu của X1
        decoded_HEX0 = seven_seg_to_char(HEX0); // Giá trị của X1
        decoded_HEX3 = seven_seg_to_char(HEX3); // Dấu của X2
        decoded_HEX2 = seven_seg_to_char(HEX2); // Giá trị của X2
    end
	 
    // Khối chính để điều khiển các tín hiệu test
    initial begin
        // Các lệnh để tạo file sóng (waveform)
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_pa1_combination);

        // ===== Trạng thái ban đầu =====
        i_A      = 0;
        i_B      = 0;
        i_C      = 0;
        i_enable = 1; // Latch đang đóng (không cho tín hiệu qua)
		  #30; // Đợi 10ns

        // ===== Test Case 1: 2 nghiệm (x1 = 2, x2 = 1 =====
        i_A = 1;
        i_B = -3; // 4'b1011
        i_C = 2;  // 4'b0110
		  i_enable = 0;
		  #12;
		  i_enable = 1;
		  #30; // Đợi 10ns
		          // ===== Test Case 2: nghiệm kép (x1 = -1 =====
        i_A = 1;
        i_B = 2; // 4'b1011
        i_C = 1;  // 4'b0110
		  i_enable = 0;
		  #12;
		  i_enable = 1;
		  #30;
		  
		   // ===== Test Case 3: vô nghiệm (x1 = 0 =====
        i_A = 1;
        i_B = 1; // 4'b1011
        i_C = 1;  // 4'b0110
		  i_enable = 0;
		  #12;
		  i_enable = 1;
		  #30;
		  
		   // ===== Test Case 4: 2 nghiệm (x1 = -3, x2 = 1 =====
        i_A = -1;
        i_B = -2; // 4'b1011
        i_C = 3;  // 4'b0110
		  i_enable = 0;
		  #12;
		  i_enable = 1;
		  #30;
		  
		  		   // ===== Test Case 5: vo nghiệm (x1 = 0 =====
        i_A = -1;
        i_B = 0; // 4'b1011
        i_C = -4;  // 4'b0110
		  i_enable = 0;
		  #12;
		  i_enable = 1;
		  #30;
		  
		  		   // ===== Test Case 6: 2 nghiệm (x1 = 2, x2 = -3 =====
        i_A = 1;
        i_B = 1; // 4'b1011
        i_C = -6;  // 4'b0110
		  i_enable = 0;
		  #12;
		  i_enable = 1;
		  #30;
		  
		  		  		   // ===== Test Case 7: ptb1 (x1 = -3 =====
        i_A = 0;
        i_B = 2; // 4'b1011
        i_C = 6;  // 4'b0110
		  i_enable = 0;
		  #12;
		  i_enable = 1;
		  #30;
        
        $display("Time=%0t: Simulation Finished.", $time);
        #20 $stop;
    end
   

endmodule