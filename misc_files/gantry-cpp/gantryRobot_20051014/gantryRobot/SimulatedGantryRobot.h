#ifndef SIMULATEDGANTRYROBOT_H
#define SIMULATEDGANTRYROBOT_H

#include "GantryRobot.h"
#include "SimpleException.h"
#include <vector>
#include <time.h>

using namespace std;

/**
 * Implements the GantryRobot to control a simulated gantry robot.
 * This is opposed to RealGantryRobot that moves the real gantry
 * robot. The only way to create an instance of this class is
 * to use the createGantryRobot() method in GantryRobotFactory.
 *
 * This class uses a very simple method of calculating the position.
 * If waiting is to be performed, it calculates the time required to
 * wait, and returns with the desired position set. If no waiting
 * is to be performed, then the final position is remembered and the
 * clock ticks remembered. Then everytime the position is asked for,
 * an estimation of the current position is provided by checking
 * where the robot should actually be.
 */

class SimulatedGantryRobot : public GantryRobot {
public:
  /**
   * Exception class that is thrown if a method is called that is not
   * yet implemented.
   */
  SIMPLE_EXCEPTION_CLASS( NotImplementedException )

  SimulatedGantryRobot();
  virtual ~SimulatedGantryRobot();

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

  void moveToXPosition(          int                x,
			         bool               waitFlag         );

  void moveToYPosition(          int                y,
			         bool               waitFlag         );

  void moveToZPosition(          int                z,
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
  bool        stopAllAxis( bool );
  bool        stopXAxis( bool );
  bool        stopYAxis( bool );
  bool        stopZAxis( bool );
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
  Position               m_DesiredPosition;

  /**
   * Stores the position when a move instruction is called.
   */
  Position               m_StartPosition;

  /**
   * Caches the position for returning directly to the user.
   */
  mutable Position       m_TempPosition;

  /**
   * Stores the clock ticks when a move instruction is called for.
   */
  mutable clock_t        m_StartOfMoveTicks;
};

#endif
