#ifndef REALGANTRYROBOT_H
#define REALGANTRYROBOT_H

#ifndef IS_LINUX

#import "clsPCI1240.dll"
using namespace frmPCI1240;

#include "ADS1240.h"

#include "GantryRobot.h"
#include "SimpleException.h"
#include <vector>

using namespace std;

/**
 * Implements the GantryRobot to control the real gantry robot.
 * This is opposed to SimulatedGantryRobot that only uses a
 * model. The only way to create an instance of this class is
 * to use the createGantryRobot() method in GantryRobotFactory.
 */
class RealGantryRobot : public GantryRobot {
public:
  /**
   * Exception class that is thrown if a method is called that is not
   * yet implemented.
   */
  SIMPLE_EXCEPTION_CLASS( NotImplementedException )

  /**
   * Thrown if the instance cannot be initialised. This is probably because
   * the card cannot be connected.
   */
  SIMPLE_EXCEPTION_CLASS( CannotInitialiseException )

  /**
   * Thrown if there is a problem running one of the commands.
   */
  SIMPLE_EXCEPTION_CLASS( CommandErrorException )

  /**
   * Thrown if the robot didn't go to the axis in the timeout period.
   */
  SIMPLE_EXCEPTION_CLASS( DidNotHomeException );

  RealGantryRobot();
  virtual ~RealGantryRobot();

  void                      getPosition( Position& positionBuffer ) const;
  const Position&           getPosition()                           const;

  void moveToHomePosition();

  void moveToHomeXPosition();

  void moveToHomeYPosition();

  void moveToHomeZPosition();

  void moveToPosition(           const Position&    position,
		                 bool               waitFlag         );

  void moveToPosition(           unsigned int       x,
			         unsigned int       y,
			         unsigned int       z,
			         bool               waitFlag         );

  void moveToXPosition(          int       x,
			         bool               waitFlag         );

  void moveToYPosition(          int       y,
			         bool               waitFlag         );

  void moveToZPosition(          int       z,
			         bool               waitFlag         );

  void moveIncrementalDistance(  int                xDisplacement,
				 int                yDisplacement,
				 int                zDisplacement,
			 	 bool               waitFlag         );

  void moveIncrementalXDistance( int                xDisplacement,
				 bool               waitFlag         );

  void moveIncrementalYDistance( int                yDisplacement,
				 bool               waitFlag         );

  void moveIncrementalZDistance( int                zDisplacement,
				 bool               waitFlag         );

  void setParameters( 
       GantryRobotAttributes::AccelerationType accelerationType,
       unsigned int                            initialSpeed,
       unsigned int                            driveSpeed,
       unsigned int                            maxSpeed,
       unsigned int                            accelerationSpeed,
       unsigned int                            accelerationRate );

  void setXParameters( 
       GantryRobotAttributes::AccelerationType accelerationType,
       unsigned int                            initialSpeed,
       unsigned int                            driveSpeed,
       unsigned int                            maxSpeed,
       unsigned int                            accelerationSpeed,
       unsigned int                            accelerationRate );

  void setYParameters( 
       GantryRobotAttributes::AccelerationType accelerationType,
       unsigned int                            initialSpeed,
       unsigned int                            driveSpeed,
       unsigned int                            maxSpeed,
       unsigned int                            accelerationSpeed,
       unsigned int                            accelerationRate );

  void setZParameters( 
       GantryRobotAttributes::AccelerationType accelerationType,
       unsigned int                            initialSpeed,
       unsigned int                            driveSpeed,
       unsigned int                            maxSpeed,
       unsigned int                            accelerationSpeed,
       unsigned int                            accelerationRate );

  void        setOutputBit(                 unsigned int outputBit,
		                            bool         bitState  );

  bool        getInputBit(                  unsigned int inputBit  ) const;
  bool        stopAllAxis(                  bool slowDown );
  bool        stopXAxis(                    bool slowDown );
  bool        stopYAxis(                    bool slowDown );
  bool        stopZAxis(                    bool slowDown );
  bool        setXSpeed(                    unsigned int speed     );
  bool        setYSpeed(                    unsigned int speed     );
  bool        setZSpeed(                    unsigned int speed     );
  void        reset();
  bool        getIsXAxisBusy()                                       const;
  bool        getIsYAxisBusy()                                       const;
  bool        getIsZAxisBusy()                                       const;
  bool        getAreAnyAxisBusy()                                    const;
  bool        getEmergencyStopButtonFlag()                           const;
  void        waitUntilXAxisHasStopped()                             const;
  void        waitUntilYAxisHasStopped()                             const;
  void        waitUntilZAxisHasStopped()                             const;
  void        waitUntilAllAxisHaveStopped()                          const;

  void        followSlewData( const SlewData&, SlewUpdate * );

protected:
  /**
   * Acts as a buffer to store the results of the last time getRealPosition
   * was called.
   */
  mutable Position m_LastRecordedPosition;

  static CLSID        clsid;
  static _clsPCI1240 *t;

  void setDefaultParameters( int axis );
};

#endif /* IS_LINUX */

#endif
