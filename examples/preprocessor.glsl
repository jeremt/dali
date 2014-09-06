
#ifdef GL_SL
#define highp
#define mediump
#define lowp
#endif

#ifndef TEST
#define TEST
int test;
#endif

#if (VERSION > 2 && VERSION < 3) || !defined(GL_SL)

#define NORMAL_VERSION

#elif VERSION == 4

#define NEW_VERSION

#else

/* ERROR */

#endif

#define ABS(x) (x < 0 ? -x : x)
#define MAX(a, b, c) (a > b ? a > c ? a : c : b)

void main() {
  gl_FragColor = MAX(1, 2, 3);
}