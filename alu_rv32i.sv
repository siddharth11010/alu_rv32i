`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2026 10:28:33 AM
// Design Name: 
// Module Name: alu_rv32i
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

module alu_rv32i (
    input  [31:0] A,          // First operand (rs1 / PC)
    input  [31:0] B,          // Second operand (rs2 / Immediate)
    input  [3:0]  alu_op,     // ALU operation control signal
    output reg [31:0] Y,      // ALU result
    output        zero        // Zero flag (High if Y == 0, used for branch instructions)
);

    // Operation Decoding Constants (Matching standard RISC-V ALU Encodings)
    localparam ALU_ADD  = 4'b0000; // Addition
    localparam ALU_SUB  = 4'b0001; // Subtraction
    localparam ALU_SLL  = 4'b0010; // Shift Left Logical
    localparam ALU_SLT  = 4'b0011; // Set Less Than (Signed)
    localparam ALU_SLTU = 4'b0100; // Set Less Than (Unsigned)
    localparam ALU_XOR  = 4'b0101; // Bitwise XOR
    localparam ALU_SRL  = 4'b0110; // Shift Right Logical
    localparam ALU_SRA  = 4'b0111; // Shift Right Arithmetic
    localparam ALU_OR   = 4'b1000; // Bitwise OR
    localparam ALU_AND  = 4'b1001; // Bitwise AND

    // Shared 33-bit subtractor helper variables
    wire [32:0] sub_res;
    wire        slt_val;
    wire        sltu_val;

    // Subtraction and comparison datapath
    assign sub_res  = {1'b0, A} - {1'b0, B};
    assign sltu_val = (A < B); // Alternatively derived from ~sub_res[32]
    
    // Signed Comparison Logic:
    // Handles corner cases where sign bits differ to prevent overflow misinterpretations
    assign slt_val  = (A[31] != B[31]) ? A[31] : sub_res[31];

    // Execution Combinational Logic
    always @(*) begin
        case (alu_op)
            ALU_ADD:  Y = A + B;
            ALU_SUB:  Y = sub_res[31:0];
            ALU_SLL:  Y = A << B[4:0];                          // Shift amount uses lower 5 bits
            ALU_SLT:  Y = {31'b0, slt_val};
            ALU_SLTU: Y = {31'b0, sltu_val};
            ALU_XOR:  Y = A ^ B;
            ALU_SRL:  Y = A >> B[4:0];                          // Zero-filled shift right
            ALU_SRA:  Y = $signed(A) >>> B[4:0];                // Sign-extended shift right
            ALU_OR:   Y = A | B;
            ALU_AND:  Y = A & B;
            default:  Y = 32'h0000_0000;
        endcase
    end

    // Zero flag output generation (Used for BEQ/BNE branch resolution)
    assign zero = (Y == 32'h0000_0000);

endmodule
