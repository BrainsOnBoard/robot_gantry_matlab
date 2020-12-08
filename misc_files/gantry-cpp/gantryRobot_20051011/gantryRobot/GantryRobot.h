#ifndef GANTRYROBOT_H
#define GANTRYROBOT_H

/*
 * This class represents the gantry robot. Further details in DOxygen
 * format below.
 *
 * Copyright Sussex University 2005
 */

#include "Position.h"
#include "GantryRobotAttributes.h"
#include "SimpleException.h"

/**
 * Represents the GantryRobot.
 * Represents the GantryRobot. This class is only an interface
 * and is actually implemented by either RealGantryRobot or
 * SimulatedGantryRobot. The only way to create an instance of
 * either of these classes is by using the GantryRobotFactory
 * class.<p>
 * The class is observable and sends a single whenever a method 
 * is called that alters the class. This is used by the Recorder 
 * class to record all the methods called so they can be replayed 
 * back at a later time.
 */
class GantryRobot {
public:
  SIMPLE_EXCEPTION_CLASS( CannotReturnHomeException );
  SIMPLE_EXCEPTION_CLASS( CannotInitialiseException );
  SIMPLE_EXCEPTION_CLASS( InvalidBitException       );
  SIMPLE_EXCEPTION_CLASS( CannotSetBitException     );
  SIMPLE_EXCEPTION_CLASS( CannotResetException      );

  /**
   * Destroys the GantryRobot instance and uninitialises the driver card.
   * Destroys the GentryRobot instance and uninitialises the driver card.
   * Note that this should never be called by the user. It is a static 
   * variable and this method is called when the program ends.
   */
  virtual ~GantryRobot() { }

  /**
   * Returns the position in millimeters.
   * Returns the position in millimeters. This is obtained from
   * the encoder for each axis.
   *
   * @see   getPosition
   * @param positionBuffer A class to place the current position of the robot.
   */
  virtual void getPosition( Position& positionBuffer ) const = 0;

  /**
   * Returns the position in millimeters.
   * Returns the position in millimeters. This is obtained from
   * the encoder for each axis.
   *
   * @see     getPosition() const
   * @returns The current position of the robot.
   */
  virtual const Position& getPosition() const = 0;

  /**
   * Returns the robot to the <i>home</i> position.
   * Returns the robot to the <i>home</i> position of all the axes.
   * This is equivilent to setting the position to Position( 0, 0, 0 ).
   * You can express whether or not to wait until the robot reaches
   * the home position before continuing. 
   * 
   * @exception CannotReturnHomeException  called when the robot cannot 
   *                                       return to the home position
   * @see       moveToHomeXPosition
   * @see       moveToHomeYPosition
   * @see       moveToHomeZPosition
   */
  virtual void moveToHomePosition() = 0;

  /**
   * Returns the robot to the home position in the X axis.
   * Returns the robot to the home position in the X axis. The positions
   * of the other axes are unchanged.
   *
   * @exception CannotReturnHomeException  called when the robot cannot 
   *                                       return to the home position
   * @see       moveToHomePosition
   * @see       moveToHomeYPosition
   * @see       moveToHomeZPosition
   */
   virtual void moveToHomeXPosition() = 0;
   
   /**
    * Returns the robot to the home position in the Y axis.
    * Returns the robot to the home position in the Y axis. The positions
    * of the other axes are unchanged.
    *
    * @exception CannotReturnHomeException  called when the robot cannot 
    *                                       return to the home position
    * @see       moveToHomePosition
    * @see       moveToHomeXPosition
    * @see       moveToHomeZPosition
    */
   virtual void moveToHomeYPosition() = 0;
   
   /**
    * Returns the robot to the home position in the Z axis.
    * Returns the robot to the home position in the Z axis. The positions
    * of the other axes are unchanged.
    *
    * @exception CannotReturnHomeException  called when the robot cannot 
    *                                       return to the home position
    * @see       moveToHomePosition
    * @see       moveToHomeXPosition
    * @see       moveToHomeYPosition
    */
   virtual void moveToHomeZPosition() = 0;

   /**
    * Moves the robot to the given absolute position.
    * Moves the robot to the given absolute position. A flag can be
    * set for the method to only return once the position has
    * been reached.
    *
    * @param     position                      The desired position
    * @param     waitFlag                      A boolean flag to state whether 
    *                                          to wait or not.
    * @exception CannotMoveToPositionException the robot cannot move the to 
    *                                          given position.
    * @see moveToXPosition
    * @see moveToYPosition
    * @see moveToZPosition
    */
   virtual void moveToPosition( const Position& position,
				bool            waitFlag = true ) = 0;

