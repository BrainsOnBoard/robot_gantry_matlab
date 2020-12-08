#ifndef GANTRYROBOTFACTORY_H
#define GANTRYROBOTFACTORY_H

#include "GantryRobot.h"
#include "GantryRobotAttributes.h"

/**
 * This factory class can create concrete instances of GantryRobot.
 * There are presently two main classes that implement the
 * interface GantryRobot. These are RealGantryRobot and 
 * SimulatedGantryRobot. Which one is created by this factory is
 * selected by a constructor parameter. Once it's created, it
 * should be invisible to the programmer which one they are using.
 */
class GantryRobotFactory {
public:
  /**
   * Thrown in case of an invalid gantry robot type requested in the
   * constructor.
   */
  SIMPLE_EXCEPTION_CLASS( InvalidGantryRobotTypeException )

  /**
   * Thrown if some terrible error has occurred and a GantryRobot
   * instance cannot be created.
   */
  SIMPLE_EXCEPTION_CLASS( CannotCreateGantryRobotException )

  /**
   * Simple constructor with a parameter stating which GantryRobot to
   * create.
   * Simple constructor with a parameter stating which GantryRobot to
   * create. The parameter passed must either be 
   * GantryRobotAttributes::SIMULATED_GANTRY_ROBOT
   * or GantryRobotAttributes::REAL_GANTRY_ROBOT.
   *
   * @param     gantryRobotType                 States whether to construct a 
   *                                            real or simulated
   *                                            GantryRobotInstance.
   * @exception InvalidGantryRobotTypeException thrown if the passed parameter
   *                                            is invalid.
   */
  GantryRobotFactory( GantryRobotAttributes::GantryRobotType gantryRobotType );

  virtual ~GantryRobotFactory() { }

  /**
   * Creates a GantryRobotInstance.
   * Creates a GantryRobotInstance. Either it'll be an instance of
   * RealGantryRobot or SimulatedGantryRobot, depending upon the
   * parameter passed to it in the GantryRobotFactoryConstructor.
   * Note that an exception can be thrown if the card cannot be
   * initialised for some reason if you are creating a 
   * RealGantryRobotInstance.
   *
   * @returns A GantryRobot instance.
   * @see       GantryRobot
   * @exception CannotCreateGantryRobotException some uncertain error has
   *                                             occurred.
   */
  GantryRobot *createGantryRobot();

protected:
  /**
   * Stored the type of GantryRobot instance that this class must
   * construct.
   */
  GantryRobotAttributes::GantryRobotType m_GantryRobotType;
};

#endif
