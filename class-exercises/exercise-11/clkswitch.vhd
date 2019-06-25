--------------------------------------------------------------------------------
--
-- Filename: 	clkswitch.v
--
-- Project:	A set of Yosys Formal Verification exercises
--
-- Purpose:	This module implements a clock switch.  This clock switch will
--		switch between one of two incoming clocks to create an outgoing
--	clock based upon a switch input.  When the input switch is one way,
--	the first output clock is selected and output, otherwise the second
--	one.
--
-- Assume:
--	1. Two clocks, one faster and one slower.
--
--	2. A select line
--
-- To prove:
--
--	1. That there will be no glitches.  The outgoing clock should only
--		rise or fall when/if one of the incoming clocks does
--
--	2. That the outgoing clock will be no faster than either incoming
--		clock
--
--	3. That the clock is able to switch from one speed to another.
--		This requires a cover property
--
--
-- Creator:	Dan Gisselquist, Ph.D.
--		Gisselquist Technology, LLC
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- This design implements the parts and components found within Mahmoud's
-- EETimes article, "Techniques to make clock switching glitch free."
-- To the extent that this design is copied from that article, Gisselquist
-- Technology asserts no copyright claims.
--
-- However, the formal properties at the end of the design are owned and
-- copyrighted by Gisselquist Technology, LLC.  They are hereby released as
-- free software (firmware): you can redistribute them and/or modify them
-- under the terms of  the GNU General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option)
-- any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for more details.
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

entity clkswitch is

	port	(i_clk_a, i_clk_b, i_areset_n : in std_logic;
		i_sel : in std_logic;
		o_clk : out std_logic := '0');

end entity clkswitch;

architecture behavior of clkswitch is
	signal aff, a_sel : std_logic := '1';
	signal bff, b_sel : std_logic := '0';
-----
-----
begin

	-- First half of the synchronizer for A
	--
	-- Set aff on the positive edge of clock A
	process(i_clk_a, i_areset_n)
	begin
		if (i_areset_n = '0') then
			aff <= '1';
		elsif (rising_edge(i_clk_a)) then
			aff <= '1' when (i_sel = '1') and (b_sel = '0') else '0';
		end if;
	end process;

	-- Second half of the synchronizer for A
	--
	-- Set a_sel based upon the negative edge of clock A
	--
	process(i_clk_a, i_areset_n)
	begin
		if (i_areset_n = '0') then
			a_sel <= '1';
		elsif (falling_edge(i_clk_a)) then
			a_sel <= aff;
		end if;
	end process;

--
-- Now repeat the above logic, but for bff and b_sel
--
-- The logic for B's side is identical, save that it is based
-- upon the negation of our select signal.
--

	process(i_clk_b, i_areset_n)
	begin
		if (i_areset_n = '0') then
			bff <= '0';
		elsif (rising_edge(i_clk_b)) then
			bff <= '1' when (i_sel = '0') and (a_sel = '0') else '0';
		end if;
	end process;

	process(i_clk_b, i_areset_n)
	begin
		if (i_areset_n = '0') then
			b_sel <= '0';
		elsif (falling_edge(i_clk_b)) then
			b_sel <= bff;
		end if;
	end process;


--
-- Finally, generate the outgoing clock itself
--

	process(all)
	begin
		if ((a_sel = '1') and (i_clk_a = '1')) then
			o_clk <= '1';
		elsif ((b_sel = '1') and (i_clk_b = '1')) then
			o_clk <= '1';
		else
			o_clk <= '0';
		end if;
	end process;

-----
-----
end behavior;
