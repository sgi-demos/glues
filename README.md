glues 1.5 for the sgi-demos SDL2/GLES2 ports
============================================

This fork is the shared, canonical GLU-for-GLES used by the sgi-demos
ports (freeglut-sdl2-ogles2/newave, inventor-sdl2-gles2). Reconciled
changes over upstream glues:

- **Standard GLU ABI throughout**: the public tess API *and* the libtess
  internals use GLdouble (upstream's GLES port had float-converted them,
  which broke callers compiled against standard `GL/glu.h` prototypes and
  lost the precision libtess' sweep algorithm needs).
- **`GLUES_GL4ES`** build flavor: compiles against gl4es's `<GL/gl.h>`;
  on Apple/Emscripten `glues.h` self-includes gl4es's `GL/glu_mangle.h`
  so the glu* definitions get the mangled (mglu*) names consumers see.
  (Build systems may still `-include GL/glu_mangle.h` — it's harmless
  and covers TUs that reach definitions before `glues.h`.)
- **`GLUES_USE_HW_MIPMAP`** (opt-in, gl4es): power-of-two
  `gluBuild2DMipmaps` defers to gl4es's hardware `GL_GENERATE_MIPMAP`;
  the CPU-built chain samples black under gl4es `*_MIPMAP_*` min
  filters. NPOT input keeps the CPU path.

The Makefile builds the core subset (project/mipmap/quad/error/registry)
for the freeglut port; the Inventor port builds the full library
(core + libtess + libnurbs) via its `tools/build-glues-*.sh` scripts.


```
Original README

This port is based on original GLU 1.3 and has original libutil, libtess and
nurbs libraries.

History:

-1.5 - NURBS support has added. Updated  HTML  documentation  to  reflect  the
      changes. New tests were added for NURBS.
-1.4 - miscellaneous non-critical  fixes,  HTML  documentation has been added.
      Support for PowerVR OpenGL ES 1.1 emulator for Win32 has been added.
1.3 - libtess and tesselation tests (QNX native and SDL 1.3) have been added.
1.2 - SDL 1.3 based tests were added.
1.1 - Removed some texture formats, which are not supported by OpenGL ES 1.x,
      added arrays manipulation to the quadric functions. Sphere flat shading
      fixes.  Disk texturing with inner radius more than 0.0f fixes.  Updated
      tests.
1.0 - Initial public release.

// 11.11.2009
// Mike Gorchak <mike@malva.ua>, <lestat@i.com.ua>
```
