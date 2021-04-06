
# tau - a reasonably fast (wip) syntax highlighter.

Tau is a fast syntax highlighter capable of emitting HTML. It highlights the following languages:
* python
* lua
* c
* c++
* x86 assembly
* brainfuck
* asm2bf

This is alpha-grade software, which means it may or may not have obvious bugs. It may also scare you off by it's code quality, but all that is a subject to change.

## Benchmarks

Unicode mode: `0:01.51`s for Boost + a few highlighter sources; around 3'700'000 lines. ASCII mode: `0:00.75`s.
Tau highlights (respectively) 2'000'000 lines of C++ code and ~4'900'000 lines of C++ code per second.
Single thread performance - `648511.11` lines of x86 assembly per second (0.09s) on [this data](https://b.catgirlsare.sexy/kn4FQpJ2.txt).

## Building

```bash
# Clone the repository
git clone https://github.com/kspalaiologos/tau && cd tau

# Start with downloading and building the dependencies.
make deps

# Find out the amount of parallel workers make can launch.
thr=$(find /sys/devices/system/cpu/ -regextype sed -regex '.*/cpu[0-9]\{1,99\}' | wc -l)

# Start the build
make target=release "-j$thr" all

# You can also try the following targets: `profile, debug`.
# If you're concerned about compile time, don't set a target.
# Tau usually takes quite a while to compile.
```

## Usage

```
% ./tau -h
tau: a reasonably fast syntax highlighter.
copyright (c) kamila szewczyk, 2021, agplv3.
usage:
 tau [--options] files...flags:
 -d dir   -  set the output directory.
 -s syn   -  override the syntax.
 -a       -  assume ASCII input (visible speedup).
 -i       -  ignore unknown languages.
 -j num   -  override the amount of worker threads.
```

## Roadmap

Project's roadmap:
* Improved I/O performance (may require profiling in the ASCII mode to find out the main bottleneck except NFAs).
* Faster highlighters (fancy/fast modes; more optimized regular expressions).
* Code quality improvements - the code has been written hastily without concerns about it's quality.
* asm2bf support
* XML/HTML/CSS support
* JavaScript support
* JSON support
* Perl support (might be tricky)
* Configurable themes
* Emitting all the output into a single file (might require some clever optimizations related to threading).
* Stripping the output's header (fairly simple; will require a small redesign of `tau.hpp.in`'s code churn).
* Less verbose syntax description language.
* Improving the builtin theme; adding a few alternative themes.

## Licensing

AGPLv3.

## Contributing

I'd happily merge good quality changes to the codebase that address issues outlined in the roadmap. Contributors
will be listed in a separate file (or in the readme) along with an outline of their changes in Tau. Feel free to
add yourself on the list before starting a pull request. For the good of this software, I'd like the copyright
over the changes be transferred to me. I make a few promises regarding the project, inter alia:
* Contributor names will stay in the contributor list as long as their code or improvements are still present in the codebase.
* The software won't be relicensed to a non-GPL and non-derivative licenses (if it'll ever be relicensed).
* The software will always remain free and open-source.

## Adding your own language

If you're reading this section, you probably want to add your own language's syntax highlighter to Tau.
Great! Let's add syntax highlighting for brainfuck. First, update the makefile to build your highlighter.

```diff
 CXXFLAGS := $(or ${CXXFLAGS.${target}},-Wall -Wextra -O0)

-_S_HIGHLIGHTERS := x86asm c cpp lua python
+_S_HIGHLIGHTERS := x86asm c cpp lua python brainfuck
 _S_HL_OBJS := $(patsubst %, highlighters/%.o, $(_S_HIGHLIGHTERS))
 _S_HL_A_OBJS := $(patsubst %, highlighters/%.ascii.o, $(_S_HIGHLIGHTERS))
```

Then, let's create the highlighter's syntax description.

```bash
touch highlighters/brainfuck.lxi
```

Start off by setting the name of your language and the colors you want to use in your highlighter. You can find an up-to-date list in `tau.hpp.in`.

