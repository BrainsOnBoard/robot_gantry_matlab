#include "SimpleException.h"
#include <stdio.h>

SimpleException::SimpleException( const char *msg ) : 
  m_Name( "SimpleException" ),
  m_Msg(  msg               ) { }

const string& SimpleException::getName() const {
  return m_Name;
}

const string& SimpleException::getMessage() const {
  return m_Msg;
}

const string& SimpleException::toString() const {
  if ( ( m_Msg.size() || !( getName().empty() ) ) &&
       m_StringVersion.size() == 0 ) {
    m_StringVersion  = getName();
    m_StringVersion += ":\t";
    m_StringVersion += m_Msg;
  }
  
  return m_StringVersion;
}

const string& SimpleException::getStackTrace() const {
  return m_StackTrace;
}

void SimpleException::__fillInExceptionABC1234( long        lineNo, 
						const char *fileName ) {
  addToStackTrace( lineNo, fileName, m_Msg.c_str() );
}

void SimpleException::addToStackTrace( long        lineNo, 
				       const char *fileName, 
				       const char *msg ) {
  string tempVariable = m_StackTrace;
  m_StackTrace  = getName();
  m_StackTrace += ":\t";

  const char *f = &( fileName[ strlen( fileName ) ] );
  while ( f > fileName && *f != '\\' && *f != '/' ) {
    f--;
  }
  
  m_StackTrace += f;
  m_StackTrace += ":\t";

  char number[ 100 ];
  sprintf( number, "%ld", lineNo );
  m_StackTrace += number;
  m_StackTrace += ":\t";
  m_StackTrace += msg;
  
  if ( tempVariable.size() ) {
    m_StackTrace += "\n";
    m_StackTrace += tempVariable;
  }
}
