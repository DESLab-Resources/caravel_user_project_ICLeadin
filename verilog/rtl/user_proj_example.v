// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 5
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,

    // IOs
    input  [BITS-1:0] io_in,
    output [BITS-1:0] io_out,
    output [BITS-1:0] io_oeb,
);
    
    wire En = io_in[BITS-1], Clk = wb_clk_i, Clr = wb_rst_i;
    wire [BITS-2:0] Q;

    counter #(
        .BITS(BITS-1)
    ) counter(
        .En(En),
        .Clk(Clk),
        .Clr(Clr),
        .Q(Q)
    );

    assign io_out = {1'b0, Q};
    assign io_oeb = 5'd0;

endmodule

module counter 
    # (parameter BITS = 4) (
    En, Clk, Clr, Q
);
    input En, Clk, Clr;
    output reg [BITS-1:0] Q;

    always @(posedge Clk, negedge Clr) begin
        if(~Clr) begin
            Q <= 0;
        end
        else if(En) begin
            Q <= Q + 1;
        end
    end
endmodule
`default_nettype wire
