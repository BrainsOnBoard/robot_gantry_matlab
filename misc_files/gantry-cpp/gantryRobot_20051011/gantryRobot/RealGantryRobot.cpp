#ifndef IS_LINUX

#include "RealGantryRobot.h"
#include <math.h>
#include <string>
#include <stdio.h>
#include <windows.h>
#include <time.h>

#define MOTOR_RATIO ((double)4.685)
#define HOME_OFFSETT       0x309
#define HOME_OFFSETT_SPEED 0x311
#define HOME_P0_DIRECTION  0x30c
#define HOME_P0_SPEED      0x30d
#define HOME_P1_DIRECTION  0x30e
#define HOME_P1_SPEED      0x30f
#define HOME_P2_DIRECTION  0x310
#define HOME_SPEED_INITIAL 0x301
#define HOME_TYPE          0x30b

using namespace std;

double round( double d ) {
  return (double)((int)( d + 0.5 ) );
}

CLSID        RealGantryRobot::clsid;
_clsPCI1240 *RealGantryRobot::t;

RealGantryRobot::RealGantryRobot() {
  try {
	  {
		  FILE *output = fopen( "dog.txt", "w" );
		  fprintf( output, "mouse 1\n" );
			fclose( output );
	  }
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

    if ( RealGantryRobot::t->blnInitialize( "c:\\PCI1240.ini" ) == false ) {
      CannotInitialiseException e( "Cannot initialise PCI1240 card" );
      e.fillInStackTrace();
      throw e;
    }

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
  
  positionBuffer.setX( (int)( (double)returnVal / MOTOR_RATIO ) );

  P1240MotRdReg( 0,
		 Y_AXIS,
		 0x101,
		 &returnVal );
  
  positionBuffer.setY( (int)( (double)returnVal / MOTOR_RATIO ) );

  P1240MotRdReg( 0,
		 Z_AXIS,
		 0x101,
		 &returnVal );
  
  positionBuffer.setZ( (int)( (double)returnVal / MOTOR_RATIO ) );
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

    clock_t timeoutTicks = clock() + 120 * CLOCKS_PER_SEC;
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

    clock_t timeoutTicks = clock() + 120 * CLOCKS_PER_SEC;
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
    fprintf( stderr, "z=%d\n", (int)Z_AXIS );
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

    clock_t timeoutTicks = clock() + 120 * CLOCKS_PER_SEC;
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
  {
		  FILE *output = fopen( "dog.txt", "a" );
		  fprintf( output, "goat 1 - %d\n", position.getZ() );
			fclose( output );
	  }
  P1240MotAxisParaSet( 0,
		       0,
		       0,
		       100,
		       1000,
		       1000,
		       4000,
		       1000000 );
  
  if ( t->blnMoveLine( (frmPCI1240::Axis)( 7 ),
		       true, position.getX(),
		       true, position.getY(),
		       true, position.getZ(),
		       true, 0 ) == false ) {
    char errMsg[ 1024 ];
    sprintf( errMsg, "Cannot moveToPosition( %d, %d, %d )",
             position.getX(), position.getY(), position.getZ() );
    
    CommandErrorException e( errMsg );
    e.fillInStackTrace();
    throw e;
  }
  
  if ( waitFlag == true ) {
    t->WaitForClear( X_AXIS );
    t->WaitForClear( Y_AXIS );
    t->WaitForClear( Z_AXIS );
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
}

void RealGantryRobot::moveToYPosition( int y,
				       bool         waitFlag ) {
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
}

void RealGantryRobot::moveToZPosition( int z,
				       bool         waitFlag ) {
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
  if ( t->blnSetParameters( 1,
			    accelerationType,
			    initialSpeed,
			    driveSpeed,
			    maxSpeed,
			    accelerationSpeed,
			    accelerationRate ) == false ) {
    CannotInitialiseException e( "Cannot set X parameters" );
    e.fillInStackTrace();
    throw e;
  }
}

void RealGantryRobot::setYParameters(
         GantryRobotAttributes::AccelerationType accelerationType,
	 unsigned int                            initialSpeed,
	 unsigned int                            driveSpeed,
	 unsigned int                            maxSpeed,
	 unsigned int                            accelerationSpeed,
	 unsigned int                            accelerationRate ) {
  if ( t->blnSetParameters( 2,
			    accelerationType,
			    initialSpeed,
			    driveSpeed,
			    maxSpeed,
			    accelerationSpeed,
			    accelerationRate ) == false ) {
    CannotInitialiseException e( "Cannot set Y parameters" );
    e.fillInStackTrace();
    throw e;
  }
}

void RealGantryRobot::setZParameters(
         GantryRobotAttributes::AccelerationType accelerationType,
	 unsigned int                            initialSpeed,
	 unsigned int                            driveSpeed,
	 unsigned int                            maxSpeed,
	 unsigned int                            accelerationSpeed,
	 unsigned int                            accelerationRate ) {
  if ( t->blnSetParameters( 3,
			    accelerationType,
			    initialSpeed,
			    driveSpeed,
			    maxSpeed,
			    accelerationSpeed,
			    accelerationRate ) == false ) {
    CannotInitialiseException e( "Cannot set Z parameters" );
    e.fillInStackTrace();
    throw e;
  }
}

void RealGantryRobot::setOutputBit( unsigned int outputBit,
				    bool         bitState  ) {
  if ( outputBit > 15 ) {
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
  }
}

bool RealGantryRobot::getInputBit( unsigned int inputBit ) const {
  if ( inputBit > 15 ) {
    char errMsg[ 1024 ];
    sprintf( errMsg, "Invalid bit number of %lu", inputBit );

    InvalidBitException e( errMsg );
    e.fillInStackTrace();
    throw e;
  }

  return ( t->blnInputStatus( inputBit ) == 0 ) ? false : true;
}

bool RealGantryRobot::stopAllAxis( bool slowDown ) {
  return stopXAxis( slowDown ) & stopYAxis( slowDown ) & stopZAxis( slowDown );
}

bool RealGantryRobot::stopXAxis( bool slowDown ) {
	return ( t->blnStopMotor( 1, !slowDown ) == 0 ) ? false : true;
}

bool RealGantryRobot::stopYAxis( bool slowDown ) {
	return ( t->blnStopMotor( 2, !slowDown ) == 0 ) ? false : true;
}

bool RealGantryRobot::stopZAxis( bool slowDown ) {
	return ( t->blnStopMotor( 3, !slowDown ) == 0 ) ? false : true;
}

bool RealGantryRobot::setXSpeed( unsigned int speed ) {

	return ( t->blnSetSpeed( X_AXIS, speed, 0, 0, 0 ) == 0 ) ? false : true;
}

bool RealGantryRobot::setYSpeed( unsigned int speed ) {
	return ( t->blnSetSpeed( Y_AXIS, 0, speed, 0, 0 ) == 0 ) ? false : true;
}

bool RealGantryRobot::setZSpeed( unsigned int speed ) {
	return ( t->blnSetSpeed( Z_AXIS, 0, 0, speed, 0 ) == 0 ) ? false : true;
}

void RealGantryRobot::reset() {
  if ( t->blnReset1240() == false ) {
    CannotResetException e( "Cannot reset the PCI1240 card" );
    e.fillInStackTrace();
    throw e;
  }
}

bool RealGantryRobot::getIsXAxisBusy() const {
	return ( t->blnAxisBusy( 1 ) == 0 ) ? false : true;
}

bool RealGantryRobot::getIsYAxisBusy() const {
	return ( t->blnAxisBusy( 2 ) == 0 ) ? false : true;
}

bool RealGantryRobot::getIsZAxisBusy() const {
	return ( t->blnAxisBusy( 3 ) == 0 ) ? false : true;
}

bool RealGantryRobot::getAreAnyAxisBusy() const {
  return getIsXAxisBusy() | getIsYAxisBusy() | getIsZAxisBusy(); 
}

bool RealGantryRobot::getEmergencyStopButtonFlag() const {
	return ( t->blnEmergencyStop() == 0 ) ? false : true;
}

void RealGantryRobot::waitUntilXAxisHasStopped() const {
  t->WaitForClear( X_AXIS );
}

void RealGantryRobot::waitUntilYAxisHasStopped() const {
  t->WaitForClear( Y_AXIS );
}

void RealGantryRobot::waitUntilZAxisHasStopped() const {
  t->WaitForClear( Z_AXIS );
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
		                 1000,   // drive speed
		                 1000,   // max speed
		                 4000,   // acceleration speed
		                 1000000 // acceleration rate
    );
}



#endif /* IS_LINUX */
