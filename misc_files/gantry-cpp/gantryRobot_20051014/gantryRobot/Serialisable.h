#ifndef SERIALISABLE_H
#define SERIALISABLE_H

#include "SimpleException.h"

/**
 * This is a simple class that forces derived classes to include two
 * methods useful for serialisation. It also contains a few utility
 * methods to do things like read and write a number, etc.
 */
class Serialisable {
public:
  /**
   * Thrown if the expected token isn't found.
   */
  SIMPLE_EXCEPTION_CLASS( TokenNotFoundException )

  /**
   * Thrown if the provided string cannot be parsed into an integer.
   */
  SIMPLE_EXCEPTION_CLASS( CannotParseIntegerException )

  /**
   * Thrown if the provided string cannot be parsed into a double.
   */
  SIMPLE_EXCEPTION_CLASS( CannotParseDoubleException )

  /**
   * Reads the object in from the given string. The string is
   * always stored and written in a human readable format
   * with tags. This method acts as a token analyser.
   *
   * @param     str                          A pointer to the beginning of
   *                                         the string to be read.
   * @returns                                A pointer to the area immediately
   *                                         after the stored class.
   */
  virtual const char *readObject( const char *str ) = 0;

  /**
   * Writes the object to the end of the given string. The string is 
   * always stored and written in a human readable format 
   * with tags. This method acts as a token analyser.
   *
   * @param     buffer The string to write the object data to.
   */
  virtual void writeObject( string& buffer ) = 0;

  /**
   * Parses the given token, ignoring whitespace. It throws an error if
   * the token isn't found for some reason.
   *
   * @param    str                     A pointer to the string to be parsed.
   *                                   It can be padded with whitespace.
   * @param    token                   The expected token.
   * @returns                          A pointer to the area after the
   *                                   parsed string, so that other elements
   *                                   can be parsed.
   * @exception TokenNotFoundException thrown if the provided token is not
   *                                   the next thing to be parsed.
   */
  static const char *skipToken( const char *str, const char *token );
  
  /**
   * Makes sure the next element is an unsigned integer, and parses it.
   * 
   * @param str                             A pointer to the string to be
   *                                        parsed. It can be padded with
   *                                        whitespace.
   * @param     intBuf                      A pointer to an area where the
   *                                        newly parsed integer can be placed.
   * @exception CannotParseIntegerException A unsigned integer cannot be
   *                                        parsed for some reason.
   * @returns   A pointer to the area immediately after the parsed data.
   */
  static const char *parseUnsignedInteger( const char   *str, 
				                                   unsigned int *intBuf );

  /**
   * Makes sure the next element is an integer, and parses it.
   * 
   * @param str                             A pointer to the string to be
   *                                        parsed. It can be padded with
   *                                        whitespace.
   * @param     intBuf                      A pointer to an area where the
   *                                        newly parsed integer can be placed.
   * @exception CannotParseIntegerException An integer cannot be parsed for
   *                                        some reason.
   * @returns   A pointer to the area immediately after the parsed data.
   */
  static const char *parseInteger( const char   *str,
                                   int          *intBuf );

  /**
   * Makes sure the next element is a double, and parses it.
   * 
   * @param str                            A pointer to the string to be
   *                                       parsed. It can be padded with
   *                                       whitespace.
   * @param     doubleBuf                  A pointer to an area where the
   *                                       newly parsed double can be placed.
   * @exception CannotParseDoubleException A double cannot be parsed for
   *                                       some reason.
   * @returns   A pointer to the area immediately after the parsed data.
   */
  static const char *parseDouble( const char *str, 
			                            double     *doubleBuf );

  /**
   * Makes sure the next element is a double, and parses it.
   * 
   * @param str                            A pointer to the string to be
   *                                       parsed. It can be padded with
   *                                       whitespace.
   * @param     doubleBuf                  A pointer to an area where the
   *                                       newly parsed double can be placed.
   * @exception CannotParseDoubleException A double cannot be parsed for
   *                                       some reason.
   */
  static void parseDouble( FILE   *input,
			                     string& token );

  /**
   * A simple method to skip the whitespace in a string, if it exists.
   *
   * @param   str A pointer to the string to parsed.
   * @returns A pointer to the next non-whitespace.
   */
  static const char *skipWhitespace( const char *str );

  /**
   * A simple method to add a double. It checks to see if the trailing
   * zeros or floating point can be removed.
   */
  static void addDouble( string& buffer, double number );
};

#endif
