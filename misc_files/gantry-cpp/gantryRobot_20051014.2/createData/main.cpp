#include <stdio.h>
#include <math.h>

#define M_PI ((double)3.14159265)

#define X_MAX 4300
#define Y_MAX 2800
#define Z_MAX 2800

int main( int, char ** ) {
  int i;
  for ( i = 0; i < 40000; i += 4 ) {
    double x = 100 + X_MAX / 2 + X_MAX * 0.5  * sin( (double)i * M_PI / 200 );
    double y = 100 + Y_MAX / 2 + Y_MAX * 0.25 * ( sin( (double)i * M_PI / 120 ) + cos( (double)i * M_PI / 220 ) );
    double z = 100 + Z_MAX / 2 + Z_MAX * 0.25 * ( sin( (double)i * M_PI / 180 ) + cos( (double)i * M_PI / 400 ) );
    printf( "0,0,%f,%f,0,%f,0\n", x, y, z );
  }

  return 0;
}
