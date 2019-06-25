////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	pastassert.v
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
// Copyright (C) 2017, Gisselquist Technology, LLC
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
module	pastassert(i_clk, i_start_signal, o_busy);
	parameter	[15:0]	MAX_AMOUNT = 22;
	parameter		F_TESTID=1;
	//
	input	wire	i_clk;
	//
	input	wire	i_start_signal;
	output	reg	o_busy;

	reg	[15:0]	counter;

	//
	// This counter will start anytime i_start_signal is true.
	//
	// Once i_start_ignal is true, and the counter == 0 (i.e. is idle),
	// the counter will be restarted.
	//
	initial	counter = 0;
	always @(posedge i_clk)
		if ((i_start_signal)&&(counter == 0))
			counter <= MAX_AMOUNT-1'b1;
		else if (counter != 0)
			counter <= counter - 1'b1;

	always @(*)
		o_busy <= (counter != 0);

`ifdef	FORMAL
	// Our property from before
	always @(*)
		assert(counter < MAX_AMOUNT);

	reg	f_past_valid;

	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	generate if (F_TESTID == 1)
	begin : F_TESTID_ONE	// Fails

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
			assert($past(counter == 0));

	end else if (F_TESTID == 2)
	begin : F_TESTID_TWO	// Succeeds

		//
		// Test #2
		always @(*)
			assume(!i_start_signal);
	
		//
		// Because this never references the past, it will succeed
		always @(posedge i_clk)
			assert(counter == 0);

	end else if (F_TESTID == 3)
	begin : F_TESTID_THREE	// Fails

		//
		// Test #3
		always @(posedge i_clk)
		if (($past(i_start_signal))&&($past(counter)==0))
			assert(counter == MAX_AMOUNT-1'b1);

	end else if (F_TESTID == 4)
	begin : F_TESTID_FOUR

		//
		// Test #4
		reg	f_past_valid;
		initial	f_past_valid = 1'b0;
		always @(posedge i_clk)
			f_past_valid <= 1'b1;

		always @(posedge i_clk)
		if ((f_past_valid)&&($past(i_start_signal))
				&&($past(counter == 0)))
			assert(counter == MAX_AMOUNT-1'b1);

	end endgenerate
`endif
endmodule