   /**
    * Moves the robot to the given absolute position.
    * Moves the robot to the given absolute position. A flag can be
    * set for the method to only return once the position has
    * been reached.
    *
    * @param     x                             The x position in millimeters
    * @param     y                             The y position in millimeters
    * @param     z                             The z position in millimeters
    * @param     waitFlag                      A boolean flag to state whether
    *                                          to wait or not.
    * @exception CannotMoveToPositionException the robot cannot move to the
    *                                          given position.
    * @see moveToXPosition
    * @see moveToYPosition
    * @see moveToZPosition
    */
   virtual void moveToPosition( unsigned int    x,
				unsigned int    y,
				unsigned int    z,
				bool            waitFlag = true ) = 0;

   /**
    * Moves the robot to the x position.
    * Moves the robot to the x position. The position of the remaining
    * axes remains the same.
    *
    * @param     x                             The x position in millimeters
    * @param     waitFlag                      A boolean flag to state whether
    *                                          to wait or not.
    * @exception CannotMoveToPositionException the robot cannot move to the
    *                                          given <i>x</i> position.
    * @see moveToPosition
    * @see moveToYPosition
    * @see moveToZPosition
    */
   virtual void moveToXPosition( int  x,
				 bool          waitFlag = true ) = 0;

   /**
    * Moves the robot to the y position.
    * Moves the robot to the y position. The position of the remaining
    * axes remains the same.
    *
    * @param     y                             The y position in millimeters
    * @param     waitFlag                      A boolean flag to state whether
    *                                          to wait or not.
    * @exception CannotMoveToPositionException the robot cannot move to the
    *                                          given <i>y</i> position.
    * @see moveToPosition
    * @see moveToXPosition
    * @see moveToZPosition
    */
   virtual void moveToYPosition( int  y,
				 bool          waitFlag = true ) = 0;

   /**
    * Moves the robot to the z position.
    * Moves the robot to the z position. The position of the remaining
    * axes remains the same.
    *
    * @param     z                             The z position in millimeters
    * @param     waitFlag                      A boolean flag to state whether
    *                                          to wait or not.
    * @exception CannotMoveToPositionException the robot cannot move to the
    *                                          given <i>z</i> position.
    * @see moveToPosition
    * @see moveToXPosition
    * @see moveToYPosition
    */
   virtual void moveToZPosition( int  z,
				 bool          waitFlag = true ) = 0;

   /**
    * Sets all the motion parameters for all the axes.
    * Sets all the motion parameters for all the axes. This is the
    * place to set all the details such as acceleration, speed,
    * etc.
    *
    * @param accelerationType     Specifies the acceleration type and must
    *                             be either 
    *                             GantryRobotAttributes::ACCELERATION_TYPE_T
    *                             or 
    *                             GantryRobotAttributes::ACCELERATION_TYPE_S.
    * @param initialSpeed                  Initial speed of all the axes. 
    *                                      Must be between 1..8000.
    * @param driveSpeed                    The final drive speed of the
    *                                      axes. Must be between 1..8000.
    * @param maxSpeed                      Maximum allowable speed of the
    *                                      axes. Must be between 1..8000.
    * @param accelerationSpeed             Acceleration of the axes. Must be
    *                                      between 125..500000000.
    * @param accelerationRate              Acceleration rate of the axes.
    *                                      Must be between 954..2000000000.
    * @exception InvalidParameterException one of the parameters is invalid
    * @exception CannotInitialiseException the gantry robot cannot initialise
    *                                      with the parameters provided.
    * @see setXParameters
    * @see setYParameters
    * @see setZParameters
    */
   virtual void setParameters( 
       GantryRobotAttributes::AccelerationType accelerationType,
       unsigned int                            initialSpeed,
       unsigned int                            driveSpeed,
       unsigned int                            maxSpeed,
       unsigned int                            accelerationSpeed,
       unsigned int                            accelerationRate ) = 0;

