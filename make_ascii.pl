#!/usr/bin/perl

#  Tau - a reasonably fast syntax highlighter.
#  Copyright (C) 2021 Kamila Szewczyk
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.

while(<>) {
    if($_ =~ /^\[[ \t]*grammar[ \t]*\]$/) {
        print; print "AIDENT    [A-Za-z_][A-Za-z0-9_]+\n";
        print "IDSTART    [A-Za-z_]\n";
        while(<>) { print; }
        exit;
    } else {
        s/^\[[ \t]*reader[ \t]*wstr[ \t]*\]$/[reader str]/;
        s/^\[[ \t]*unicode[ \t]*1[ \t]*\]\n//;
        s/^\[[ \t]*identifier(.*)\]$/[identifier {AIDENT}]/;
        s/^\[[ \t]*syntax[ \t]*(.*)\]$/[syntax \1_a]/;
        s/^\[[ \t]*viewkind[ \t]*wstring_view[ \t]*\]$/[viewkind string_view]/;
        s/^\[[ \t]*idstart[ \t]*.*[ \t]*\]$/[idstart {IDSTART}]/;
        s/^\[[ \t]*idpart[ \t]*.*[ \t]*\]$/[idpart A-Za-z0-9_]/;
        s/^\[[ \t]*strkind[ \t]*wstring[ \t]*\]$/[strkind string]/;
        s/^\[[ \t]*literalprefix[ \t]*L[ \t]*\]$/[literalprefix]/;
        print;
    }
}
