#ifndef GANTRYROBOTATTRIBUTES_H
#define GANTRYROBOTATTRIBUTES_H

/**
 * Contains various constants and enumerated values to do with the gantry 
 * robot.
 * Contains various constants and enumerated values to do with the gantry 
 * robot. Stashed here to make them freely available to all the other
 * classes.
 */
class GantryRobotAttributes {
public:
  /**
   * The maximum position X axis position and is used by all the 
   * support classes such as Position.
   */
  static const unsigned int MAX_X;

  /**
   * The maximum position Y axis position and is used by all the 
   * support classes such as Position.
   */
  static const unsigned int MAX_Y;


  /**
   * The maximum position Z axis position and is used by all the 
   * support classes such as Position.
   */
  static const unsigned int MAX_Z;

  /**
   * Values to specify the desired acceleration type for all the axes.
   */
  enum AccelerationType { ACCELERATION_TYPE_T, ACCELERATION_TYPE_S };

  /**
   * Values used by the factory class to specify what kind of GantryRobot
   * to create.
   */
  enum GantryRobotType { SIMULATED_GANTRY_ROBOT, REAL_GANTRY_ROBOT };
};

#endif
