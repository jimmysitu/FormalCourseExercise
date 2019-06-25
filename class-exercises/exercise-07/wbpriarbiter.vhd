--------------------------------------------------------------------------------
--
-- Filename: 	wbpriarbiter.vhd
--
-- Project:	A set of Yosys Formal Verification exercises
--
-- Purpose:	This is a priority bus arbiter.  It allows two separate wishbone
--		masters to connect to the same bus, while also guaranteeing
--	that one master can have the bus with no delay any time the other
--	master is not using the bus.  The goal is to eliminate the combinatorial
--	logic required in the other wishbone arbiter, while still guarateeing
--	access time for the priority channel.
--
--	The core logic works like this:
--
--	1. When no one requests the bus, 'A' is granted the bus and guaranteed
--		that any access will go right through.
--	2. If 'B' requests the bus (asserts cyc), and the bus is idle, then
--		'B' will be granted the bus.
--	3. Bus grants last as long as the 'cyc' line is high.
--	4. Once 'cyc' is dropped, the bus returns to 'A' as the owner.
--
--
-- Creator:	Dan Gisselquist, Ph.D.
--		Gisselquist Technology, LLC
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Copyright (C) 2015,2018, Gisselquist Technology, LLC
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
use ieee.numeric_std_unsigned.all;

entity	wbpriarbiter is

	generic(AW : natural := 32;
		DW : natural := 32;
		OPT_ZERO_ON_IDLE : std_logic := '0');

	port (i_clk, i_reset : in std_logic;
		-- Bus A
		i_a_cyc, i_a_stb, i_a_we : in std_logic;
		  i_a_adr : in std_logic_vector(AW-1 downto 0);
		  i_a_dat : in std_logic_vector(DW-1 downto 0);
		  i_a_sel : in std_logic_vector(DW/8 -1 downto 0);
		o_a_ack, o_a_stall, o_a_err : out std_logic;
		-- Bus B
		i_b_cyc, i_b_stb, i_b_we : in std_logic;
		  i_b_adr : in std_logic_vector(AW-1 downto 0);
		  i_b_dat : in std_logic_vector(DW-1 downto 0);
		  i_b_sel : in std_logic_vector(DW/8 -1 downto 0);
		o_b_ack, o_b_stall, o_b_err : out std_logic;
		-- Both busses, the output interface
		o_cyc, o_stb, o_we : out std_logic;
		  o_adr : out std_logic_vector(AW-1 downto 0);
		  o_dat : out std_logic_vector(DW-1 downto 0);
		  o_sel : out std_logic_vector(DW/8 -1 downto 0);
		i_ack, i_stall, i_err : in std_logic);

end entity wbpriarbiter;

architecture behavior of wbpriarbiter is
	signal r_a_owner : std_logic := '1';
begin
----
----

process(i_clk)
begin
  if (rising_edge(i_clk)) then
	-- Go high immediately (new cycle) if ...
	--	Previous cycle was low and *someone* is requesting a bus cycle
	-- Go low immadiately if ...
	--	We were just high and the owner no longer wants the bus
	-- WISHBONE Spec recommends no logic between a FF and the o_cyc
	--	This violates that spec.  (Rec 3.15, p35)
	if (i_b_cyc = '0') then
		r_a_owner <= '1';
	-- Allow B to set its CYC line w/o activating this interface
	elsif ((i_b_cyc = '1') and (i_b_stb = '1') and (i_a_cyc = '0')) then
		r_a_owner <= '0';
	end if;
  end if;
end process;


	-- Realistically, if neither master owns the bus, the output is a
	-- don't care.  Thus we trigger off whether or not 'A' owns the bus.
	-- If 'B' owns it all we care is that 'A' does not.  Likewise, if
	-- neither owns the bus than the values on these various lines are
	-- irrelevant.
	o_cyc <= i_a_cyc when (r_a_owner = '1') else i_b_cyc;
	o_stb <= i_a_stb when (r_a_owner = '1') else i_b_stb;
	o_we  <= i_a_we  when (r_a_owner = '1') else i_b_we;

process(all)
begin
	if (r_a_owner) then
		o_adr <= i_a_adr when(o_stb='1' or OPT_ZERO_ON_IDLE='0')
				else std_logic_vector(to_unsigned(0,AW));
		o_dat <= i_a_dat when(o_stb='1' or OPT_ZERO_ON_IDLE='0')
				else std_logic_vector(to_unsigned(0,DW));
		o_sel <= i_a_sel when(o_stb='1' or OPT_ZERO_ON_IDLE='0')
				else std_logic_vector(to_unsigned(0,DW/8));
		--
		o_a_ack   <= i_ack;
		o_a_stall <= i_stall;
		o_a_err   <= i_err;
		--
		-- We cannot allow the return acknowledgement to ever go
		-- high if the master in question does not own the bus.  Hence
		-- we force it low if the particular master doesn't own the bus.
		o_b_ack   <= '0';
		-- Stall must be asserted on the same cycle the input master
		-- asserts the bus, if the bus isn't granted to him.
		o_b_stall <= '1';
		o_b_err   <= '0';
	else
		o_adr <= i_b_adr when(o_stb='1' or OPT_ZERO_ON_IDLE='0')
				else std_logic_vector(to_unsigned(0,AW));
		o_dat <= i_b_dat when(o_stb='1' or OPT_ZERO_ON_IDLE='0')
				else std_logic_vector(to_unsigned(0,DW));
		o_sel <= i_b_sel when(o_stb='1' or OPT_ZERO_ON_IDLE='0')
				else std_logic_vector(to_unsigned(0,DW/8));
		--
		o_a_ack   <= '0';
		o_a_stall <= '1';
		o_a_err   <= '0';
		--
		o_b_ack   <= i_ack;
		o_b_stall <= i_stall;
		o_b_err   <= i_err;
	end if;
end process;

----
----
end behavior;
