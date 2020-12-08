S      = .
CC     = g++
CFLAGS = $(IS_LINUX)
INC    = -I/usr/local/include
LIBDIR = -L/usr/local/lib
SRC    = consoleTest.cpp
LIB    = -lgantryrobot

TARGET = consoleTest

OBJ = $(SRC:.cpp=.o)

all:	$(TARGET)

.cpp.o:
	$(CC) $(CFLAGS) $(INC) -c $< -o $@

$(TARGET):	$(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o $(TARGET) $(LIBDIR) $(LIB) $(LIB) $(LIB)  

clean:
	rm -f $(OBJ) *~ $(TARGET)
