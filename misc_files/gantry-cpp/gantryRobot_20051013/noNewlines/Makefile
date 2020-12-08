S      = .
CC     = g++
CFLAGS = -g
INC    = -I/usr/local/include
LIBDIR = -L/usr/local/lib
SRC    = main.cpp
LIB    = 

TARGET = noNewlines

OBJ = $(SRC:.cpp=.o)

all:	$(TARGET)

.cpp.o:
	$(CC) $(CFLAGS) $(INC) -c $< -o $@

$(TARGET):	$(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o $(TARGET) $(LIBDIR) $(LIB) $(LIB) $(LIB)  

clean:
	rm -f $(OBJ) *~ $(TARGET)
