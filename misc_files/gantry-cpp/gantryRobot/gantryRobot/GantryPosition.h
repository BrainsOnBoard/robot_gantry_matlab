#ifndef GANTRYPOSITION_H
#define GANTRYPOSITION_H

#include "Serialisable.h"
#include "SimpleException.h"

/**
 * Represents a position within the GantryRobot.
 * Represents a position within the GantryRobot. The maximum positions are
 * given by GantryRobot::MAX_X etc. The class is serialiable,
 * which means it must implement the methods readObject and 
 * writeObject for storing to a file.
 */
class GantryPosition : public Serialisable {
public:
  /**
   * Exception class thrown in case a position is set outside the gantry
   * robot.
   */
  SIMPLE_EXCEPTION_CLASS( InvalidPositionException )

  /**
   * Constructs a Position instance with a position of ( 0, 0, 0 ).
   */
  GantryPosition();

  /**
   * Constructs a GantryPosition instance given the position in millimeters.
   * Constructs a GantryPosition instance given the position in millimeters. The
   * maximum position is provided by GantryRobot::MAX_X, etc.
   *
   * @param     x                        Position of <i>x</i> coordinates in
   *                                     millimeters.
   * @param     y                        Position of <i>y</i> coordinates in
   *                                     millimeters.
   * @param     z                        Position of <i>z</i> coordinates in
   *                                     millimeters.
   * @exception InvalidPositionException the robot cannot go to the given
   *                                     position.
   */
  GantryPosition( int x,
	        int y,
	        int z );

  virtual ~GantryPosition() { }

  /**
   * Returns the position of the X axis in millimeters.
   *
   * @returns X position.
   */
  int getX() const { return m_X; }

  /**
   * Returns the position of the Y axis in millimeters.
   *
   * @returns Y position.
   */
  int getY() const { return m_Y; }

  /**
   * Returns the position of the Z axis in millimeters.
   *
   * @returns Z position.
   */
  int getZ() const { return m_Z; }

  /**
   * Sets the position of the X axis in millimeters.
   *
   * @param     x                        New position of the X axis.
   * @exception InvalidPositionException the position is now invalid.
   */
  void setX( int x );

  /**
   * Sets the position of the Y axis in millimeters.
   *
   * @param     y                        New position of the Y axis.
   * @exception InvalidPositionException the position is now invalid.
   */
  void setY( int y );

  /**
   * Sets the position of the Z axis in millimeters.
   *
   * @param     z                        New position of the Z axis.
   * @exception InvalidPositionException the position is now invalid.
   */
  void setZ( int z );

  /**
   * A static method to calculate the distance between two positions.
   */
  static double distanceBetweenPoints( const GantryPosition&, const GantryPosition& );

  /**
   * A static method to calculate an intermediate position the fraction
   * of the distance from one point to another.
   */
  static void calculateIntermediatePosition( GantryPosition&       buffer,
					     double          fraction,
					     const GantryPosition&,
					     const GantryPosition& );
  /**
   * Reads the object in from the given string. 
   * Reads the object in from the given string. The string is 
   * always stored and written in a human readable format 
   * with tags. This method acts as a token analyser.
   *
   * @param     str                          A pointer to the beginning of
   *                                         the string to be read.
   * @returns                                A pointer to the area immediately
   *                                         after the stored Position.
   * @exception InvalidPositionDataException the string cannot be converted
   *                                         to a Position instance.
   */
  const char *readObject( const char *str );

  /**
   * Writes the object to the end of the given string. 
   * Writes the object to the end of the given string. The string is 
   * always stored and written in a human readable format 
   * with tags. This method acts as a token analyser.
   *
   * @param     buffer The string to write the position data to.
   */
  void writeObject( string& buffer );

protected:
  /**
   * Stored the X axis position in millimeters.
   */
  int m_X;

   /**
   * Stored the Y axis position in millimeters.
   */
  int m_Y;

   /**
   * Stored the Z axis position in millimeters.
   */
  int m_Z;
};

#endif
