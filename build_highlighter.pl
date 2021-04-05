#!/usr/bin/perl

use 5.010; use warnings; use strict;

my $reading_grammar = 0;
my %opt = ();
my $grammar = '';
$opt{'toplevel'} = '';

while(<>) {
    if(!$reading_grammar) {
        if($_ =~ /^\[[ \t]*([A-Za-z0-9_-]+)[ \t]*([^\r\n]*)[ \t]*\]$/) {
            if($1 eq 'grammar') {
                $reading_grammar = 1; next;
            } elsif($1 eq 'top') {
                $opt{'toplevel'} .= $2 . "\n";
            } else {
                $2 eq "" ? ($opt{$1} = "") : ($opt{$1} = $2);
            }
        }
    }

    $grammar .= $_ if($reading_grammar);
}

if($opt{'unicode'} eq '1') {
    $opt{'unicode'} = 'unicode';
    $opt{'printer'} = 'printer';
} else {
    $opt{'unicode'} = '';
    $opt{'printer'} = 'ascii_printer';
}

$opt{'grammar'} = $grammar;

while (<DATA>) {
    # replace twice
    s=\$\{([A-Za-z0-9_-]+)\}=$opt{$1}//die"undefined $1"=ge;
    s=\$\{([A-Za-z0-9_-]+)\}=$opt{$1}//die"undefined $1"=ge;
    print;
}

# printer: printer / ascii_printer
# defines: add your custom highlighting colors.
# syntax: [your language's name]
# unicode: 1 / 0
# grammar: [your language's grammar]

__DATA__
%top {
    #include <string_view>
    #include <iostream>
    #include <tau.hpp>

    #define PRINTER_TYPE tau::${printer}

    ${toplevel}
}

%o class=${syntax}_highlight lex=process fast params="PRINTER_TYPE & printer"

%{
class ${syntax}_highlight : public Lexer {
    public:
        using Lexer::process;
        int process(PRINTER_TYPE &);
};
%}

%o ${unicode} nodefault

${grammar}

void highlight_${syntax}(FILE * f, PRINTER_TYPE & output) { ${syntax}_highlight highlight; highlight.process(f, output); }

