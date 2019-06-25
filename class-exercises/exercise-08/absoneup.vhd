--------------------------------------------------------------------------------
--
-- Filename: 	absoneup.vhd
--
-- Project:	A set of Yosys Formal Verification exercises
--
-- Background:	A 32'bit counter will roll over every 2^32 clocks.  On
--	that rollover, adding one to the counter will set a carry bit as well.
--	This carry bit can be used externally to cause events to happen on
--	some predefined interval.
--
--	The problem with this is that it may take a *lot* of simulation (or
--	formal) clock ticks to prove that something works that only steps
--	every second.
--
--	This module illustrates how an o_carry value can be calculated
--	in an abstract fashion.  This abstract version *includes* the
--	functionality of the non-abstract clock, but also allows the
--	counter to step forward much faster than simulation time.
--
-- To Prove:
--
--	1. That o_carry still takes place anytime the counter rolls over.
--
--	2. That o_carry is never true on any other clock cycles.
--
--	3. That any time o_carry is true, the counter must be equal to zero.
--
--	4. That prior to any clock where o_carry is true, the counter must be
--		equal to -1.
--
--
-- Creator:	Dan Gisselquist, Ph.D.
--		Gisselquist Technology, LLC
--
--------------------------------------------------------------------------------
--
-- Copyright (C) 2018, Gisselquist Technology, LLC
--
-- This program is free software (firmware): you can redistribute it and/or
-- modify it under the terms of  the GNU General Public License as published
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
--
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity absoneup is

  generic (OPT_ABSTRACT : bit := '1');

  port(i_clk : in std_logic;
	o_carry : out std_logic := '0');

end entity absoneup;

architecture behavior of absoneup is
	signal r_count   : unsigned(31 downto 0) := x"00000001";
	signal increment : unsigned(31 downto 0);

	attribute anyseq : bit;
	attribute anyseq of increment : signal is OPT_ABSTRACT;
begin
-----
-----

process(i_clk)
begin
  if (rising_edge(i_clk)) then
    if (OPT_ABSTRACT = '1') then
      (o_carry, r_count) <= resize(r_count, 33)
                          + resize(increment, 33);
    else
      (o_carry, r_count) <= resize(r_count, 33) + 1;
    end if;
  end if;
end process;

-----
-----
end behavior;
