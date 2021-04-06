
CXX ?= g++

HFLAGS=-Ideps/RE-flex/include/ -I. -std=c++20 -Wall -Wextra

STRIPPER.debug := :
STRIPPER.release := strip
STRIPPER.profile := :
STRIPPER := $(or ${STRIPPER.${target}},:)

ifeq ($(CXX),g++)
CXXFLAGS.debug := -O0 -g3 -fsanitize=address -fsanitize=leak -fsanitize=undefined \
		 		  -fcf-protection=full -fstack-protector-strong -fstack-check
CXXFLAGS.release := -O3 -march=native -funroll-loops -flto -flto=auto
CXXFLAGS.profile := $(CXXFLAGS.release) -g3
CXXFLAGS := $(or ${CXXFLAGS.${target}},-Wall -Wextra -O0)
else
ifeq ($(CXX),clang++)
CXXFLAGS.debug := -O0 -g3 -fsanitize=address -fsanitize=leak -fsanitize=undefined \
		 		  -fcf-protection=full -fstack-protector-strong -fstack-check
CXXFLAGS.release := -O3 -march=native -funroll-loops -flto \
	-ffinite-loops -ffinite-math-only -fignore-exceptions -fno-math-errno -fno-stack-protector \
	-funroll-loops -funsafe-math-optimizations -fvectorize -fwhole-program-vtables -fvirtual-function-elimination \
	-fopenmp-simd -fopenmp -fslp-vectorize # line 2 & 3 are dangerous as fuck, remove when there's some trouble.
CXXFLAGS.profile := $(CXXFLAGS.release) -g3
CXXFLAGS := $(or ${CXXFLAGS.${target}},-Wall -Wextra -O0)
else
CXXFLAGS := -O2
endif
endif

_S_HIGHLIGHTERS := x86asm c cpp lua python brainfuck asm2bf
_S_HL_OBJS := $(patsubst %, highlighters/%.o, $(_S_HIGHLIGHTERS))
_S_HL_A_OBJS := $(patsubst %, highlighters/%.ascii.o, $(_S_HIGHLIGHTERS))

.PHONY: clean all clean-deps
all: tau
clean-deps:
	rm -rf deps
clean:
	rm -f highlighters/*.cpp highlighters/*.o highlighters/*.lxx highlighters/*.ascii.lxi tau.o tau tau.hpp tau.cpp bfpp
deps:
	mkdir deps
	cd deps && git clone https://github.com/Genivia/RE-flex && cd RE-flex && ./clean.sh && ./build.sh
bfpp:
	$(CXX) -DLUA_USE_POPEN -O3 -flto bfpp.c -o bfpp -lm

tau.hpp: bfpp tau.hpp.in
	bfpp < tau.hpp.in > tau.hpp

tau.cpp: bfpp tau.cpp.in
	bfpp < tau.cpp.in > tau.cpp

tau: $(_S_HL_OBJS) $(_S_HL_A_OBJS) tau.o
	$(CXX) $^ deps/RE-flex/lib/libreflex.a -lpthread -lm -o $@ $(CXXFLAGS)
	$(STRIPPER) --strip-all tau   # stripper? never seen one.

%.o: %.cpp tau.hpp
	$(CXX) $< -c -o $@ $(CXXFLAGS) $(HFLAGS)

highlighters/%.lxx: highlighters/%.lxi
	perl build_highlighter.pl $< > $@

highlighters/%.ascii.lxi: highlighters/%.lxi
	cp $< $@ && perl -i make_ascii.pl $(<:.lxi=.ascii.lxi)

highlighters/%.cpp: highlighters/%.lxx
	deps/RE-flex/bin/reflex --fast −−noindent $< -o $@
	perl -pi -e "s/^(?:extern )?(void reflex\_code\_[A-Za-z]+)/static \$$1/;" $@

highlighters/%.o: highlighters/%.cpp tau.hpp
	$(CXX) $< -c -o $@ $(CXXFLAGS) $(HFLAGS)
