`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2026 10:30:59 AM
// Design Name: 
// Module Name: tb_alu_rv32i
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_alu_rv32i;

    // Testbench Signals
    reg  [31:0] A;
    reg  [31:0] B;
    reg  [3:0]  alu_op;
    wire [31:0] Y;
    wire        zero;

    // Error Tracking
    integer error_count = 0;
    integer test_count  = 0;

    // Operation Decoding Constants (Matching Module Under Test)
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_SLL  = 4'b0010;
    localparam ALU_SLT  = 4'b0011;
    localparam ALU_SLTU = 4'b0100;
    localparam ALU_XOR  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_OR   = 4'b1000;
    localparam ALU_AND  = 4'b1001;

    // Instantiate Unit Under Test (UUT)
    alu_rv32i uut (
        .A(A),
        .B(B),
        .alu_op(alu_op),
        .Y(Y),
        .zero(zero)
    );

    // Verification Task
    task check_result;
        input [31:0] expected_Y;
        input        expected_zero;
        input [256:1] test_name;
        begin
            test_count = test_count + 1;
            #1; // Allow combinational settling
            if (Y !== expected_Y || zero !== expected_zero) begin
                $display("[FAIL] Test %0d (%s): A=0x%h, B=0x%h, op=%b | Expected: Y=0x%h, Zero=%b | Got: Y=0x%h, Zero=%b", 
                         test_count, test_name, A, B, alu_op, expected_Y, expected_zero, Y, zero);
                error_count = error_count + 1;
            end else begin
                $display("[PASS] Test %0d (%s): Y=0x%h, Zero=%b", test_count, test_name, Y, zero);
            end
        end
    endtask

    initial begin
        $display("==================================================");
        $display("       STARTING RV32I ALU SELF-CHECKING TB        ");
        $display("==================================================");

        // ----------------------------------------------------
        // 1. ARITHMETIC OPERATIONS & ZERO FLAG
        // ----------------------------------------------------
        alu_op = ALU_ADD; A = 32'h0000_000F; B = 32'h0000_0001;
        check_result(32'h0000_0010, 1'b0, "ADD Basic");

        alu_op = ALU_SUB; A = 32'h0000_000F; B = 32'h0000_0001;
        check_result(32'h0000_000E, 1'b0, "SUB Basic");

        // Zero Flag Check (Equal inputs subtraction)
        alu_op = ALU_SUB; A = 32'h1234_5678; B = 32'h1234_5678;
        check_result(32'h0000_0000, 1'b1, "SUB Equal -> Zero Flag High");

        // ----------------------------------------------------
        // 2. SHIFT OPERATIONS (SLL, SRL, SRA)
        // ----------------------------------------------------
        // SLL (Logical Shift Left)
        alu_op = ALU_SLL; A = 32'h0000_0001; B = 32'd4;
        check_result(32'h0000_0010, 1'b0, "SLL Shift Left 4 bits");

        // SRL (Logical Shift Right - Zero extension)
        alu_op = ALU_SRL; A = 32'hF000_0000; B = 32'd4;
        check_result(32'h0F00_0000, 1'b0, "SRL Zero-fill Right Shift");

        // SRA (Arithmetic Shift Right - Sign extension)
        alu_op = ALU_SRA; A = 32'h8000_0000; B = 32'd4;
        check_result(32'hF800_0000, 1'b0, "SRA Sign-extended Shift (Negative)");

        // Shift Amount > 31 Check (Uses B[4:0] only -> 36 & 31 = 4)
        alu_op = ALU_SLL; A = 32'h0000_0001; B = 32'd36; 
        check_result(32'h0000_0010, 1'b0, "SLL Truncated Shift Amount B[4:0]");

        // ----------------------------------------------------
        // 3. COMPARISON OPERATIONS & CORNER CASES (SLT / SLTU)
        // ----------------------------------------------------
        // SLT: Both Positive (3 < 5)
        alu_op = ALU_SLT; A = 32'd3; B = 32'd5;
        check_result(32'h0000_0001, 1'b0, "SLT Signed Pos < Pos (True)");

        // SLT: Positive vs Negative (+3 < -5 -> False)
        alu_op = ALU_SLT; A = 32'd3; B = -32'd5;
        check_result(32'h0000_0000, 1'b1, "SLT Signed Pos < Neg (False)");

        // SLT: Negative vs Positive (-5 < +3 -> True)
        alu_op = ALU_SLT; A = -32'd5; B = 32'd3;
        check_result(32'h0000_0001, 1'b0, "SLT Signed Neg < Pos (True)");

        // SLT Signed Overflow Corner Case: Large Positive vs Large Negative
        // A = +2,147,483,647 (0x7FFFFFFF), B = -2 (-32'd2)
        // Subtraction A - B overflows 32-bit signed int, but SLT must handle signs correctly!
        alu_op = ALU_SLT; A = 32'h7FFF_FFFF; B = -32'd2;
        check_result(32'h0000_0000, 1'b1, "SLT Overflow Handling (+Max < -2)");

        // SLTU: Unsigned Comparison (0xFFFFFFFF > 0x00000001)
        alu_op = ALU_SLTU; A = 32'hFFFF_FFFF; B = 32'h0000_0001;
        check_result(32'h0000_0000, 1'b1, "SLTU Unsigned 0xFFFFFFFF < 0x1 (False)");

        // SLTU: Unsigned Comparison (0x00000001 < 0xFFFFFFFF)
        alu_op = ALU_SLTU; A = 32'h0000_0001; B = 32'hFFFF_FFFF;
        check_result(32'h0000_0001, 1'b0, "SLTU Unsigned 0x1 < 0xFFFFFFFF (True)");

        // ----------------------------------------------------
        // 4. BITWISE LOGIC OPERATIONS
        // ----------------------------------------------------
        alu_op = ALU_AND; A = 32'hFF00_AA55; B = 32'hF0F0_FFFF;
        check_result(32'hF000_AA55, 1'b0, "AND Basic");

        alu_op = ALU_OR;  A = 32'hFF00_0000; B = 32'h0000_AA55;
        check_result(32'hFF00_AA55, 1'b0, "OR Basic");

        alu_op = ALU_XOR; A = 32'hFFFF_FFFF; B = 32'h1234_5678;
        check_result(32'hEDCB_A987, 1'b0, "XOR Basic");

        // ----------------------------------------------------
        // SUMMARY
        // ----------------------------------------------------
        $display("==================================================");
        if (error_count == 0) begin
            $display("   TEST PASSED SUCCESSFULLY (%0d/%0d TESTS)", test_count, test_count);
        end else begin
            $display("   TEST FAILED WITH %0d ERRORS OUT OF %0d TESTS", error_count, test_count);
        end
        $display("==================================================");

        $finish;
    end

endmodule
