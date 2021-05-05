LIBS = GL dl stdc++fs

COMMONFLAGS = -Wall -Werror -Wfatal-errors -DLAK_USE_$(PLATFORM) -DLAK_DONT_AUTO_COMPILE_PLATFORM_SPECIFICS -Iinc -Iinc/lak/inc -ldl -lstdc++fs

CXX = g++
CC  = gcc

CXXFLAGS = -g3 -O0 -mfpmath=387 -mtune=generic -no-pie -mavx
CCFLAGS  = -g3 -O0 -mfpmath=387 -mtune=generic -no-pie -mavx

CXXFLAGS += -pthread -std=c++17 $(COMMONFLAGS)
CCFLAGS  += -pthread -std=c99 $(COMMONFLAGS)

PLATFORM = NONE

ifeq ($(PLATFORM),SDL)
CXXFLAGS += `sdl2-config --cflags`
LIBS += SDL2
else ifeq ($(PLATFORM),WIN32)
else ifeq ($(PLATFORM),XCB)
else ifeq ($(PLATFORM),XLIB)
else ifeq ($(PLATFORM),NONE)
else
$(error Invalid platform "$(PLATFORM)")
endif

ifneq ($(shell grep -a -h -i microsoft /proc/version),)
# For use on Windows (WSL) with cygwinX
# Requires xinit, xauth and xhost probably
# Start the X11 server with `path\to\cygwin64\bin\run.exe --quote /usr/bin/bash.exe -l -c "cd; exec /usr/bin/startxwin -- -listen tcp"`
# If you get "Authorization required, but no authorization protocol specified"
# then try running `DISPLAY=:0.0 xhost +` in the cygwin terminal after
# starting the X11 server.
DISPLAY = "`cat /etc/resolv.conf | grep nameserver | awk '{ print $$2 }'`:0.0"
endif

.PHONY: ctob

ctob: bin/ctob.elf
	cp $< $@

# ctob.exe: bin/ctob.exe
# 	bin/ctob.exe

