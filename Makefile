# glues/Makefile -- build GLU-ES "core" (project + mipmap + error + registry)
# as a static lib for native + emscripten, for the freeglut SDL2/GLES2/gl4es port.
#
# NURBS/tessellation are not needed and are omitted. glues_quad.c (gluNewQuadric,
# gluSphere, ...) is also omitted by default because newave/3dview don't need it;
# add it to SRC if a later demo calls quadrics.
#
# Sources are force-compiled so that on Emscripten/Apple the glu* definitions get
# the SAME mgl* mangling as gl4es applies to the demo's glu* calls. That match is
# what lets the linker resolve newave's gluPerspective -> glues' mgluPerspective.
#
# GL4ES must point at the gl4es checkout (its include/ supplies GL/gl.h and the
# macro-only GL/glu_mangle.h).

GL4ES ?= $(HOME)/Github/gl4es

# ---- platform detect ----
OS := $(shell uname -s)
ifeq ($(OS),Darwin)
	OS = mac
else ifeq ($(OS),Linux)
	OS = linux
else ifneq ($(findstring MINGW64_NT,$(OS)),)
	OS = win
else ifneq ($(findstring MSYS_NT,$(OS)),)
	OS = win
else ifneq ($(findstring CLANG64,$(OS)),)
	OS = win
endif

# ---- compilers / flags ----
CC      ?= cc
EMCC    ?= emcc -s WASM=1
OPT     ?= -O2 -g
EM_OPT  ?= -O2
WARN_OFF = -Wno-implicit-function-declaration -Wno-unused-value \
           -Wno-deprecated-declarations -Wno-unused-but-set-variable

# ---- sources (the "core" subset; matches flwbox's proven set) ----
SRC = source/glues_project.c source/glues_mipmap.c source/glues_quad.c \
      source/glues_error.c   source/glues_registry.c

# gl4es headers first so <GL/gl.h> resolves to gl4es' header (NOT gl4es' GL/glu.h,
# whose GLdouble protos conflict with glues' own). GLUES_GL4ES selects the branch
# in glues.h that includes <GL/gl.h> instead of #error.
INCS = -I$(GL4ES)/include -Isource -DGLUES_GL4ES

# gl4es mangles glu* -> mglu* only on Emscripten and Apple. Match that:
#  - web build: always force-include the macro-only glu_mangle.h
#  - native: only on mac (linux/win keep unmangled glu* names)
FORCE_GLU_WEB = -include GL/glu_mangle.h
ifeq ($(OS),mac)
	GLUES_MANGLE = -include GL/glu_mangle.h
else
	GLUES_MANGLE =
endif

NATIVE_OBJS = $(patsubst source/%.c,obj-native/%.o,$(SRC))
WEB_OBJS    = $(patsubst source/%.c,obj-web/%.o,$(SRC))

NATIVE_LIB = lib/libglues-native.a
WEB_LIB    = lib/libglues-web.a

all: native

native: $(NATIVE_LIB)
browser: $(WEB_LIB)

obj-native/%.o: source/%.c | obj-native
	$(CC) $(OPT) $(WARN_OFF) $(INCS) $(GLUES_MANGLE) -c $< -o $@

obj-web/%.o: source/%.c | obj-web
	$(EMCC) $(EM_OPT) $(WARN_OFF) $(INCS) $(FORCE_GLU_WEB) -c $< -o $@

$(NATIVE_LIB): $(NATIVE_OBJS) | lib
	ar rcs $@ $(NATIVE_OBJS)
	@echo "BUILT: glues $@  (GL4ES=$(GL4ES), OS=$(OS), mangle=$(GLUES_MANGLE))"

$(WEB_LIB): $(WEB_OBJS) | lib
	emar rcs $@ $(WEB_OBJS)
	@echo "BUILT: glues $@  (web, mangle=$(FORCE_GLU_WEB))"

obj-native obj-web lib:
	mkdir -p $@

clean:
	rm -rf obj-native obj-web $(NATIVE_LIB) $(WEB_LIB)

.PHONY: all native browser clean
