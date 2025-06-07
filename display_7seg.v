module display_7seg(
    input [4:0] X1_out,  // [sign][4-bit magnitude]
    input [4:0] X2_out,
    output wire [6:0] seg1,   // X1 hàng chục (dấu)
    output wire [6:0] seg2,   // X1 hàng đơn vị (số)
    output wire [6:0] seg3,   // X2 hàng chục (dấu)
    output wire [6:0] seg4    // X2 hàng đơn vị (số)
);

    wire [3:0] x1_mag = X1_out[3:0];         // Trị tuyệt đối của X1
    wire [3:0] x2_mag = X2_out[3:0];         // Trị tuyệt đối của X2
    wire x1_sign = X1_out[4];                // Bit dấu
    wire x2_sign = X2_out[4];

    // Nếu số âm → mã 10 ('-'), nếu dương → mã 15 (blank)
    wire [3:0] x1_sign_bcd = (x1_sign) ? 4'd10 : 4'd15;
    wire [3:0] x2_sign_bcd = (x2_sign) ? 4'd10 : 4'd15;

    // Hiển thị trị tuyệt đối
    bcd_to_7seg seg_x1_mag (
        .bcd(x1_mag),
        .seg(seg2)
    );

    bcd_to_7seg seg_x2_mag (
        .bcd(x2_mag),
        .seg(seg4)
    );

    // Hiển thị dấu hoặc trống
    bcd_to_7seg seg_x1_sign (
        .bcd(x1_sign_bcd),
        .seg(seg1)
    );

    bcd_to_7seg seg_x2_sign (
        .bcd(x2_sign_bcd),
        .seg(seg3)
    );

endmodule
