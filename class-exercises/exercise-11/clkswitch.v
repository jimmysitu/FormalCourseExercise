////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	clkswitch.v
//
// Project:	A set of Yosys Formal Verification exercises
//
// Purpose:	This module implements a clock switch.  This clock switch will
//		switch between one of two incoming clocks to create an outgoing
//	clock based upon a switch input.  When the input switch is one way,
//	the first output clock is selected and output, otherwise the second
//	one.
//
// Assume:
//	1. Two clocks, one faster and one slower.
//
//	2. A select line
//
// To prove:
//
//	1. That there will be no glitches.  The outgoing clock should only
//		rise or fall when/if one of the incoming clocks does
//
//	2. That the outgoing clock will be no faster than either incoming
//		clock
//
//	3. That the clock is able to switch from one speed to another.
//		This requires a cover property
//
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2018, Gisselquist Technology, LLC
//
// This design implements the parts and components found within Mahmoud's
// EETimes article, "Techniques to make clock switching glitch free."
// To the extent that this design is copied from that article, Gisselquist
// Technology asserts no copyright claims.
//
// However, the formal properties at the end of the design are owned and
// copyrighted by Gisselquist Technology, LLC.  They are hereby released as
// free software (firmware): you can redistribute them and/or modify them
// under the terms of  the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
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
module clkswitch(i_clk_a, i_clk_b, i_areset_n, i_sel, o_clk);
	input	wire	i_clk_a, i_clk_b;
	input	wire	i_areset_n;
	input	wire	i_sel;
	output	wire	o_clk;

	reg		aff, bff, a_sel, b_sel;

	// First half of the synchronizer for A
	//
	// Set aff on the positive edge of clock A
	initial aff = 0;
	always @(posedge i_clk_a, negedge i_areset_n)
	if (!i_areset_n)
		aff = 1;
	else
		aff <= (i_sel)&&(!b_sel);

	// Second half of the synchronizer for A
	//
	// Set a_sel based upon the negative edge of clock A
	//
	initial a_sel = 0;
	always @(negedge i_clk_a, negedge i_areset_n)
	if (!i_areset_n)
		a_sel = 1;
	else
		a_sel <= aff;


	// The logic for B's side is identical, save that it is based
	// upon the negation of our select signal.

	initial bff = 0;
	always @(posedge i_clk_b, negedge i_areset_n)
	if (!i_areset_n)
		bff <= 0;
	else
		bff <= (!i_sel)&&(!a_sel);

	initial b_sel = 0;
	always @(negedge i_clk_b, negedge i_areset_n)
	if (!i_areset_n)
		b_sel <= 0;
	else
		b_sel <= bff;

	assign	o_clk = ((a_sel)&&(i_clk_a))
			||((b_sel)&&(i_clk_b));

`ifdef	FORMAL
	//
	// Your properties go here
	//
`endif
endmodule
