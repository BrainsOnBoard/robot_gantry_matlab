// consoleTest.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <time.h>
#include <stdio.h>
#include "..\gantryRobot\RealGantryRobot.h"
#include "..\gantryRobot\SlewRawData.h"
#include "..\gantryRobot\SlewData.h"

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
    fprintf( stderr, "1 current position = %d,%d,%d\n", 
	         position.getX(),
	         position.getY(),
	         position.getZ() );
	}

	position.setX( 1000 );
	position.setY( 500 );
	position.setZ( 700 );

  gantryRobot->moveToPosition( position, false );

	while ( gantryRobot->getAreAnyAxisBusy() == true ) {
      gantryRobot->getPosition( position );
      fprintf( stderr, "2 current position = %d,%d,%d (%s,%s,%s)\n", 
	           position.getX(),
	           position.getY(),
	           position.getZ(),
             gantryRobot->getIsXAxisBusy() ? "busy" : "not busy",
             gantryRobot->getIsYAxisBusy() ? "busy" : "not busy",
             gantryRobot->getIsXAxisBusy() ? "busy" : "not busy" );
	}
}

static void testAxisMove( GantryRobot *gantryRobot ) {
	gantryRobot->moveToZPosition( 1000, true );
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

static void testSlewRawData() {
  SlewRawData slewRawData( "datafile.txt" );

  SlewRawData::const_iterator i;
  for ( i = slewRawData.begin(); i != slewRawData.end(); i++ ) {
    fprintf( stderr, "(%f,%f,%f)\n", i->m_X, i->m_Y, i->m_Z );
  }
}

static void testSlewData() {
  SlewData slewData( "datafile.txt" );

  SlewData::const_iterator i;
  for ( i = slewData.begin(); i != slewData.end(); i++ ) {
    fprintf( stderr, "(%f,%f,%f)\n", i->m_X, i->m_Y, i->m_Z );
  }
}

static void testFollowBeeSlewData( GantryRobot *gantryRobot ) {
  SlewData slewData( "datafilebee.txt" );

  slewData.setBaseSpeed(    0   );
  slewData.setInterval(     500 );
  slewData.setMagnifier(    3   );
  slewData.setPositionComp( 0   );
  slewData.setSpeedMag(     10  );

  gantryRobot->followSlewData( slewData );
}

static void testFollowAntSlewData( GantryRobot *gantryRobot ) {
  SlewData slewData( "datafileant.txt" );

  slewData.setBaseSpeed(    50   );
  slewData.setInterval(     30   );
  slewData.setMagnifier(    50   );
  slewData.setPositionComp( 300  );
  slewData.setSpeedMag(     1000 );

  gantryRobot->followSlewData( slewData );
}

static void testFollowRandomSlewData( GantryRobot *gantryRobot ) {
  SlewData slewData( "randomData.txt" );

  slewData.setBaseSpeed(    10  );
  slewData.setInterval(     200 );
  slewData.setMagnifier(    1   );
  slewData.setPositionComp( 0   );
  slewData.setSpeedMag(     10  );

  gantryRobot->followSlewData( slewData );
}

int main( int argc, char* argv[] ) {
  try {
    RealGantryRobot gantryRobot;
  
	  //testMove( &gantryRobot );
    //testIsAxisBusy( &gantryRobot );
	  //testAxisMove( &gantryRobot );
	  testHomePosition( &gantryRobot );
    //testEmergencyButton( &gantryRobot );
    //testSlewRawData();
    //testSlewData();
    //testFollowBeeSlewData( &gantryRobot );
    //testFollowAntSlewData( &gantryRobot );
    //testFollowRandomSlewData( &gantryRobot );

  } catch( SimpleException& e ) {
    fprintf( stderr, "exception=%s\n%s\n", e.toString().c_str(), e.getStackTrace().c_str() );
	exit( 1 );
  }
  
  return 0;
}
