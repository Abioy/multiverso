PROJECT := $(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)

CXX = g++
CXXFLAGS = -O3 \
           -std=c++11 \
           -Wall \
           -Wno-sign-compare \
           -fno-omit-frame-pointer

HEADERS_DIR = $(PROJECT)/include/multiverso
MULTIVERSO_SRC = $(PROJECT)/src/multiverso
MULTIVERSO_SERVER_SRC = $(PROJECT)/src/multiverso_server

THIRD_PARTY = $(PROJECT)/third_party
THIRD_PARTY_INC = $(THIRD_PARTY)/include
THIRD_PARTY_LIB = $(THIRD_PARTY)/lib

INC_FLAGS = -I$(HEADERS_DIR)
INC_FLAGS += -I$(THIRD_PARTY_INC)
LD_FLAGS = -L$(THIRD_PARTY_LIB) -lzmq -lmpi -lmpl

LIB_SRC_DIR = $(PROJECT)/src/multiverso
SERVER_SRC_DIR = $(PROJECT)/src/multiverso_server
HEADERS = $(shell find $(HEADERS_DIR) -type f -name "*.h")
LIB_SRC = $(shell find $(MULTIVERSO_SRC) -type f -name "*.cpp")
SERVER_HEADERS = $(shell find $(MULTIVERSO_SERVER_SRC) -type f -name "*.h")
SERVER_SRC = $(shell find $(MULTIVERSO_SERVER_SRC) -type f -name "*.cpp")

LIB_OBJ = $(LIB_SRC:.cpp=.o)
SERVER_OBJ = $(SERVER_SRC:.cpp=.o)

BIN = $(PROJECT)/bin
LIB = $(PROJECT)/lib

MULTIVERSO_LIB = $(LIB)/libmultiverso.a
MULTIVERSO_SERVER = $(BIN)/multiverso_server

MKDIR = $(BIN) \
    	$(LIB)

all: path \
	 multiverso \
	 multiverso_server
		
path: $(MKDIR)

$(MKDIR):
	mkdir -p $@

$(MULTIVERSO_LIB): $(LIB_OBJ) 
	ar csrv $@ $(LIB_OBJ)

$(MULTIVERSO_SERVER): $(SERVER_OBJ) $(MULTIVERSO_LIB)
	$(CXX) $(SERVER_OBJ) $(MULTIVERSO_LIB) $(CXXFLAGS) $(INC_FLAGS) $(LD_FLAGS) -o $@

$(LIB_OBJ): %.o: %.cpp $(HEADERS)
	$(CXX) $(CXXFLAGS) $(INC_FLAGS) -c $< -o $@

$(SERVER_OBJ): %.o: %.cpp $(HEADERS) $(SERVER_HEADERS)
	$(CXX) $(CXXFLAGS) $(INC_FLAGS) $(LD_FLAGS) -c $< -o $@

multiverso: path $(MULTIVERSO_LIB)

multiverso_server: path $(MULTIVERSO_SERVER)

clean:
	rm -rf $(BIN) $(LIB) $(LIB_OBJ) $(SERVER_OBJ)
