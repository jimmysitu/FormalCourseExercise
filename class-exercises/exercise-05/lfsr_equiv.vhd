--------------------------------------------------------------------------------
--
-- Filename: 	lfsr_equiv.vhd
--
-- Project:	DSP Filtering Example Project
--
-- Purpose:	This is a formal proof that the two types of LRS's, Fibonacci
--		and Galois, are equivalent expressions of the same underlying
--	function.
--
--	The CE line is also a challenge to include, making this a potentially
--	difficult proof.
--
-- Creator:	Dan Gisselquist, Ph.D.
--		Gisselquist Technology, LLC
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Copyright (C) 2017, Gisselquist Technology, LLC
--
-- This program is free software (firmware): you can redistribute it and/or
-- modify it under the terms of the GNU General Public License as published
-- by the Free Software Foundation, either version 3 of the License, or (at
-- your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for more details.
--
-- You should have received a copy of the GNU General Public License along
-- with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
-- target there if the PDF file isn't present.)  If not, see
-- <http://www.gnu.org/licenses/> for a copy.
--
-- License:	GPL, v3, as defined and found on www.gnu.org,
--		http://www.gnu.org/licenses/gpl.html
--
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr_equiv is
	generic (
		LN : natural := 8;
		FIB_TAPS : std_logic_vector(LN-1 downto 0) := x"2d";
		GAL_TAPS : std_logic_vector(LN-1 downto 0) := x"b4";
		INITIAL_FILL : std_logic_vector(LN-1 downto 0) := x"80");
	port (i_clk, i_reset, i_ce, i_in : in std_logic;
		o_bit : out std_logic := '0');

end entity lfsr_equiv;

architecture behavior of lfsr_equiv is
	component lfsr_fib
	  generic (LN : natural;
		TAPS : std_logic_vector(LN-1 downto 0);
		INITIAL_FILL : std_logic_vector(LN-1 downto 0));
	  port(i_clk, i_reset, i_ce, i_in : in std_logic;
		o_bit : out std_logic);
	end component;
	component lfsr_gal
	  generic (LN : natural;
		TAPS : std_logic_vector(LN-1 downto 0);
		INITIAL_FILL : std_logic_vector(LN-1 downto 0));

	  port(i_clk, i_reset, i_ce, i_in : in std_logic;
		o_bit : out std_logic);
	end component;

	signal	a_data, b_data : std_logic;
begin
----
----

fib: lfsr_fib
	generic map (LN => LN, TAPS => FIB_TAPS, INITIAL_FILL => INITIAL_FILL)
	port map (i_clk => i_clk,
		i_reset => i_reset,
		i_ce => i_ce,
		i_in => i_in,
		o_bit => a_data);

gal: lfsr_gal
	generic map (LN => LN, TAPS => GAL_TAPS, INITIAL_FILL => INITIAL_FILL)
	port map (
		i_clk => i_clk,
		i_reset => i_reset,
		i_ce => i_ce,
		i_in => i_in,
		o_bit => b_data);

o_bit <= a_data xor b_data;

----
----
end behavior;
