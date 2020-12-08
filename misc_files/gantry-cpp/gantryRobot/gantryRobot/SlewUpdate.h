#ifndef SLEWUPDATE_H
#define SLEWUPDATE_H

/**
 * This is a simple interface that the user can implement so that their method is
 * called every time a movement has occurred during a slew session. The user should
 * return from this method before the time interval between slew points has elapsed.
 */

class SlewUpdate {
public:
  /**
   * A method that the user can overload so that their own method is called. The user
   * return true if they wish the slew to continue.
   */
  virtual bool performSlewUpdate() = 0;
};

#endif
