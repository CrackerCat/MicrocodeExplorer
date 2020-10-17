# use this makefile to build MicrocodeExplorer for macOS
# based off HexRaysCodeXplorer makefile for Linux
#
# Instructions:
# After setting up IDA SDK and Hex Rays SDK to work, in the MicrocodeExplorer folder do:
# for ida64.app
# 	EA64=1 make [install]
# for ida.app
# 	EA64=0 make [install]
#

# CHANGE ME :-)
# where IDA_DIR must be the full path to ida.app (not ida64.app)
# IDA 7.5 example: /Applications/IDA Pro 7.5/ida.app/
IDA_DIR="/Applications/IDA Pro 7.5/ida.app/"
# path to IDA SDK folder
IDA_SDK="/Applications/IDA Pro 7.5/idasdk75"

CC=g++
LD=ld
LDFLAGS=-shared -m64

LIBDIR=-L$(IDA_DIR)/Contents/MacOS
SRCDIR=./
HEXRAYS_SDK=$(IDA_DIR)/plugins/hexrays_sdk
INCLUDES=-I$(IDA_SDK)/include -I$(HEXRAYS_SDK)/include
__X64__=1

SRC=$(SRCDIR)main.cpp \
	$(SRCDIR)HexRaysUtil.cpp \
	$(SRCDIR)MicrocodeExplorer.cpp
	
OBJS=$(subst .cpp,.o,$(SRC))

CFLAGS=-m64 -fPIC -D__MAC__ -D__PLUGIN__ -std=c++14 -D__X64__ -D_GLIBCXX_USE_CXX11_ABI=0 -Wno-logical-op-parentheses -Wno-nullability-completeness
LIBS=-lc -lpthread -ldl
EXT=dylib

ifeq ($(EA64),1)
	CFLAGS+=-D__EA64__
	LIBS+=-lida64
	SUFFIX=64
else
	LIBS+=-lida
	SUFFIX=
endif

all: check-env clean MicrocodeExplorer$(SUFFIX).$(EXT)

MicrocodeExplorer$(SUFFIX).$(EXT): $(OBJS) 
	$(CC) $(LDFLAGS) $(LIBDIR) -o MicrocodeExplorer$(SUFFIX).$(EXT) $(OBJS) $(LIBS)

%.o: %.cpp
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(OBJS) MicrocodeExplorer$(SUFFIX).$(EXT)

install: MicrocodeExplorer$(SUFFIX).$(EXT)
	cp -f MicrocodeExplorer$(SUFFIX).$(EXT) $(IDA_DIR)/Contents/MacOS/plugins

check-env:
ifndef IDA_SDK
	$(error IDA_SDK is undefined)
endif
ifndef IDA_DIR
	$(error IDA_DIR is undefined)
endif
ifndef EA64
	$(error specify EA64=0 for 32 bit build or EA64=1 for 64 bit build)
endif
.PHONY: check-env
