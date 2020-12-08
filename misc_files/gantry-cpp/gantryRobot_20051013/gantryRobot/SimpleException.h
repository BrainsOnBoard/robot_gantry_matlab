#ifndef SIMPLEEXCEPTION_H
#define SIMPLEEXCEPTION_H

#include <string>

using namespace std;

#define fillInStackTrace() __fillInExceptionABC1234(__LINE__,__FILE__)

/**
 * A simple exception class written for the Gantry Robot software.
 * It is adapted from QException (pre-GPL version) and is based upon
 * the java.lang.Exception class.
 */
class SimpleException {
public:
  /**
   * The constructor always uses an message string to initialise with.
   */
  SimpleException( const char *msg );
  virtual ~SimpleException() { }

  /**
   * Gets the message string the exception was initialised with.
   *
   * @returns The message string the exception was initialised with.
   */
  const string& getMessage()    const;

  /**
   * Converts the exception to a nice string.
   *
   * @returns Text string form the exception suitable for human reading.
   */
  const string& toString()      const;

  /**
   * Provides a stack trace of the exception. Includes every source file
   * and line number that was called with SimpleException::fillInStackTrace().
   *
   * @returns The stack trace of the exception.
   */
  const string& getStackTrace() const;

  /**
   * Fills in a stack trace line. This method should never be called
   * directly, instead use fillInStackTrace().
   */
  void        __fillInExceptionABC1234( long lineNo,
					const char *fileName );

protected:
  /**
   * Return the name of the exception. Automatically set by using
   * the macro SIMPLE_EXCEPTION_CLASS.
   *
   * @returns The name of the exception.
   */
  virtual const string& getName() const;

  /**
   * Used by fillInStackTrace() to add the to stack trace.
   */
  void                addToStackTrace( long        lineNo,
				       const char *filename,
				       const char *msg );

protected:
  string m_Msg;
  string m_Name;
  string m_StackTrace;

  mutable string m_StringVersion;
};

#define SIMPLE_EXCEPTION_CLASS( A )                                \
  class A : public SimpleException {                               \
  public:                                                          \
    A( const char *msg ) : SimpleException( msg ) { m_Name = #A; } \
  };

#endif

