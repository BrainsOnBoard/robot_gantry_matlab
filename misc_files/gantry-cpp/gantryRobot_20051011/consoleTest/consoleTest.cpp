// consoleTest.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <time.h>
#include <stdio.h>
#include <gantryRobot/RealGantryRobot.h>

static void testMove( GantryRobot *gantryRobot ) {
    Position position;
    gantryRobot->getPosition( position );

    fprintf( stderr, "Start position = %d,%d,%d\n", 
	         position.getX(),
	         position.getY(),
	         position.getZ() );

	position.setX( 100 );
	position.setY( 0 );
	position.setZ( 50 );

    gantryRobot->moveToPosition( position, false );

    while ( gantryRobot->getAreAnyAxisBusy() == true ) {
      gantryRobot->getPosition( position );
      fprintf( stderr, "current position = %d,%d,%d\n", 
	           position.getX(),
	           position.getY(),
	           position.getZ() );
	}

	position.setX( 100 );
	position.setY( 100 );
	position.setZ( 50 );

    gantryRobot->moveToPosition( position, false );

	while ( gantryRobot->getAreAnyAxisBusy() == true ) {
      gantryRobot->getPosition( position );
      fprintf( stderr, "current position = %d,%d,%d\n", 
	           position.getX(),
	           position.getY(),
	           position.getZ() );
	}
}

static void testAxisMove( GantryRobot *gantryRobot ) {
	gantryRobot->moveToZPosition( 1000, false );
    fprintf( stderr, "goat 1\n" );
    Sleep( 5000 );
    fprintf( stderr, "goat 2\n" );
}

static void testHomePosition( GantryRobot *gantryRobot ) {
	gantryRobot->moveToHomePosition();
}

static void testEmergencyButton( GantryRobot *gantryRobot ) {
    Position position;
    position.setX( 100 );
	position.setY( 0 );
	position.setZ( 50 );

    gantryRobot->moveToPosition( position, false );

    clock_t timeoutTicks = clock() + 60 * CLOCKS_PER_SEC;
    do {
        fprintf( stderr, "Emergency button is %s\n",
            gantryRobot->getEmergencyStopButtonFlag() ? "on":"off" );
        Sleep( 500 );
    } while ( clock() < timeoutTicks );
}

int main( int argc, char* argv[] ) {
  try {
    RealGantryRobot gantryRobot;
  
	//testMove( &gantryRobot );
	//testAxisMove( &gantryRobot );
	//testHomePosition( &gantryRobot );
    testEmergencyButton( &gantryRobot );
  } catch( SimpleException& e ) {
    fprintf( stderr, "exception=%s\n", e.toString().c_str() );
	exit( 1 );
  }
  
  return 0;
}
