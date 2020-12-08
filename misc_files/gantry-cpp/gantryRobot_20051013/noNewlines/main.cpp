#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <string>
#include <stdlib.h>

using namespace std;

/**
 * This program goes through all the given files and gets rid of all
 * the \r characters.
 */

static void printUsage() {
  fputs( "noNewlines filename1 [filename2 ...]\n", stderr );
  exit( 1 );
}

static void moveToBackupFile( const char *filename ) {
  string newFilename;
  newFilename = ".";
  newFilename += filename;
  newFilename += ".back";

  errno = 0;
  if ( rename( filename, newFilename.c_str() ) == -1 ) {
    fprintf( stderr, "Error for file %s - error states: %s\n",
	     filename, strerror( errno ) );
    exit( 1 );
  }
}

static void convertFile( const char *filename ) {
  string backupFilename;
  backupFilename = ".";
  backupFilename += filename;
  backupFilename += ".back";

  FILE *input;
  errno = 0;
  if ( ( input = fopen( backupFilename.c_str(), "r" ) ) == NULL ) {
    fprintf( stderr, "Cannot open file %s for reading - error states: %s\n",
	     backupFilename.c_str(), strerror( errno ) );
    exit( 1 );
  }

  FILE *output;
  errno = 0;
  if ( ( output = fopen( filename, "w" ) ) == NULL ) {
    fprintf( stderr, "Cannot open file %s for writing - error states: %s\n",
	     filename, strerror( errno ) );
    exit( 1 );
  }

  int ch;
  while ( ( ch = fgetc( input ) ) != EOF ) {
    if ( ch != (int)'\r' ) {
      fputc( ch, output );
    }
  }

  fclose( output );
  fclose( input );
}

int main( int argc, char **argv ) {
  if ( argc == 1 ) {
    printUsage();
  }

  int i;
  for ( i = 1; argv[ i ] != NULL; i++ ) {
    moveToBackupFile( argv[ i ] );
    convertFile( argv[ i ] );
  }

  return 0;
}

    