LAK_HEADERS = \
	Makefile \
	inc/lak/inc/GL/gl3w.h \
	inc/lak/inc/GL/glcorearb.h \
	inc/lak/inc/lak/opengl/mesh.hpp \
	inc/lak/inc/lak/opengl/shader.hpp \
	inc/lak/inc/lak/opengl/state.hpp \
	inc/lak/inc/lak/opengl/texture.hpp \
	inc/lak/inc/lak/algorithm.hpp \
	inc/lak/inc/lak/array.hpp \
	inc/lak/inc/lak/array.inl \
	inc/lak/inc/lak/bank_ptr.hpp \
	inc/lak/inc/lak/bank_ptr.inl \
	inc/lak/inc/lak/basic_program.inl \
	inc/lak/inc/lak/bitflag.hpp \
	inc/lak/inc/lak/bitset.hpp \
	inc/lak/inc/lak/buffer.hpp \
	inc/lak/inc/lak/char.hpp \
	inc/lak/inc/lak/colour.hpp \
	inc/lak/inc/lak/colour.inl \
	inc/lak/inc/lak/compiler.hpp \
	inc/lak/inc/lak/debug.hpp \
	inc/lak/inc/lak/debug.inl \
	inc/lak/inc/lak/defer.hpp \
	inc/lak/inc/lak/endian.hpp \
	inc/lak/inc/lak/errno_result.hpp \
	inc/lak/inc/lak/events.hpp \
	inc/lak/inc/lak/file.hpp \
	inc/lak/inc/lak/image.hpp \
	inc/lak/inc/lak/image.inl \
	inc/lak/inc/lak/intrin.hpp \
	inc/lak/inc/lak/lifetime_view.hpp \
	inc/lak/inc/lak/lifetime_view.inl \
	inc/lak/inc/lak/macro_utils.hpp \
	inc/lak/inc/lak/memmanip.hpp \
	inc/lak/inc/lak/memory.hpp \
	inc/lak/inc/lak/optional.hpp \
	inc/lak/inc/lak/os.hpp \
	inc/lak/inc/lak/packed_array.hpp \
	inc/lak/inc/lak/packed_array.inl \
	inc/lak/inc/lak/platform.hpp \
	inc/lak/inc/lak/profile.hpp \
	inc/lak/inc/lak/railcar.hpp \
	inc/lak/inc/lak/railcar.inl \
	inc/lak/inc/lak/result.hpp \
	inc/lak/inc/lak/span_forward.hpp \
	inc/lak/inc/lak/span.hpp \
	inc/lak/inc/lak/span.inl \
	inc/lak/inc/lak/stdint.hpp \
	inc/lak/inc/lak/strcast.hpp \
	inc/lak/inc/lak/strcast.inl \
	inc/lak/inc/lak/strconv.hpp \
	inc/lak/inc/lak/strconv.inl \
	inc/lak/inc/lak/streamify.hpp \
	inc/lak/inc/lak/streamify.inl \
	inc/lak/inc/lak/string.hpp \
	inc/lak/inc/lak/surface.hpp \
	inc/lak/inc/lak/tinflate.hpp \
	inc/lak/inc/lak/tokeniser.hpp \
	inc/lak/inc/lak/tokeniser.inl \
	inc/lak/inc/lak/trace.hpp \
	inc/lak/inc/lak/trie.hpp \
	inc/lak/inc/lak/trie.inl \
	inc/lak/inc/lak/tuple.hpp \
	inc/lak/inc/lak/type_pack.hpp \
	inc/lak/inc/lak/type_traits.hpp \
	inc/lak/inc/lak/unicode.hpp \
	inc/lak/inc/lak/unicode.inl \
	inc/lak/inc/lak/uninitialised.hpp \
	inc/lak/inc/lak/unique_pages.hpp \
	inc/lak/inc/lak/unique_pages.inl \
	inc/lak/inc/lak/utility.hpp \
	inc/lak/inc/lak/uwuify.hpp \
	inc/lak/inc/lak/variant.hpp \
	inc/lak/inc/lak/variant.inl \
	inc/lak/inc/lak/vec_intrin.hpp \
	inc/lak/inc/lak/vec.hpp \
	inc/lak/inc/lak/visit.hpp \
	inc/lak/inc/lak/visit.inl \
	inc/lak/inc/lak/window.hpp

LAK_OBJ = \
	obj/lak/debug.obj \
	obj/lak/file.obj \
	obj/lak/strconv.obj \
	obj/lak/unicode.obj

ifneq ($(PLATFORM),NONE)
LAK_OBJ += \
	obj/lak/events.obj \
	obj/lak/platform.obj \
	obj/lak/window.obj
endif

ifeq ($(PLATFORM),SDL)
LAK_OBJ += \
	obj/lak/SDL/events.obj \
	obj/lak/SDL/platform.obj \
	obj/lak/SDL/window.obj
else ifeq ($(PLATFORM),WIN32)
LAK_OBJ += \
	obj/lak/WIN32/events.obj \
	obj/lak/WIN32/platform.obj \
	obj/lak/WIN32/window.obj
else ifeq ($(PLATFORM),XCB)
LAK_OBJ += \
	obj/lak/XCB/events.obj \
	obj/lak/XCB/platform.obj \
	obj/lak/XCB/window.obj
else ifeq ($(PLATFORM),XLIB)
LAK_OBJ += \
	obj/lak/XLIB/events.obj \
	obj/lak/XLIB/platform.obj \
	obj/lak/XLIB/window.obj
endif

bin/ctob.elf: obj/main.obj $(LAK_OBJ) | bin
	$(CXX) -o $@ $^ $(CXXFLAGS)

obj/main.obj: src/main.cpp $(LAK_HEADERS) | obj inc/lak/inc
	$(CXX) -o $@ -c $< $(CXXFLAGS)

# Common

