
#ifndef _ALL_HPP
#define _ALL_HPP

#include <iostream>
#include <tau.hpp>

#define _all_highlighter(name) void highlight_##name(FILE * f, tau::printer & output)
#define _all_highlighter_ascii(name) void highlight_##name##_a(FILE * f, tau::ascii_printer & output)

_all_highlighter(c);
_all_highlighter(x86asm);
_all_highlighter(cpp);
_all_highlighter(lua);
_all_highlighter(python);
_all_highlighter(brainfuck);
_all_highlighter(asm2bf);

_all_highlighter_ascii(c);
_all_highlighter_ascii(x86asm);
_all_highlighter_ascii(cpp);
_all_highlighter_ascii(lua);
_all_highlighter_ascii(python);
_all_highlighter_ascii(brainfuck);
_all_highlighter_ascii(asm2bf);

#undef _all_highlighter

#endif
