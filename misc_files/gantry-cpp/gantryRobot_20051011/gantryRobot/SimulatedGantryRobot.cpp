#include "SimulatedGantryRobot.h"

/**
 * Points per second
 */
#define SPEED (0.1)

/**
 * A small fix to deal with rounding errors.
 */
#define EPS   (0.001)

SimulatedGantryRobot::SimulatedGantryRobot() : m_StartOfMoveTicks( 0 ) {
  try {
    if ( clock() == (clock_t)-1 ) {
      NotImplementedException e( "Clock is not implemented" );
      e.fillInStackTrace();
      throw e;
    }
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}

SimulatedGantryRobot::~SimulatedGantryRobot() { }

void SimulatedGantryRobot::getPosition( Position& positionBuffer ) const {
  try {
    if ( m_StartOfMoveTicks == 0 ) {
      positionBuffer = m_DesiredPosition;
    } else {
      /**
       * We have to see if enough time has passed so that the robot
       * will have reached the correct position.
       */
      double distance = Position::distanceBetweenPoints( m_DesiredPosition,
							 m_StartPosition );
      
      double currentTicks = clock();
      
      if ( distance * SPEED + EPS > 
	   ( m_StartOfMoveTicks - currentTicks ) /
	   (double)CLOCKS_PER_SEC ) {
	m_StartOfMoveTicks = 0;
	positionBuffer = m_DesiredPosition;
      } else {
	/**
	 * OK - final case. The robot is still moving. We need to calculate
	 * an intermediate position.
	 */
	double intermediateFraction = 
	  ( distance * SPEED ) / 
	  ( ( m_StartOfMoveTicks - currentTicks ) / (double)CLOCKS_PER_SEC );
	
	Position::calculateIntermediatePosition( positionBuffer,
						 intermediateFraction,
						 m_StartPosition,
						 m_DesiredPosition );
      }
    }
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}

const Position& SimulatedGantryRobot::getPosition() const {
  getPosition( m_TempPosition );
  return m_TempPosition;
}

void SimulatedGantryRobot::moveToHomePosition() {
  /**
   * The speed parameter is ignored for now.
   */
  Position pos( 0, 0, 0 );
  moveToPosition( pos, true );
}

void SimulatedGantryRobot::moveToHomeXPosition() {
  Position currentPos;
  getPosition( currentPos );
  currentPos.setX( 0 );

  moveToPosition( currentPos, true );
}

void SimulatedGantryRobot::moveToHomeYPosition() {
  Position currentPos;
  getPosition( currentPos );
  currentPos.setY( 0 );

  moveToPosition( currentPos, true );
}

void SimulatedGantryRobot::moveToHomeZPosition() {
  Position currentPos;
  getPosition( currentPos );
  currentPos.setZ( 0 );

  moveToPosition( currentPos, true );
}

void SimulatedGantryRobot::moveToPosition( const Position& position,
					   bool            waitFlag ) {
  m_DesiredPosition     = position;
  Position tempPosition = getPosition();
  m_StartPosition       = tempPosition;
  m_StartOfMoveTicks    = clock();
}

void SimulatedGantryRobot::moveToPosition( unsigned int x,
					   unsigned int y,
					   unsigned int z,
					   bool         waitFlag ) {
  Position pos( x, y, z );
  moveToPosition( pos, waitFlag );
}

void SimulatedGantryRobot::moveToXPosition( int  x,
					    bool waitFlag ) {
  Position currentPos;
  getPosition( currentPos );
  currentPos.setX( x );

  moveToPosition( currentPos, waitFlag );
}

void SimulatedGantryRobot::moveToYPosition( int  y,
					    bool waitFlag ) {
  Position currentPos;
  getPosition( currentPos );
  currentPos.setY( y );

  moveToPosition( currentPos, waitFlag );
}

void SimulatedGantryRobot::moveToZPosition( int  z,
					    bool waitFlag ) {
  Position currentPos;
  getPosition( currentPos );
  currentPos.setZ( z );

  moveToPosition( currentPos, waitFlag );
}

void SimulatedGantryRobot::setParameters(
	 GantryRobotAttributes::AccelerationType accelerationType,
	 unsigned int                            initialSpeed,
	 unsigned int                            driveSpeed,
	 unsigned int                            maxSpeed,
	 unsigned int                            accelerationSpeed,
	 unsigned int                            accelerationRate ) { }

void SimulatedGantryRobot::setXParameters(
         GantryRobotAttributes::AccelerationType accelerationType,
	 unsigned int                            initialSpeed,
	 unsigned int                            driveSpeed,
	 unsigned int                            maxSpeed,
	 unsigned int                            accelerationSpeed,
	 unsigned int                            accelerationRate ) { }

void SimulatedGantryRobot::setYParameters(
         GantryRobotAttributes::AccelerationType accelerationType,
	 unsigned int                            initialSpeed,
	 unsigned int                            driveSpeed,
	 unsigned int                            maxSpeed,
	 unsigned int                            accelerationSpeed,
	 unsigned int                            accelerationRate ) { }

void SimulatedGantryRobot::setZParameters(
         GantryRobotAttributes::AccelerationType accelerationType,
	 unsigned int                            initialSpeed,
	 unsigned int                            driveSpeed,
	 unsigned int                            maxSpeed,
	 unsigned int                            accelerationSpeed,
	 unsigned int                            accelerationRate ) { }

void SimulatedGantryRobot::setOutputBit( unsigned int outputBit,
					 bool         bitState  ) { }

bool SimulatedGantryRobot::getInputBit( unsigned int inputBit  ) const { 
  return false; 
}

bool SimulatedGantryRobot::stopAllAxis( bool ) {
  m_StartOfMoveTicks = 0;
  return false;
}

bool SimulatedGantryRobot::stopXAxis( bool ) {
  m_StartOfMoveTicks = 0;
  return false;
}

bool SimulatedGantryRobot::stopYAxis( bool ) {
  m_StartOfMoveTicks = 0;
  return false;
}

bool SimulatedGantryRobot::stopZAxis( bool ) {
  m_StartOfMoveTicks = 0;
  return false;
}

bool SimulatedGantryRobot::setXSpeed( unsigned int speed ) {
	return true;
}

bool SimulatedGantryRobot::setYSpeed( unsigned int speed ) {
	return true;
}

bool SimulatedGantryRobot::setZSpeed( unsigned int speed ) { 
	return true;
}

void SimulatedGantryRobot::reset() { }

bool SimulatedGantryRobot::getIsXAxisBusy() const {
  return ( m_StartOfMoveTicks != 0 );
}

bool SimulatedGantryRobot::getIsYAxisBusy() const {
  return ( m_StartOfMoveTicks != 0 );
}

bool SimulatedGantryRobot::getIsZAxisBusy() const {
  return ( m_StartOfMoveTicks != 0 );
}

bool SimulatedGantryRobot::getAreAnyAxisBusy() const {
  return ( m_StartOfMoveTicks != 0 );
}

bool SimulatedGantryRobot::getEmergencyStopButtonFlag() const {
  return false;
}

void SimulatedGantryRobot::waitUntilXAxisHasStopped() const {
  m_StartOfMoveTicks = 0;
}

void SimulatedGantryRobot::waitUntilYAxisHasStopped() const {
  m_StartOfMoveTicks = 0;
}

void SimulatedGantryRobot::waitUntilZAxisHasStopped() const {
  m_StartOfMoveTicks = 0;
}


void SimulatedGantryRobot::waitUntilAllAxisHaveStopped() const {
  m_StartOfMoveTicks = 0;
}
