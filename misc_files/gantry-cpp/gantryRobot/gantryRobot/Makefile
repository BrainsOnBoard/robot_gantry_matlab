CC     = g++
CFLAGS = $(LAPTOP) $(IS_LINUX)
INC    = -I$(INSTALLROOT)/include
SRC    = Position.cpp RealGantryRobot.cpp SimpleException.cpp \
         GantryRobotAttributes.cpp SimulatedGantryRobot.cpp \
	 GantryRobotFactory.cpp Serialisable.cpp

TARGET = libgantryrobot.a

OBJ = $(SRC:.cpp=.o)
HED = $(SRC:.cpp=.h) GantryRobot.h 

LIB_PATH = $(INSTALLROOT)/lib
INCLUDE_PATH = $(INSTALLROOT)/include

all:	$(TARGET)

.cpp.o:
	$(CC) $(CFLAGS) $(INC) -c $< -o $@

$(TARGET):	$(OBJ)
	ar rcs $(TARGET) $(OBJ)

install:
	@if ( test -e ${INCLUDE_PATH}/gantryRobot );   \
	then                                     \
		REMOVE=nothing;                  \
	else                                     \
		mkdir ${INCLUDE_PATH}/gantryRobot;    \
	fi;
	cp ${HED} ${INCLUDE_PATH}/gantryRobot
	cp ${TARGET} ${LIB_PATH}

clean:
	rm -f $(OBJ) *~ $(TARGET)

depend:
	makedepend -- $(INC) $(CFLAGS) -- $(SRC)