   /**
    * Sets all the motion parameters for the X axis.
    * Sets all the motion parameters for the X axis. This is the
    * place to set all the details such as acceleration, speed,
    * etc.
    *
    * @param accelerationType     Specifies the acceleration type and must
    *                             be either 
    *                             GantryRobotAttributes::ACCELERATION_TYPE_T
    *                             or 
    *                             GantryRobotAttributes::ACCELERATION_TYPE_S.
    * @param initialSpeed                  Initial speed of the X axes.
    *                                      Must be between 1..8000.
    * @param driveSpeed                    The final drive speed of the X
    *                                      axis. Must be between 1..8000.
    * @param maxSpeed                      Maximum allowable speed of the X
    *                                      axis. Must be between 1..8000.
    * @param accelerationSpeed             Acceleration of the X axis. Must
    *                                      be between 125..500000000.
    * @param accelerationRate              Acceleration rate of the X axis.
    *                                      Must be between 954..2000000000.
    * @exception InvalidParameterException one of the parameters is invalid
    * @exception CannotInitialiseException the gantry robot cannot initialise
    *                                      with the parameters provided.
    * @see setParameters
    * @see setYParameters
    * @see setZParameters
    */
   virtual void setXParameters( 
       GantryRobotAttributes::AccelerationType accelerationType,
       unsigned int                            initialSpeed,
       unsigned int                            driveSpeed,
       unsigned int                            maxSpeed,
       unsigned int                            accelerationSpeed,
       unsigned int                            accelerationRate ) = 0;

   /**
    * Sets all the motion parameters for the Y axis.
    * Sets all the motion parameters for the Y axis. This is the
    * place to set all the details such as acceleration, speed,
    * etc.
    *
    * @param accelerationType     Specifies the acceleration type and must
    *                             be either 
    *                             GantryRobotAttributes::ACCELERATION_TYPE_T
    *                             or 
    *                             GantryRobotAttributes::ACCELERATION_TYPE_S.
    * @param initialSpeed                  Initial speed of the Y axes. Must
    *                                      be between 1..8000.
    * @param driveSpeed                    The final drive speed of the Y
    *                                      axis. Must be between 1..8000.
    * @param maxSpeed                      Maximum allowable speed of the Y
    *                                      axis. Must be between 1..8000.
    * @param accelerationSpeed             Acceleration of the Y axis. Must
    *                                      be between 125..500000000.
    * @param accelerationRate              Acceleration rate of the Y axis.
    *                                      Must be between 954..2000000000.
    * @exception InvalidParameterException one of the parameters is invalid
    * @exception CannotInitialiseException the gantry robot cannot initialise
    *                                      with the parameters provided.
    * @see setParameters
    * @see setXParameters
    * @see setZParameters
    */
   virtual void setYParameters( 
       GantryRobotAttributes::AccelerationType accelerationType,
       unsigned int                            initialSpeed,
       unsigned int                            driveSpeed,
       unsigned int                            maxSpeed,
       unsigned int                            accelerationSpeed,
       unsigned int                            accelerationRate ) = 0;

   /**
    * Sets all the motion parameters for the Z axis.
    * Sets all the motion parameters for the Z axis. This is the
    * place to set all the details such as acceleration, speed,
    * etc.
    *
    * @param accelerationType     Specifies the acceleration type and must
    *                             be either 
    *                             GantryRobotAttributes::ACCELERATION_TYPE_T
    *                             or 
    *                             GantryRobotAttributes::ACCELERATION_TYPE_S.
    * @param initialSpeed                  Initial speed of the Z axes. Must
    *                                      be  between 1..8000.
    * @param driveSpeed                    The final drive speed of the Z
    *                                      axis. Must be between 1..8000.
    * @param maxSpeed                      Maximum allowable speed of the Z
    *                                      axis. Must be between 1..8000.
    * @param accelerationSpeed             Acceleration of the Z axis. Must
    *                                      be between 125..500000000.
    * @param accelerationRate              Acceleration rate of the Z axis.
    *                                      Must be between 954..2000000000.
    * @exception InvalidParameterException one of the parameters is invalid
    * @exception CannotInitialiseException the gantry robot cannot initialise
    *                                      with the parameters provided.
    * @see setParameters
    * @see setXParameters
    * @see setYParameters
    */
   virtual void setZParameters( 
       GantryRobotAttributes::AccelerationType accelerationType,
       unsigned int                            initialSpeed,
       unsigned int                            driveSpeed,
       unsigned int                            maxSpeed,
       unsigned int                            accelerationSpeed,
       unsigned int                            accelerationRate ) = 0;

   /**
    * Sets the specified output bit to on or off.
    * Sets the specified output bit to on or off. There are 16 output
    * bits, and some of them are used to turn on or off certain functions.
    * This functionality is kept for completeness, but really the
    * specific output function should be called for each.
    *
    * @param     outputBit           The output bit to switch. Range is 0..15.
    * @param     bitState            The state to switch to.
    * @exception InvalidBitException the bit is an invalid number
    *                                (perhaps >15?).
    * @exception CannotSetBitException The output bit cannot be set properly
    * @see       getInputBit
    */
   virtual void setOutputBit( unsigned int outputBit,
			      bool         bitState ) = 0;

