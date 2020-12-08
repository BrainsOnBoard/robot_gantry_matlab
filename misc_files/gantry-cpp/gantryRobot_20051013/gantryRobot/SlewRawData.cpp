#include "SlewRawData.h"
#include "Serialisable.h"
#include <errno.h>
#include <string>

SlewRawData::SlewRawData( const char *filename ) {
  try {
    FILE *input;
    errno = 0;
    if ( ( input = fopen( filename, "r" ) ) == NULL ) {
      string errMsg;
      errMsg += "Cannot open file '";
      errMsg += filename;
      errMsg += "' - error states: ";
      errMsg += strerror( errno );

      CannotOpenFileException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }

    /**
     * Now the first line might be a heading line or not. We'll quickly test by
     * reading the first character. If it's a letter, we'll assume it's the 
     * beginning of a list of headings. Otherwise, we'll assume the numbers start
     * right away.
     */
    int ch;
    if ( isalpha( ( ch = fgetc( input ) ) ) ) {
      char tempBuffer[ 1024 ];
      fgets( tempBuffer, 1024, input );
    } else {
      ungetc( ch, input );
    }

    /**
     * We'll now read all the data in.
     */
    int    tokenNo;
    string token;
    int    lineNo = 1;

    while ( ( tokenNo = readToken( input, token, &lineNo ) ) != ENDOFFILE_TOKEN ) {
      struct RawCoordinate coordinate;

      int i;
      for ( i = 0; i < 7; i++ ) {
        if ( tokenNo != NUMBER_TOKEN ) {
          char errMsg[ 1024 ];
          sprintf( errMsg, "Parse error line %d: Expected a number - found '%s'",
                   lineNo, token.c_str() );

          ParseException e( errMsg );
          e.fillInStackTrace();
          throw e;
        }

        switch( i ) {
        case 0: /* Trial ref   */
        case 1: /* Frame no    */
        case 4: /* Orientation */
        case 6: /* Pitch       */
          break;

        case 2:
          coordinate.m_X = atoi( token.c_str() );
          break;

        case 3:
          coordinate.m_Y = atoi( token.c_str() );
          break;

        case 5:
          coordinate.m_Z = atoi( token.c_str() );
          break;

        default:
          fprintf( stderr, "Programming error - %s: %d\n",
                   __FILE__, __LINE__ );
          exit( 1 );
        }

        tokenNo = readToken( input, token, &lineNo );
     
        if ( i < 6 ) {
          if ( tokenNo != COMMA_TOKEN ) {
            char errMsg[ 1024 ];
            sprintf( errMsg, "Parse error line %d: Expected a comma - found '%s'",
                     lineNo, token.c_str() );

            ParseException e( errMsg );
            e.fillInStackTrace();
            throw e;
          }

          tokenNo = readToken( input, token, &lineNo );
        } else if ( tokenNo != NEWLINE_TOKEN ) {
          /**
           * Unfortunately, the data files are WRONG. The .TC files are OK but the
           * rebuilt files weren't done properly. So we'll kludge it for now...
           */
          while ( tokenNo != NEWLINE_TOKEN ) {
            tokenNo = readToken( input, token, &lineNo );
          }
        }
      }

      m_Coordinates.push_back( coordinate );
    }

    fclose( input );
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}

int SlewRawData::readToken( FILE *input, string& token, int *lineNo ) {
  token = "";

  int ch;
  ch = fgetc( input );
  while ( ch == ' ' || ch == '\t' ) {
    ch = fgetc( input );
  }

  if ( ch == EOF ) {
    return ENDOFFILE_TOKEN;
  }

  if ( ch == ',' ) {
    token = ",";
    return COMMA_TOKEN;
  }

  if ( ch == '\n' ) {
    (*lineNo)++;
    return NEWLINE_TOKEN;
  }

  if ( isdigit( ch ) || ch == '-' ) {
    ungetc( ch, input );
    Serialisable::parseDouble( input, token );
    return NUMBER_TOKEN;
  }

  return UNKNOWN_TOKEN;
}

void SlewRawData::addData( double x, double y, double z ) {
  struct RawCoordinate coordinate;
  coordinate.m_X = x;
  coordinate.m_Y = y;
  coordinate.m_Z = z;

  m_Coordinates.push_back( coordinate );
}

void SlewRawData::save( const char *filename ) {
  FILE *output;
  errno = 0;
  if ( ( output = fopen( filename, "w" ) ) == NULL ) {
    string errMsg;
    errMsg += "Cannot open file '";
    errMsg += filename;
    errMsg += "' - error states: ";
    errMsg += strerror( errno );

    CannotOpenFileException e( errMsg.c_str() );
    e.fillInStackTrace();
    throw e;
  }

  const_iterator i;
  for ( i = m_Coordinates.begin(); i != m_Coordinates.end(); i++ ) {
    fprintf( output, "0,0,%f,%f,0,%f,0\n", i->m_X, i->m_Y, i->m_Z );
  }

  fclose( output );
}
