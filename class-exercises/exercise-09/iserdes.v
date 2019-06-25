////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	iserdes.v
//
// Project:	A set of Yosys Formal Verification exercises
//
// Purpose:	An example input SERDES operator
//
// Assume:
//	1. Two clocks, where one clock (i_fast_clk) is exactly WIDTH
//		times faster than (i_slow_clk), and where
//
//	2. i_slow_clock and i_fast_clock share a positive edge transition
//
// To prove:
//
//	1. That the output returned on the positive edge of the slow clock,
//		is the input that was received
//
//	2. That the slow clock outputs are stable, over the slow clock
//
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2018, Gisselquist Technology, LLC
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
module iserdes(i_slow_clk, i_fast_clk, i_areset_n, i_pin, o_word);
	//
	parameter			WIDTH=10;
	parameter	[(WIDTH-1):0]	RESET_VALUE = 0;
	//
	input	wire			i_slow_clk, i_fast_clk, i_areset_n;
	//
	input	wire			i_pin;
	output	reg	[(WIDTH-1):0]	o_word;

	reg	[WIDTH-1:0]	r_word;

	//
	// The basic input SERDESE operator
	//
	always @(posedge i_fast_clk, negedge i_areset_n)
	if (!i_areset_n)
		r_word <= RESET_VALUE;
	else
		r_word <= { r_word[(WIDTH-2):0], i_pin };

	always @(posedge i_slow_clk, negedge i_areset_n)
	if (!i_areset_n)
		o_word <= RESET_VALUE;
	else
		o_word <= { r_word[(WIDTH-2):0], i_pin };

`ifdef	FORMAL
`endif
endmodule
