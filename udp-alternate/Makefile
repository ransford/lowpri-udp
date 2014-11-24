CC=gcc
CFLAGS=-O3 -Wall
TARGET=udpalt
SOURCES=$(wildcard *.c)
OBJECTS=$(SOURCES:.c=.o)

$(TARGET): $(OBJECTS)

clean:
	$(RM) $(TARGET) $(OBJECTS)