   /**
    * Retrieves the value of the provided input bit.
    * Retrieves the value of the provided input bit. There are 16 input
    * bits to read. Some of these are attached to specific input
    * devices. This method is kept for completeness but really the
    * specific methods should be called instead of this method.
    *
    * @param     inputBit            The input it to switch. Range is 0..15.
    * @returns                       The bit state of the input.
    * @exception InvalidBitException the bit is an invalid number 
    *                                (perhaps >15?).
    * @see       getInputBit 
    */
   virtual bool getInputBit( unsigned int inputBit ) const = 0;

   /**
    * Stops the gantry robot dead.
    * Stops the gantry robot dead. A command to stop all the axes is
    * sent. This can be used to perform a software emergency stop.
    *
    * @returns a flag to specify that the command was successful.
    * @see stopXAxis
    * @see stopYAxis
    * @see stopZAxis
    */
   virtual bool stopAllAxis( bool slowDown = false ) = 0;

   /**
    * Stops all movement in the X axis dead.
    *
    * @returns a flag to specify that the command was successful.
    * @see stopAllAxis
    * @see stopYAxis
    * @see stopZAxis
    */
   virtual bool stopXAxis( bool slowDown = false ) = 0;

   /**
    * Stops all movement in the Y axis dead.
    *
    * @returns a flag to specify that the command was successful.
    * @see stopAllAxis
    * @see stopXAxis
    * @see stopZAxis
    */
   virtual bool stopYAxis( bool slowDown = false ) = 0;

   /**
    * Stops all movement in the Z axis dead.
    *
    * @returns a flag to specify that the command was successful.
    * @see stopAllAxis
    * @see stopXAxis
    * @see stopYAxis
    */
   virtual bool stopZAxis( bool slowDown = false ) = 0;

   /**
    * Sets the speed for the X axis.
    *
    * @param speed Ranges from 0..4000000.
    * @returns A flag true if the command was successful, otherwise false.
    */
   virtual bool setXSpeed( unsigned int speed ) = 0;

   /**
    * Sets the speed for the Y axis.
    *
    * @param speed Ranges from 0..4000000.
    * @returns A flag true if the command was successful, otherwise false.
    */
   virtual bool setYSpeed( unsigned int speed ) = 0;

   /**
    * Sets the speed for the Z axis.
    *
    * @param speed Ranges from 0..4000000.
    * @returns A flag true if the command was successful, otherwise false.
    */
   virtual bool setZSpeed( unsigned int speed ) = 0;

   /**
    * Resets the PCI1240 driver card.
    * Resets the PCI1240 driver card. All currently operating functions
    * are halted.
    *
    * @exception CannotResetException
    */
   virtual void reset() = 0;

   /**
    * Returns a flag specifying if the X axis is busy.
    *
    * @returns A flag true if the X axis is moving.
    */
   virtual bool getIsXAxisBusy() const = 0;

   /**
    * Returns a flag specifying if the Y axis is busy.
    *
    * @returns A flag true if the Y axis is moving.
    */
   virtual bool getIsYAxisBusy() const = 0;

   /**
    * Returns a flag specifying if the Z axis is busy.
    *
    * @returns A flag true if the Z axis is moving.
    */
   virtual bool getIsZAxisBusy() const = 0;

   /**
    * Returns a flag specifying if any of the axes are busy.
    *
    * @returns A flag true if any of the axes is moving.
    */
   virtual bool getAreAnyAxisBusy() const = 0;

   /**
    * Returns the state of the emergency stop button.
    * 
    * @returns A flag true if the emergency stop button is pressed.
    */
   virtual bool getEmergencyStopButtonFlag() const = 0;

   /**
    * Waits until the X axis has stopped moving.
    */
   virtual void waitUntilXAxisHasStopped() const = 0;

   /**
    * Waits until the Y axis has stopped moving.
    */
   virtual void waitUntilYAxisHasStopped() const = 0;

   /**
    * Waits until the Z axis has stopped moving.
    */
   virtual void waitUntilZAxisHasStopped() const = 0;

   /**
    * Waits until all the axes have stopped moving.
    */
   virtual void waitUntilAllAxisHaveStopped() const = 0;
};

#endif
