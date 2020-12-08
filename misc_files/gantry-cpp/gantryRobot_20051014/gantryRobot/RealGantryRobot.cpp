#ifndef IS_LINUX

#include "RealGantryRobot.h"
#include "SlewData.h"
#include "SlewUpdate.h"
#include <math.h>
#include <string>
#include <stdio.h>
#include <windows.h>
#include <time.h>

#define MOTOR_RATIO ((double)4.685)
#define HOME_OFFSETT        0x309
#define HOME_OFFSETT_SPEED  0x311
#define HOME_P0_DIRECTION   0x30c
#define HOME_P0_SPEED       0x30d
#define HOME_P1_DIRECTION   0x30e
#define HOME_P1_SPEED       0x30f
#define HOME_P2_DIRECTION   0x310
#define HOME_SPEED_INITIAL  0x301
#define HOME_TYPE           0x30b

#define SLOW_DOWN_THEN_STOP 0
#define STOP_IMMEDIATELY    1

#define MAX_POSITION_ERROR 2

using namespace std;

double round( double d ) {
  return (double)((int)( d + 0.5 ) );
}

CLSID        RealGantryRobot::clsid;
_clsPCI1240 *RealGantryRobot::t;

RealGantryRobot::RealGantryRobot() {
  try {

	HRESULT hresult;
    
    CoInitialize( NULL );
    
    hresult = CLSIDFromProgID( OLESTR( "frmPCI1240.clsPCI1240" ), &clsid );
    if ( hresult != S_OK ) {
      string errMsg;
      errMsg += "Couldn't get program ID - error states: ";
      
      switch( hresult ) {
      case CO_E_CLASSSTRING:
	errMsg += "registered CLSID for ProgID is invalid";
	break;
	
      case REGDB_E_WRITEREGDB:
	errMsg += "error occurred writing to the CLSID to the registry";
	break;
	
      default:
	errMsg += "unknown error (sorry!)";
	break;
      }
      
      CannotInitialiseException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }
    
    hresult = CoCreateInstance( clsid,
                                NULL,
                                CLSCTX_INPROC_SERVER,
                                __uuidof( _clsPCI1240 ),
                                (LPVOID *)&(RealGantryRobot::t) );
    
    if ( hresult != S_OK ) {
      string errMsg;
      errMsg += "Couldn't open PCI1240 Object - error states: ";

      switch( hresult ) {
      case REGDB_E_CLASSNOTREG:
        errMsg += "class not registered";
        break;

      case E_OUTOFMEMORY:
        errMsg += "out of memory";
        break;

      case E_INVALIDARG:
        errMsg += "invalid argument";
        break;
	
      case E_NOINTERFACE:
	errMsg += "no interface";
	break;
	
      case E_UNEXPECTED:
        errMsg += "unexpected error";
        break;

      case CLASS_E_NOAGGREGATION:
        errMsg += "cannot be treated as aggregation";
        break;

      default:
        errMsg += "unknown error (sorry!)";
        break;
      }

      CannotInitialiseException e( errMsg.c_str() );
      e.fillInStackTrace();
      throw e;
    }

    /*if ( RealGantryRobot::t->blnInitialize( "c:\\PCI1240.ini" ) == false ) {
      CannotInitialiseException e( "Cannot initialise PCI1240 card" );
      e.fillInStackTrace();
      throw e;
    }*/

    if ( P1240MotDevOpen( 0 ) != 0 ) {
      if ( P1240MotDevOpen( 0 ) != 0 ) {
        CannotInitialiseException e( "Cannot initialise PCI1240 card" );
        e.fillInStackTrace();
        throw e;
      }
    }

    setDefaultParameters( 0      );
    setDefaultParameters( X_AXIS );
    setDefaultParameters( Y_AXIS );
    setDefaultParameters( Z_AXIS );

    //RealGantryRobot::t->blnSwitchOutput( 1, true );
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}

RealGantryRobot::~RealGantryRobot() { }

void RealGantryRobot::getPosition( Position& positionBuffer ) const {
  unsigned long returnVal = 0;
  P1240MotRdReg( 0,
		 X_AXIS,
		 0x101,
		 &returnVal );
  
  positionBuffer.setX( (int)( round( (double)returnVal / MOTOR_RATIO ) ) );

  P1240MotRdReg( 0,
		 Y_AXIS,
		 0x101,
		 &returnVal );
  
  positionBuffer.setY( (int)( round( (double)returnVal / MOTOR_RATIO ) ) );

  P1240MotRdReg( 0,
		 Z_AXIS,
		 0x101,
		 &returnVal );
  
  positionBuffer.setZ( (int)( round( (double)returnVal / MOTOR_RATIO ) ) );
}

const Position& RealGantryRobot::getPosition() const {
  getPosition( m_LastRecordedPosition );
  return m_LastRecordedPosition;
}

void RealGantryRobot::moveToHomePosition() {
  moveToHomeXPosition();
  moveToHomeYPosition();
  moveToHomeZPosition();
}

void RealGantryRobot::moveToHomeXPosition() {
    P1240MotWrReg( 0, X_AXIS, HOME_P0_DIRECTION,  1 );
    P1240MotWrReg( 0, X_AXIS, HOME_P0_SPEED,      100 );
    P1240MotWrReg( 0, X_AXIS, HOME_P1_DIRECTION,  0 );
    P1240MotWrReg( 0, X_AXIS, HOME_P1_SPEED,      50 );
    P1240MotWrReg( 0, X_AXIS, HOME_P2_DIRECTION,  0 );
    P1240MotWrReg( 0, X_AXIS, HOME_OFFSETT,       10 );
    P1240MotWrReg( 0, X_AXIS, HOME_OFFSETT_SPEED, 50 );
    P1240MotWrReg( 0, X_AXIS, HOME_TYPE,          2 );
    P1240MotWrReg( 0, X_AXIS, HOME_SPEED_INITIAL, 100 );

    int ret = P1240MotHome( 0, X_AXIS );

    clock_t timeoutTicks = clock() + 5 * 60 * CLOCKS_PER_SEC;
    do {
        Sleep( 10 );
    } while ( clock() < timeoutTicks && !getEmergencyStopButtonFlag() && getIsXAxisBusy() );

    timeoutTicks = clock() + 120 * CLOCKS_PER_SEC;
    do {
        Sleep( 10 );
    } while ( clock() < timeoutTicks && !getEmergencyStopButtonFlag() && getIsXAxisBusy() );

    setDefaultParameters( X_AXIS );

    moveToXPosition( 100, true );
}

void RealGantryRobot::moveToHomeYPosition() {
    P1240MotWrReg( 0, Y_AXIS, HOME_P0_DIRECTION,  1 );
    P1240MotWrReg( 0, Y_AXIS, HOME_P0_SPEED,      100 );
    P1240MotWrReg( 0, Y_AXIS, HOME_P1_DIRECTION,  0 );
    P1240MotWrReg( 0, Y_AXIS, HOME_P1_SPEED,      50 );
    P1240MotWrReg( 0, Y_AXIS, HOME_P2_DIRECTION,  0 );
    P1240MotWrReg( 0, Y_AXIS, HOME_OFFSETT,       10 );
    P1240MotWrReg( 0, Y_AXIS, HOME_OFFSETT_SPEED, 50 );
    P1240MotWrReg( 0, Y_AXIS, HOME_TYPE,          2 );
    P1240MotWrReg( 0, Y_AXIS, HOME_SPEED_INITIAL, 100 );

    int ret = P1240MotHome( 0, Y_AXIS );

    clock_t timeoutTicks = clock() + 5 * 60 * CLOCKS_PER_SEC;
    do {
        Sleep( 10 );
    } while ( clock() < timeoutTicks && !getEmergencyStopButtonFlag() && getIsYAxisBusy() );

    timeoutTicks = clock() + 120 * CLOCKS_PER_SEC;
    do {
        Sleep( 10 );
    } while ( clock() < timeoutTicks && !getEmergencyStopButtonFlag() && getIsYAxisBusy() );


    setDefaultParameters( Y_AXIS );

    moveToYPosition( 100, true );
}

void RealGantryRobot::moveToHomeZPosition() {
    P1240MotWrReg( 0, Z_AXIS, HOME_P0_DIRECTION,  1 );
    P1240MotWrReg( 0, Z_AXIS, HOME_P0_SPEED,      100 );
    P1240MotWrReg( 0, Z_AXIS, HOME_P1_DIRECTION,  0 );
    P1240MotWrReg( 0, Z_AXIS, HOME_P1_SPEED,      50 );
    P1240MotWrReg( 0, Z_AXIS, HOME_P2_DIRECTION,  0 );
    P1240MotWrReg( 0, Z_AXIS, HOME_OFFSETT,       10 );
    P1240MotWrReg( 0, Z_AXIS, HOME_OFFSETT_SPEED, 50 );
    P1240MotWrReg( 0, Z_AXIS, HOME_TYPE,          2 );
    P1240MotWrReg( 0, Z_AXIS, HOME_SPEED_INITIAL, 100 );

    int ret = P1240MotHome( 0, Z_AXIS );

    clock_t timeoutTicks = clock() + 5 * 60 * CLOCKS_PER_SEC;
    do {
        Sleep( 10 );
    } while ( clock() < timeoutTicks && !getEmergencyStopButtonFlag() && getIsZAxisBusy() );

    timeoutTicks = clock() + 120 * CLOCKS_PER_SEC;
    do {
        Sleep( 10 );
    } while ( clock() < timeoutTicks && !getEmergencyStopButtonFlag() && getIsZAxisBusy() );


    setDefaultParameters( Z_AXIS );

    moveToZPosition( 100, true );
}

void RealGantryRobot::moveToPosition( const Position& position,
				                              bool            waitFlag ) {
    bool failed;

    if ( waitFlag == true ) {
        failed = true;
    } else {
        failed = false;
    }

    int      noOfTries = 0;
    Position currentPosition;
    do {
        int lngXPulses = (int)((double)position.getX() * MOTOR_RATIO);
        int lngYPulses = (int)((double)position.getY() * MOTOR_RATIO);
        int lngZPulses = (int)((double)position.getZ() * MOTOR_RATIO);

        int result = P1240MotLine( 0,
                                  1 + 2 + 4,
                                  1 + 2 + 4,
                                  lngXPulses,
                                  lngYPulses,
                                  lngZPulses,
                                  0 );
    
        if ( waitFlag == true ) {
            clock_t timeoutTicks = clock() + 120 * CLOCKS_PER_SEC;
            do {
                Sleep( 10 );
            } while ( clock() < timeoutTicks && !getEmergencyStopButtonFlag() && getIsXAxisBusy() );

            /**
             * We have to do a check here to ensure that the move was successful.
             */
            getPosition( currentPosition );

            double currentDistance = Position::distanceBetweenPoints( position, currentPosition );
        
            if ( currentDistance > -MAX_POSITION_ERROR && currentDistance < MAX_POSITION_ERROR ) {
                failed = false;
            }
        }
    } while ( failed == true && ++noOfTries < 10 && !getEmergencyStopButtonFlag() );

    if ( failed == true ) {
        char errMsg[ 1000 ];
        sprintf( errMsg, "Failed to move to position %d,%d,%d - position=%d,%d,%d", 
                 position.getX(),
                 position.getY(),
                 position.getZ(),
                 currentPosition.getX(),
                 currentPosition.getY(),
                 currentPosition.getZ() );

        CannotMoveToPositionException e( errMsg );
        e.fillInStackTrace();
        throw e;
    }
}

void RealGantryRobot::moveToPosition( unsigned int x,
				      unsigned int y,
				      unsigned int z,
				      bool         waitFlag ) {
  Position pos( x, y, z );
  moveToPosition( pos, waitFlag );
}

void RealGantryRobot::moveToXPosition( int  x,
		                                   bool waitFlag ) {
    bool failed;

    if ( waitFlag == true ) {
        failed = true;
    } else {
        failed = false;
    }

    int noOfTries = 0;
    unsigned long returnVal;
    double realPosition;

    do {
        int lngXPulses = (int)((double)x * MOTOR_RATIO);
        int result = P1240MotPtp( 0,
                                  1,
                                  1,
                                  lngXPulses,
                                  0,
                                  0,
                                  0 );
    
        if ( waitFlag == true ) {
            clock_t timeoutTicks = clock() + 120 * CLOCKS_PER_SEC;
            do {
                Sleep( 10 );
            } while ( clock() < timeoutTicks && !getEmergencyStopButtonFlag() && getIsXAxisBusy() );
        }

        /**
         * We have to do a check here to ensure that the move was successful.
         */
        returnVal = 0;
        P1240MotRdReg( 0,
		               X_AXIS,
		               0x101,
		               &returnVal );
  
        realPosition = returnVal;
        realPosition /= MOTOR_RATIO;
        realPosition -= x;

        if ( realPosition > -MAX_POSITION_ERROR && realPosition < MAX_POSITION_ERROR ) {
            failed = false;
        }
    } while ( failed == true && ++noOfTries < 10 && !getEmergencyStopButtonFlag() );

    if ( failed == true ) {
        char errMsg[ 1000 ];
        sprintf( errMsg, "Failed to move to %d X position - position=%ld", 
                 x, (int)(round( realPosition + x ) ) );

        CannotMoveToPositionException e( errMsg );
        e.fillInStackTrace();
        throw e;
    }
}

void RealGantryRobot::moveToYPosition( int  y,
				                               bool waitFlag ) {
    bool failed;

    if ( waitFlag == true ) {
        failed = true;
    } else {
        failed = false;
    }

    int noOfTries = 0;
    unsigned long returnVal;
    double realPosition;

    do {
        int lngYPulses = (int)((double)y * MOTOR_RATIO);
        int result = P1240MotPtp( 0,
                                  2,
                                  1,
                                  0,
                                  lngYPulses,
                                  0,
                                  0 );
    
        if ( waitFlag == true ) {
            clock_t timeoutTicks = clock() + 120 * CLOCKS_PER_SEC;
            do {
                Sleep( 10 );
            } while ( clock() < timeoutTicks && !getEmergencyStopButtonFlag() && getIsYAxisBusy() );
        }

        /**
         * We have to do a check here to ensure that the move was successful.
         */
        returnVal = 0;
        P1240MotRdReg( 0,
		               Y_AXIS,
		               0x101,
		               &returnVal );
  
        realPosition = returnVal;
        realPosition /= MOTOR_RATIO;
        realPosition -= y;

        if ( realPosition > -MAX_POSITION_ERROR && realPosition < MAX_POSITION_ERROR ) {
            failed = false;
        }
    } while ( failed == true && ++noOfTries < 10 && !getEmergencyStopButtonFlag() );

    if ( failed == true ) {
        char errMsg[ 1000 ];
        sprintf( errMsg, "Failed to move to %d Y position - position=%ld", 
                 y, (int)(round( realPosition + y ) ) );

        CannotMoveToPositionException e( errMsg );
        e.fillInStackTrace();
        throw e;
    }
}

void RealGantryRobot::moveToZPosition( int  z,
				                               bool waitFlag ) {
    bool failed;

    if ( waitFlag == true ) {
        failed = true;
    } else {
        failed = false;
    }

    int noOfTries = 0;
    unsigned long returnVal;
    double realPosition;

    do {
        int lngZPulses = (int)((double)z * MOTOR_RATIO);
        int result = P1240MotPtp( 0,
                                  4,
                                  1,
                                  0,
                                  0,
                                  lngZPulses,
                                  0 );
    
        if ( waitFlag == true ) {
            clock_t timeoutTicks = clock() + 120 * CLOCKS_PER_SEC;
            do {
                Sleep( 10 );
            } while ( clock() < timeoutTicks && !getEmergencyStopButtonFlag() && getIsZAxisBusy() );
        }

        /**
         * We have to do a check here to ensure that the move was successful.
         */
        returnVal = 0;
        P1240MotRdReg( 0,
		               Z_AXIS,
		               0x101,
		               &returnVal );
  
        realPosition = returnVal;
        realPosition /= MOTOR_RATIO;
        realPosition -= z;

        if ( realPosition > -MAX_POSITION_ERROR && realPosition < MAX_POSITION_ERROR ) {
            failed = false;
        }
    } while ( failed == true && ++noOfTries < 10 && !getEmergencyStopButtonFlag() );

    if ( failed == true ) {
        char errMsg[ 1000 ];
        sprintf( errMsg, "Failed to move to %d Z position - position=%ld", 
                 z, (int)(round( realPosition + z ) ) );

        CannotMoveToPositionException e( errMsg );
        e.fillInStackTrace();
        throw e;
    }
}

void RealGantryRobot::setParameters(
         GantryRobotAttributes::AccelerationType accelerationType,
	 unsigned int                            initialSpeed,
	 unsigned int                            driveSpeed,
	 unsigned int                            maxSpeed,
	 unsigned int                            accelerationSpeed,
	 unsigned int                            accelerationRate ) {
  try {
    setXParameters( accelerationType,
		    initialSpeed,
		    driveSpeed,
		    maxSpeed,
		    accelerationSpeed,
		    accelerationRate );

    setYParameters( accelerationType,
		    initialSpeed,
		    driveSpeed,
		    maxSpeed,
		    accelerationSpeed,
		    accelerationRate );

    setZParameters( accelerationType,
		    initialSpeed,
		    driveSpeed,
		    maxSpeed,
		    accelerationSpeed,
		    accelerationRate );
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}

void RealGantryRobot::setXParameters(
         GantryRobotAttributes::AccelerationType accelerationType,
	 unsigned int                            initialSpeed,
	 unsigned int                            driveSpeed,
	 unsigned int                            maxSpeed,
	 unsigned int                            accelerationSpeed,
	 unsigned int                            accelerationRate ) {
  P1240MotAxisParaSet( 0, 
                       X_AXIS, 
                       accelerationType, 
                       initialSpeed, 
                       driveSpeed, 
                       maxSpeed, 
                       accelerationSpeed, 
                       accelerationRate );
}

void RealGantryRobot::setYParameters(
         GantryRobotAttributes::AccelerationType accelerationType,
	 unsigned int                            initialSpeed,
	 unsigned int                            driveSpeed,
	 unsigned int                            maxSpeed,
	 unsigned int                            accelerationSpeed,
	 unsigned int                            accelerationRate ) {
  P1240MotAxisParaSet( 0, 
                       Y_AXIS, 
                       accelerationType, 
                       initialSpeed, 
                       driveSpeed, 
                       maxSpeed, 
                       accelerationSpeed, 
                       accelerationRate );
}

void RealGantryRobot::setZParameters(
         GantryRobotAttributes::AccelerationType accelerationType,
	 unsigned int                            initialSpeed,
	 unsigned int                            driveSpeed,
	 unsigned int                            maxSpeed,
	 unsigned int                            accelerationSpeed,
	 unsigned int                            accelerationRate ) {
  P1240MotAxisParaSet( 0, 
                       Z_AXIS, 
                       accelerationType, 
                       initialSpeed, 
                       driveSpeed, 
                       maxSpeed, 
                       accelerationSpeed, 
                       accelerationRate );
}

void RealGantryRobot::setOutputBit( unsigned int /*outputBit*/,
				    bool         /*bitState*/  ) {
  /**
   * This is currently not working. The reason for this is known and it will be
   * fixed soon!
   */
  /*if ( outputBit > 15 ) {
    char errMsg[ 1024 ];
    sprintf( errMsg, "Invalid bit number of %lu", outputBit );

    InvalidBitException e( errMsg );
    e.fillInStackTrace();
    throw e;
  }

  if ( t->blnSwitchOutput( outputBit, bitState ) == false ) {
    char errMsg[ 1024 ];
    sprintf( errMsg, "Cannot set bit %lu", outputBit );

    CannotSetBitException e( errMsg );
    e.fillInStackTrace();
    throw e;
  }*/
}

bool RealGantryRobot::getInputBit( unsigned int /*inputBit*/ ) const {
  /**
   * This is currently not working. The reason for this is known and it will be
   * fixed soon!
   */
  /*if ( inputBit > 15 ) {
    char errMsg[ 1024 ];
    sprintf( errMsg, "Invalid bit number of %lu", inputBit );

    InvalidBitException e( errMsg );
    e.fillInStackTrace();
    throw e;
  }

  return ( t->blnInputStatus( inputBit ) == 0 ) ? false : true;*/

  return false;
}

bool RealGantryRobot::stopAllAxis( bool slowDown ) {
  return stopXAxis( slowDown ) & stopYAxis( slowDown ) & stopZAxis( slowDown );
}

bool RealGantryRobot::stopXAxis( bool slowDown ) {
	//return ( t->blnStopMotor( 1, !slowDown ) == 0 ) ? false : true;
  return P1240MotStop( 0, 
                       X_AXIS, 
                       slowDown == true ? SLOW_DOWN_THEN_STOP : STOP_IMMEDIATELY ) == 0 ? true : false;
}

bool RealGantryRobot::stopYAxis( bool slowDown ) {
	//return ( t->blnStopMotor( 2, !slowDown ) == 0 ) ? false : true;
  return P1240MotStop( 0, 
                       Y_AXIS, 
                       slowDown == true ? SLOW_DOWN_THEN_STOP : STOP_IMMEDIATELY ) == 0 ? true : false;
}

bool RealGantryRobot::stopZAxis( bool slowDown ) {
	//return ( t->blnStopMotor( 3, !slowDown ) == 0 ) ? false : true;
  return P1240MotStop( 0, 
                       Z_AXIS, 
                       slowDown == true ? SLOW_DOWN_THEN_STOP : STOP_IMMEDIATELY ) == 0 ? true : false;
}

bool RealGantryRobot::setXSpeed( unsigned int speed ) {
  /**
   * This is currently not working. The reason for this is known and it will be
   * fixed soon!
   */
	//return ( t->blnSetSpeed( X_AXIS, speed, 0, 0, 0 ) == 0 ) ? false : true;
  return false;
}

bool RealGantryRobot::setYSpeed( unsigned int speed ) {
	/**
   * This is currently not working. The reason for this is known and it will be
   * fixed soon!
   */
  //return ( t->blnSetSpeed( Y_AXIS, 0, speed, 0, 0 ) == 0 ) ? false : true;
  return false;
}

bool RealGantryRobot::setZSpeed( unsigned int speed ) {
	/**
   * This is currently not working. The reason for this is known and it will be
   * fixed soon!
   */
  //return ( t->blnSetSpeed( Z_AXIS, 0, 0, speed, 0 ) == 0 ) ? false : true;
  return false;
}

void RealGantryRobot::reset() {
  if ( P1240MotReset( 0 ) == 0 ) {
    CannotResetException e( "Cannot reset the PCI1240 card" );
    e.fillInStackTrace();
    throw e;
  }
}

bool RealGantryRobot::getIsXAxisBusy() const {
	return P1240MotAxisBusy( 0, X_AXIS ) != 0 ? true : false;
}

bool RealGantryRobot::getIsYAxisBusy() const {
	return P1240MotAxisBusy( 0, Y_AXIS ) != 0 ? true : false;
}

bool RealGantryRobot::getIsZAxisBusy() const {
	return P1240MotAxisBusy( 0, Z_AXIS ) != 0 ? true : false;
}

bool RealGantryRobot::getAreAnyAxisBusy() const {
  return getIsXAxisBusy() | getIsYAxisBusy() | getIsZAxisBusy(); 
}

bool RealGantryRobot::getEmergencyStopButtonFlag() const {
	unsigned long returnVal = 0;
  P1240MotRdReg( 0, 1, RR2, &returnVal );
  return ( returnVal & 32 ) != 0 ? true : false;
}

void RealGantryRobot::waitUntilXAxisHasStopped() const {
  //t->WaitForClear( X_AXIS );
  while ( getIsXAxisBusy() ) { }
}

void RealGantryRobot::waitUntilYAxisHasStopped() const {
  //t->WaitForClear( Y_AXIS );
  while ( getIsYAxisBusy() ) { }
}

void RealGantryRobot::waitUntilZAxisHasStopped() const {
  //t->WaitForClear( Z_AXIS );
  while ( getIsZAxisBusy() ) { }
}

void RealGantryRobot::waitUntilAllAxisHaveStopped() const {
  waitUntilXAxisHasStopped();
  waitUntilYAxisHasStopped();
  waitUntilZAxisHasStopped();
}

void RealGantryRobot::setDefaultParameters( int axis ) {
  P1240MotAxisParaSet( 0,      // board ID 
		                 axis,   // Axis no
		                 0,      // acceleration type
		                 100,    // initial speed
		                 11000,   // drive speed
		                 11000,   // max speed
		                 4000,   // acceleration speed
		                 1000000 // acceleration rate
  );
}

void RealGantryRobot::followSlewData( const SlewData& slewData, SlewUpdate *slewUpdate ) {
  try {
    SlewData::const_iterator currentCoordinate;
    SlewData::const_iterator lastCoordinate;
    bool                     finishNow = false;

    for ( currentCoordinate = slewData.begin(); 
          currentCoordinate != slewData.end() && 
            finishNow == false                && 
            getEmergencyStopButtonFlag() == false;
          currentCoordinate++ ) {
      if ( currentCoordinate == slewData.begin() ) {
        /**
         * We just have to move to the start quickly.
         */
        P1240MotAxisParaSet( 0,      // board ID 
		                         0,      // Axis no
		                         0,      // acceleration type
		                         100,    // initial speed
		                         4000,   // drive speed
		                         4000,   // max speed
		                         4000,   // acceleration speed
		                         1000000 // acceleration rate
        );

        moveToPosition( currentCoordinate->m_X,
                        currentCoordinate->m_Y,
                        currentCoordinate->m_Z,
                        true );
        /*fprintf( stderr, "start move to = %f,%f,%f\n", 
                 currentCoordinate->m_X, 
                 currentCoordinate->m_Y, 
                 currentCoordinate->m_Z );*/
        
        lastCoordinate = currentCoordinate;

        currentCoordinate++;
      }

      double vectorX, vectorY, vectorZ;
      vectorX = currentCoordinate->m_X - lastCoordinate->m_X;
      vectorY = currentCoordinate->m_Y - lastCoordinate->m_Y;
      vectorZ = currentCoordinate->m_Z - lastCoordinate->m_Z;

      double magnitude = sqrt( vectorX * vectorX +
                               vectorY * vectorY +
                               vectorZ * vectorZ );

      int axisSpeed = (int)round((double)slewData.getBaseSpeed() + magnitude * slewData.getSpeedMag() );

      vectorX *= slewData.getMagnifier();
      vectorY *= slewData.getMagnifier();
      vectorZ *= slewData.getMagnifier();

      /**
       * Now to move to the line...
       */
      stopXAxis( false );
      waitUntilAllAxisHaveStopped();

      P1240MotAxisParaSet( 0,         // board ID 
		                       0,         // Axis no
		                       0,         // acceleration type
		                       axisSpeed, // initial speed
		                       axisSpeed, // drive speed
		                       axisSpeed, // max speed
		                       4000,      // acceleration speed
		                       1000000    // acceleration rate
      );

      Position currentPosition = getPosition();
      currentPosition.setX( currentPosition.getX() + vectorX );
      currentPosition.setY( currentPosition.getY() + vectorY );
      currentPosition.setZ( currentPosition.getZ() + vectorZ );

      moveToPosition( currentPosition.getX(),
                      currentPosition.getY(),
                      currentPosition.getZ(),
                      false );
     
      clock_t clockTicks = clock() + 
        (int)round( (double)CLOCKS_PER_SEC * slewData.getInterval() / 1000.0 );

      if ( slewUpdate != NULL ) {
        if ( slewUpdate->performSlewUpdate() == false ) {
          finishNow = true;
        }
      }

      //fprintf( stderr, "Sleed=%d\n", 
      //         (int)round( (double)1000.0 * ( clockTicks - clock() ) / CLOCKS_PER_SEC ) );
      Sleep( (int)round( (double)1000.0 * ( clockTicks - clock() ) / CLOCKS_PER_SEC ) );

      lastCoordinate = currentCoordinate;
    }

    stopAllAxis( false );
  } catch( SimpleException& e ) {
    e.fillInStackTrace();
    throw;
  }
}

#endif /* IS_LINUX */
