#ifndef SLEWDATA_H
#define SLEWDATA_H

/**
 * This class represents data that plots a path that the gantry robot can follow. The
 * slew raw data is read from a file.
 */

#include "SlewRawData.h"

using namespace std;

class SlewData {
public:
  typedef SlewRawData::const_iterator const_iterator;

  SlewData( const char *filename ) : m_SlewRawData(  NULL ),
                                     m_BaseSpeed(    50   ),
                                     m_Interval(     30   ),
                                     m_Magnifier(    50   ),
                                     m_PositionComp( 300  ),
                                     m_SpeedMag(     1000 ) { 
    m_SlewRawData = new SlewRawData( filename );
  }

  virtual ~SlewData() { delete m_SlewRawData; }

  const SlewRawData& getRawData() const { return *m_SlewRawData;         }

  const_iterator begin()          const { return m_SlewRawData->begin(); }
  const_iterator end()            const { return m_SlewRawData->end();   }

  double getBaseSpeed()           const { return m_BaseSpeed;            }
  double getInterval()            const { return m_Interval;             }
  double getMagnifier()           const { return m_Magnifier;            }
  double getPositionComp()        const { return m_PositionComp;         }
  double getSpeedMag()            const { return m_SpeedMag;             }

  void setBaseSpeed(    double a ) { m_BaseSpeed    = a; }
  void setInterval(     double a ) { m_Interval     = a; }
  void setMagnifier(    double a ) { m_Magnifier    = a; }
  void setPositionComp( double a ) { m_PositionComp = a; }
  void setSpeedMag(     double a ) { m_SpeedMag     = a; }

protected:
  SlewRawData *m_SlewRawData;
  double       m_BaseSpeed;
  double       m_Interval;
  double       m_Magnifier;
  double       m_PositionComp;
  double       m_SpeedMag;
};

#endif