obj/lak/debug.obj: inc/lak/src/debug.cpp $(LAK_HEADERS) | obj/lak inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/events.obj: inc/lak/src/events.cpp $(LAK_HEADERS) | obj/lak inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/file.obj: inc/lak/src/file.cpp $(LAK_HEADERS) | obj/lak inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/intrin.obj: inc/lak/src/intrin.cpp $(LAK_HEADERS) | obj/lak inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/memmanip.obj: inc/lak/src/memmanip.cpp $(LAK_HEADERS) | obj/lak inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/platform.obj: inc/lak/src/platform.cpp $(LAK_HEADERS) | obj/lak inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/profile.obj: inc/lak/src/profile.cpp $(LAK_HEADERS) | obj/lak inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/strconv.obj: inc/lak/src/strconv.cpp $(LAK_HEADERS) | obj/lak inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/tinflate.obj: inc/lak/src/tinflate.cpp $(LAK_HEADERS) | obj/lak inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/tokeniser.obj: inc/lak/src/tokeniser.cpp $(LAK_HEADERS) | obj/lak inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/unicode.obj: inc/lak/src/unicode.cpp $(LAK_HEADERS) | obj/lak inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/window.obj: inc/lak/src/window.cpp $(LAK_HEADERS) | obj/lak inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

# OpenGL

obj/lak/opengl/gl3w.obj: inc/lak/src/opengl/gl3w.c $(LAK_HEADERS) | obj/lak/opengl inc/lak/src
	$(CC) -o $@ -c $< $(CCFLAGS)

obj/lak/opengl/mesh.obj: inc/lak/src/opengl/mesh.cpp $(LAK_HEADERS) | obj/lak/opengl inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/opengl/shader.obj: inc/lak/src/opengl/shader.cpp $(LAK_HEADERS) | obj/lak/opengl inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/opengl/texture.obj: inc/lak/src/opengl/texture.cpp $(LAK_HEADERS) | obj/lak/opengl inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

# SDL

obj/lak/SDL/events.obj: inc/lak/src/sdl/events.cpp $(LAK_HEADERS) | obj/lak/SDL inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/SDL/platform.obj: inc/lak/src/sdl/platform.cpp $(LAK_HEADERS) | obj/lak/SDL inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/SDL/window.obj: inc/lak/src/sdl/window.cpp $(LAK_HEADERS) | obj/lak/SDL inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

# Win32

obj/lak/WIN32/events.obj: inc/lak/src/win32/events.cpp $(LAK_HEADERS) | obj/lak/WIN32 inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/WIN32/platform.obj: inc/lak/src/win32/platform.cpp $(LAK_HEADERS) inc/lak/src/win32/platform.hpp | obj/lak/WIN32 inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/WIN32/window.obj: inc/lak/src/win32/window.cpp $(LAK_HEADERS) | obj/lak/WIN32 inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

# XCB

obj/lak/XCB/events.obj: inc/lak/src/xcb/events.cpp $(LAK_HEADERS) | obj/lak/XCB inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/XCB/platform.obj: inc/lak/src/xcb/platform.cpp $(LAK_HEADERS) | obj/lak/XCB inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/XCB/window.obj: inc/lak/src/xcb/window.cpp $(LAK_HEADERS) | obj/lak/XCB inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

# Xlib

obj/lak/XLIB/events.obj: inc/lak/src/xlib/events.cpp $(LAK_HEADERS) | obj/lak/XLIB inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/XLIB/platform.obj: inc/lak/src/xlib/platform.cpp $(LAK_HEADERS) | obj/lak/XLIB inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)

obj/lak/XLIB/window.obj: inc/lak/src/xlib/window.cpp $(LAK_HEADERS) | obj/lak/XLIB inc/lak/src
	$(CXX) -o $@ -c $< $(CXXFLAGS)


inc/lak/src inc/lak/inc:
	git submodule update --init

bin obj obj/lak obj/lak/opengl obj/lak/SDL obj/lak/WIN32 obj/lak/XCB obj/lak/XLIB:
	mkdir -p $@

clean:
	rm -rf obj bin