```
[syntax brainfuck]
[top #define COLOR_GROUP1 2]
[top #define COLOR_GROUP2 5]
[top #define COLOR_GROUP3 4]
[top #define COLOR_GROUP4 9]
[top #define COLOR_COMMENT 8]
[top #define COLOR_NONE 0]
```

Then, define a few helper macros for your grammar:

```
-- set the source of data
[reader wstr]
-- we're making a unicode-aware highlighter.
[unicode 1]
-- the default prefix of literals (a consequence of `unicode`)
[literalprefix L]
```

You can also set a few of other macros (we won't need them in this grammar):

```
[viewkind wstring_view]
[strkind wstring]
[identifier \p{UnicodeIdentifierStart}\p{UnicodeIdentifierPart}*]
```

They're later processed by another script which asciifies the highlighters (and replaces all the definitions). Let's move on to the grammar.

```
[grammar]

%%

.+         printer << COLOR_NONE << ${reader}();

%%
```

This very simple grammar will simply output whatever it reads. Let's make something better:

```
%%

[\+\-]+                     printer << COLOR_GROUP1 << ${reader}();
[><]+                       printer << COLOR_GROUP2 << ${reader}();
[\.\,]+                     printer << COLOR_GROUP3 << ${reader}();
[\[\]]+                     printer << COLOR_GROUP4 << ${reader}();
[ \t\r\n\f\v]               printer >> ${reader}()[0];
[^\+\-><\[\]\.\,]*          printer << COLOR_COMMENT << ${reader}();

%%
```

Note: `>>` is used with _strings_ and _characters_. For _strings_, it highlights escape sequences inside them.
With characters, it prints them. Use `<<` for anything else.

Now, let's do something more advanced - `[-][...]` comments. The main issue that stops us from simply
using `"[-][".*?"]"` is the fact, that for example `[-][test [test] test]` won't be highlighted correctly.
For this, we will use multiple states.

```
[grammar]

%x INCOMMENT

%%

<INCOMMENT>(\[(.|\n)*?\])|([^\[\]]+)     printer << COLOR_COMMENT << ${reader}();
<INCOMMENT>\]                            printer << COLOR_COMMENT >> ${literalprefix}']'; start(INITIAL);

"[-]["                                   printer << COLOR_COMMENT << ${reader}(); start(INCOMMENT); 
[\+\-]+                                  printer << COLOR_GROUP1 << ${reader}();
[><]+                                    printer << COLOR_GROUP2 << ${reader}();
[\.\,]+                                  printer << COLOR_GROUP3 << ${reader}();
[\[\]]+                                  printer << COLOR_GROUP4 << ${reader}();
[ \t\r\n\f\v]                            printer >> ${reader}()[0];
[^\+\-><\[\]\.\,]*                       printer << COLOR_COMMENT << ${reader}();

%%
```

Now we're ready to add our highlighter to the recognition module (in `tau.cpp.in`):

```diff
 rewind(in);
    
 if(shebang[0] == '#' && shebang[1] == '!') {
     std::string str(shebang + 2);
     if(is_lang(str, "python")) { $(highlight_lang("python")) return; }
+    else if(is_lang(str, "tritium", "brainfuck", "/bf")) { $(highlight_lang("brainfuck")) return; }
 }
```

after we support the shebang (i.e. `#!/bin/bf` will be recognized as brainfuck), we register a new
file extension:

```diff
 else if(ext == ".lua")
     $(highlight_lang("lua"))
+else if(ext == ".bf")
+    $(highlight_lang("brainfuck"))
 else if(ext == ".py")
     $(highlight_lang("python"))
```

finally, we register the brainfuck highlighter in `highlighters/all.hpp`:

```
 _all_highlighter(python);
+_all_highlighter(brainfuck);

 _all_highlighter_ascii(c);
 _all_highlighter_ascii(x86asm);
 _all_highlighter_ascii(cpp);
 _all_highlighter_ascii(lua);
 _all_highlighter_ascii(python);
+_all_highlighter_ascii(brainfuck);
```

... and the language support is finished. now, you can `make -j4 all` to verify the correctness of
your highlighter and then run `make target=release -j4 all` to build an optimized binary to benchmark
your highlighter.
