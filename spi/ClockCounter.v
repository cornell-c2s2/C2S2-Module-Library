/*
==========================================================================
ClockCounter.v
==========================================================================
Clock counter allows for sampling frequency adjustment

Author : Austin Brown
  Date : May 13, 2023

*/

module counter 
#(
    nbits = 32
)
(
    input  logic             clk,
    input  logic             reset,

    input  logic [nbits-1:0] clock_counter_msg,
    output logic             clock_counter_rdy,
    input  logic             clock_counter_val,

    input  logic             clock_counter_en_msg,
    output logic             clock_counter_en_rdy,
    input  logic             clock_counter_en_val,

    output logic             counter_flag
);

    logic [nbits-1:0] clock_counter;
    logic             clock_counter_en;
    logic [nbits-1:0] orig_value;


    always_ff @( posedge clk ) begin
        if (reset) orig_value <= 0;
        else if (clock_counter_val) begin
            orig_value <= clock_counter_msg;
        end

    end
    
    always_ff @( posedge clk ) begin
        if (reset) begin
            clock_counter <= 0;
            counter_flag <= 0;
        end
        else if (clock_counter_val) begin
            clock_counter <= clock_counter_msg;
            counter_flag <= 0;
        end
        else if (clock_counter_en) begin
            clock_counter <= clock_counter - 1;
            if (!clock_counter) begin
                counter_flag <= 1;
                clock_counter <= orig_value;
            end
        end
    end

endmodule