
# tau - a reasonably fast (wip) syntax highlighter.

Tau is a fast syntax highlighter capable of emitting HTML. It highlights the following languages:
* python
* lua
* c
* c++
* x86 assembly

This is alpha-grade software, which means it may or may not have obvious bugs. It may also scare you off by it's code quality, but all that is a subject to change.

## Building

```bash
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
