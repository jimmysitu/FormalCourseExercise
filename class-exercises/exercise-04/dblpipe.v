////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	dblpipe.v
//
// Project:	A set of Yosys Formal Verification exercises
//
// Background:	This file contains a pair of LFSR modules.  They "should" be
//		identical.
//
// To prove:
//
//	1. That nothing changes as long as CE is low
//
//	2. That the outputs of the two LFSR's are identical, and hence the
//		output, o_data, will be forever zero.
//
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2017, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module dblpipe(i_clk,
		i_ce, i_data, o_data);
	input	wire	i_clk, i_ce;
	//
	input	wire	i_data;
	output	wire	o_data;

	wire	a_data, b_data;

	lfsr_fib	one(i_clk, 1'b0, i_ce, i_data, a_data);
	lfsr_fib	two(i_clk, 1'b0, i_ce, i_data, b_data);

	initial	o_data = 1'b0;
	always @(posedge i_clk)
		o_data <= a_data ^ b_data;

`ifdef FORMAL
    always @(*)
        assert(!o_data);
`endif
endmodule
