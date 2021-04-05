#!/usr/bin/perl

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
