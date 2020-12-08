#include "Position.h"
#include "GantryRobotAttributes.h"
#include <stdio.h>
#include <math.h>

Position::Position() : m_X( 0 ),
                       m_Y( 0 ),
                       m_Z( 0 ) { }

Position::Position( int x,
		    int y,
		    int z ) : m_X( x ),
				       m_Y( y ),
				       m_Z( z ) {
  try {
    if ( m_X > GantryRobotAttributes::MAX_X ) {
      string errMsg;
      errMsg += "x coordinate is out of range in constructor(";

      char number[ 100 ];
      sprintf( number, "%d", m_X );
      errMsg += number;
      errMsg += ")";

      InvalidPositionException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }

    if ( m_Y > GantryRobotAttributes::MAX_Y ) {
      string errMsg;
      errMsg += "y coordinate is out of range (";

      char number[ 100 ];
      sprintf( number, "%d", m_Y );
      errMsg += number;
      errMsg += ")";

      InvalidPositionException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }

    if ( m_Z > GantryRobotAttributes::MAX_Z ) {
      string errMsg;
      errMsg += "z coordinate is out of range (";

      char number[ 100 ];
      sprintf( number, "%d", m_Z );
      errMsg += number;
      errMsg += ")";

      InvalidPositionException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}

void Position::setX( int x ) {
  try {
    m_X = x;

    if ( m_X > GantryRobotAttributes::MAX_X ) {
      string errMsg;
      errMsg += "x coordinate is out of range in setX(";

      char number[ 100 ];
      sprintf( number, "%d", m_X );
      errMsg += number;
      errMsg += ")";

      InvalidPositionException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}

void Position::setY( int y ) {
  try {
    m_Y = y;

    if ( m_Y > GantryRobotAttributes::MAX_Y ) {
      string errMsg;
      errMsg += "y coordinate is out of range in setY(";
      
      char number[ 100 ];
      sprintf( number, "%d", m_Y );
      errMsg += number;
      errMsg += ")";

      InvalidPositionException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}
   
void Position::setZ( int z ) {
  try {
    m_Z = z;

    if ( m_Z > GantryRobotAttributes::MAX_Z ) {
      string errMsg;
      errMsg += "z coordinate is out of range in setZ(";
      
      char number[ 100 ];
      sprintf( number, "%d", m_Z );
      errMsg += number;
      errMsg += ")";

      InvalidPositionException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}

const char *Position::readObject( const char *str ) {
  try {
    /**
     * First the X number...
     */
    str = skipToken( str, "<position>" );
    str = skipToken( str, "<x>" );
    str = parseInteger( str, &m_X );
    str = skipToken( str, "</x>" );

    if ( m_X > GantryRobotAttributes::MAX_X ) {
      string errMsg;
      errMsg += "x coordinate is out of range in constructor(";
      
      char number[ 100 ];
      sprintf( number, "%d", m_X );
      errMsg += number;
      errMsg += ")";

      InvalidPositionException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }
    
    /**
     * Now the Y number...
     */
    str = skipToken( str, "<y>" );
    str = parseInteger( str, &m_Y );
    str = skipToken( str, "</y>" );

    if ( m_Y > GantryRobotAttributes::MAX_Y ) {
      string errMsg;
      errMsg += "y coordinate is out of range in constructor(";
      
      char number[ 100 ];
      sprintf( number, "%d", m_Y );
      errMsg += number;
      errMsg += ")";

      InvalidPositionException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }

    /**
     * Finally the Z number...
     */
    str = skipToken( str, "<z>" );
    str = parseInteger( str, &m_Z );
    str = skipToken( str, "</z>" );

    if ( m_Z > GantryRobotAttributes::MAX_Z ) {
      string errMsg;
      errMsg += "z coordinate is out of range in constructor(";
      
      char number[ 100 ];
      sprintf( number, "%d", m_Z );
      errMsg += number;
      errMsg += ")";

      InvalidPositionException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }
    
    str = skipToken( str, "</position>" );

    return str;
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}

void Position::writeObject( string& buffer ) {
  buffer += "    <position>\n"
            "      <x>";
  
  char number[ 100 ];
  sprintf( number, "%d", m_X );
  buffer += number;
  
  buffer += "</x>\n"
            "      <y>";
  sprintf( number, "%d", m_Y );
  buffer += number;

  buffer += "</y>\n"
            "      <z>";
  sprintf( number, "%d", m_Z );
  buffer += number;

  buffer += "</z>\n"
            "    </position>\n";
}

double Position::distanceBetweenPoints( const Position& a, 
					const Position& b ) {
  return sqrt( ( a.getX() - b.getX() ) * ( a.getX() - b.getX() ) +
	       ( a.getY() - b.getY() ) * ( a.getY() - b.getY() ) +
	       ( a.getZ() - b.getZ() ) * ( a.getZ() - b.getZ() ) );
}

void Position::calculateIntermediatePosition( Position&       buffer,
					      double          fraction,
					      const Position& a,
					      const Position& b ) {
  try {
    buffer.setX( (int)( a.getX() + 
			( (double)b.getX() - a.getX() ) * fraction ) );

    buffer.setY( (int)( a.getY() + 
			( (double)b.getY() - a.getY() ) * fraction ) );

    buffer.setZ( (int)( a.getZ() + 
			( (double)b.getZ() - a.getZ() ) * fraction ) );
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}
