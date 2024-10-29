`define NAN  3
`define ZERO 2
`define INF  1
`define NORM 0



module bf16_add #(
    parameter EXP_WIDTH = 8,
    parameter SIG_WIDTH = 7, 
    parameter FLAG_WIDTH = 4
) (
    input [EXP_WIDTH+SIG_WIDTH:0] i_data_a,
    input [EXP_WIDTH+SIG_WIDTH:0] i_data_b,

    output reg [EXP_WIDTH+SIG_WIDTH:0] o_data,
    output reg [FLAG_WIDTH-1:0] o_flag
);

wire [FLAG_WIDTH-1:0] flag_a, flag_b;
wire signed [EXP_WIDTH-1:0] exp_a, exp_b;
wire [SIG_WIDTH-1:0] sig_a, sig_b;
wire sign_a, sign_b;

bf16_class m_class_a (
    i_data_a,
    flag_a,
    sig_a,
    exp_a,
    sign_a
);

bf16_class m_class_b (
    i_data_b,
    flag_b,
    sig_b,
    exp_b,
    sign_b
);


reg sign;

always @(*) begin
    
    o_flag = 4'b0000;
    sign = sign_a ^ sign_b;
    //augend -> larger number (no shifting needed)
    //addend -> smaller number (needs to be shifted)

    //handle edge cases -> zeros, inf and nan

    //handle nan
    if(flag_a[`NAN] | flag_b[`NAN]) begin
        o_data = flag_b[`NAN] ? i_data_b : i_data_a;
        o_flag[`NAN] = 1'b1;
    end
    //handle both zero
    else if(flag_a[`ZERO] & flag_b[`ZERO]) begin

        o_data = {sign_a&sign_b, 15'b0000000_00000000};
        o_flag[`ZERO] = 1'b1; 
    end
    //handle one zero
    else if(flag_a[`ZERO] | flag_b[`ZERO]) begin

        o_data = flag_b[`ZERO] ? i_data_a : i_data_b;
        o_flag[`ZERO] = 1'b1; 
    end
    //handle inf
    else if(flag_a[`INF] | flag_b[`INF]) begin
        
    end
    
    

    //compare inputs and extract augend and addend
    // if(exp_a < exp_b) begin
    //     sig_augend[SIG_WIDTH-1:0] = sig_b;
    //     sig_addend[SIG_WIDTH-1:0] = sig_a;
    //     sign_augend = sign_b;
    //     exp_augend = exp_b;
    //     shift_count = exp_b - exp_a;
    // end
    // else begin
    //     sig_augend[SIG_WIDTH-1:0] = sig_a;
    //     sig_addend[SIG_WIDTH-1:0] = sig_b;
    //     sign_augend = sign_a;
    //     exp_augend = exp_a;
    //     shift_count = exp_a - exp_b;
    // end

    // sig_addend_shifted = sig_addend >> shift_count;


end

endmodule