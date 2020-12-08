#ifndef SLEWRAWDATA_H
#define SLEWRAWDATA_H

/**
 * This class represents a raw list of data. It can be created with a filename, in
 * which case the data fields should be comma-delimited and in the following order:
 *
 * Trial ref (this is ignored by the program)
 * frame number (also ignored by the program)
 * X coordinate
 * Y coordinate
 * orientation (ignored by program)
 * height (Z coordinate)
 * pitch (ignored by program)
 */

#include <vector>
#include <stdio.h>
#include "SimpleException.h"

using namespace std;

class SlewRawData {
public:
  SIMPLE_EXCEPTION_CLASS( CannotOpenFileException );
  SIMPLE_EXCEPTION_CLASS( ParseException          );

  struct RawCoordinate {
    double m_X;
    double m_Y;
    double m_Z;
  };
  
  typedef vector<RawCoordinate>::const_iterator const_iterator;

  SlewRawData() { }
  SlewRawData( const char *filename );
  virtual ~SlewRawData() { }

  const_iterator begin() const { return m_Coordinates.begin(); }
  const_iterator end()   const { return m_Coordinates.end();   }

  /**
   * A method for constructing slew data on the fly.
   */
  void addData( double x, double y, double z );

  void save( const char *filename );

protected:
  enum { NUMBER_TOKEN, COMMA_TOKEN, NEWLINE_TOKEN, ENDOFFILE_TOKEN, UNKNOWN_TOKEN };

  int readToken( FILE *, string&, int *lineNo );

  vector<RawCoordinate> m_Coordinates;
};

#endif
