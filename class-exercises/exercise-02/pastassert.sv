////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	pastassert_vhd.sv
//
// Project:	A set of Yosys Formal Verification exercises
//
// Background:	
//
// To Prove:
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2017-2018, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of  the GNU General Public License as published
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
module	pastassert_vhd(i_clk, i_start_signal, o_busy, counts);
	parameter	[15:0]	MAX_AMOUNT = 22;
	parameter		TESTID=1;
	//
	input	wire	i_clk;
	//
	input	wire	i_start_signal;
	input	wire	o_busy;

	input	wire [15:0] counter;

`ifdef	FORMAL
	// Our property from before
	always @(*)
		assert(counts < MAX_AMOUNT);

	reg	f_past_valid;

	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	generate if (TESTID == 1)
	begin : TESTID_ONE	// Fails

		//
		// Test #1
		//
		// if i_start_signal is never true, then the counter should
		// never leave zero.
		always @(*)
			assume(!i_start_signal);

		//
		// assert that the counter was zero on the last clock.
		// This will fail, since the counter could easily be something
		// other than its initial value prior to the start of time
		always @(posedge i_clk)
			assert($past(counts == 0));

	end else if (TESTID == 2)
	begin : TESTID_TWO	// Succeeds

		//
		// Test #2
		always @(*)
			assume(!i_start_signal);
	
		//
		// Because this never references the past, it will succeed
		always @(posedge i_clk)
			assert(counts == 0);

	end else if (TESTID == 3)
	begin : TESTID_THREE	// Fails

		//
		// Test #3
		always @(posedge i_clk)
		if (($past(i_start_signal))&&($past(counts)==0))
			assert(counts == MAX_AMOUNT-1'b1);

	end else if (TESTID == 4)
	begin : TESTID_FOUR

		//
		// Test #4
		reg	f_past_valid;
		initial	f_past_valid = 1'b0;
		always @(posedge i_clk)
			f_past_valid <= 1'b1;

		always @(posedge i_clk)
		if ((f_past_valid)&&($past(i_start_signal))
				&&($past(counts == 0)))
			assert(counts == MAX_AMOUNT-1'b1);

	end endgenerate
`endif
endmodule

bind past_assert pastassert_vhd #(.MAX_AMOUNT(MAX_AMOUNT)) copy (.*);
