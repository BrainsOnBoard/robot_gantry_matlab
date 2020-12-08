#include "Serialisable.h"
#include <string.h>
#include <ctype.h>
#include <string>
#include <stdio.h>

using namespace std;

const char *
Serialisable::skipToken( const char *str, const char *token ) const {
  try {
    str = skipWhitespace( str );
    if ( strncmp( str, token, strlen( token ) ) != 0 ) {
      char buffer[ 100 ];
      strncpy( buffer, str, 15 );
      buffer[ 15 ] = '\0';

      string errMsg;
      errMsg += "Didn't found expected token '";
      errMsg += token;
      errMsg += "' - found '";
      errMsg += buffer;
      errMsg += "'";

      TokenNotFoundException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }

    str += strlen( token );
    return skipWhitespace( str );
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw e;
  }
}

const char *Serialisable::parseUnsignedInteger( const char   *str, 
						unsigned int *intBuf ) const {
  try {
    str = skipWhitespace( str );
    if ( !isdigit( *str ) ) {
      char buffer[ 100 ];
      strncpy( buffer, str, 15 );
      buffer[ 15 ] = '\0';

      string errMsg;
      errMsg += "Didn't found an integer - found '";
      errMsg += buffer;
      errMsg += "'";

      CannotParseIntegerException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }

    char number[ 1024 ]; char *t = number;
    while ( isdigit( *str ) ) {
      *t++ = *str++;
    }

    *t = '\0';

    *intBuf = atoi( number );

    return skipWhitespace( str );
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}

const char *Serialisable::parseInteger( const char   *str,
						                            int          *intBuf ) const {
  try {
    str = skipWhitespace( str );
    if ( !isdigit( *str ) && *str != '-' ) {
      char buffer[ 100 ];
      strncpy( buffer, str, 15 );
      buffer[ 15 ] = '\0';

      string errMsg;
      errMsg += "Didn't found an integer - found '";
      errMsg += buffer;
      errMsg += "'";

      CannotParseIntegerException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }

    char number[ 1024 ]; char *t = number;
    if ( *str == '-' ) {
      *t++ = *str++;
    }

    while ( isdigit( *str ) ) {
      *t++ = *str++;
    }

    *t = '\0';

    *intBuf = atoi( number );

    return skipWhitespace( str );
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}

const char *Serialisable::parseDouble( const char *str,
                                       double     *doubleBuf ) const {
  try {
    str = skipWhitespace( str );
    if ( !isdigit( *str ) && *str != '-' ) {
      char buffer[ 100 ];
      strncpy( buffer, str, 15 );
      buffer[ 15 ] = '\0';

      string errMsg;
      errMsg += "Didn't found an double - found '";
      errMsg += buffer;
      errMsg += "'";

      CannotParseDoubleException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }

    char number[ 1024 ]; char *t = number;
    if ( *str == '-' ) {
      *t++ = *str++;
    }

    while ( isdigit( *str ) ) {
      *t++ = *str++;
    }

    if ( *str == '.' ) {
      *t++ = *str++;
    }

    while ( isdigit( *str ) ) {
      *t++ = *str++;
    }

    *t = '\0';

    *doubleBuf = atof( number );

    return skipWhitespace( str );
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}

const char *Serialisable::skipWhitespace( const char *str ) const {
  while ( isspace( *str ) ) {
    str++;
  }

  return str;
}

void Serialisable::addDouble( string& buffer, double number ) const {
  if ( number == 0 ) {
    buffer += "0";
  } else {
    char buf[ 1024 ];
    sprintf( buf, "%.20f", number );
    char *s;
    for ( s = buf; *s != '\0'; s++ ) {
      if ( *s == '.' ) {
        char *c = &( buf[ strlen( buf ) ] );
        for ( c--; c > buf && *c == '0'; c-- ) {
          *c = '\0';
        }
        if ( *c == '.' ) {
          *c = '\0';
        }
        break;
      }
    }
    buffer += buf;
  }

}
