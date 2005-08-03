########################################################################
#
# librets
#

LIBRETS_ANTLR_GRAMMAR_DIR = project/librets/src
LIBRETS_ANTLR_PARSER = $(LIBRETS_ANTLR_GRAMMAR_DIR)/rets-sql.g
LIBRETS_ANTLR_TREE_PARSER = $(LIBRETS_ANTLR_GRAMMAR_DIR)/dmql-tree.g
LIBRETS_ANTLR_GET_OBJECT_TREE_PARSER = \
	$(LIBRETS_ANTLR_GRAMMAR_DIR)/get-object-tree.g

LIBRETS_ANTLR_GRAMMARS = $(LIBRETS_ANTLR_PARSER) $(LIBRETS_ANTLR_TREE_PARSER) \
	$(LIBRETS_ANTLR_GET_OBJECT_TREE_PARSER)
LIBRETS_ANTLR_SRC_DIR = build/librets/antlr
LIBRETS_ANTLR_OBJ_DIR = $(LIBRETS_ANTLR_SRC_DIR)
LIBRETS_ANTLR_TRIGGER = $(LIBRETS_ANTLR_SRC_DIR)/.antlr-up-to-date
LIBRETS_ANTLR_HDR_FILES = $(patsubst %, $(LIBRETS_ANTLR_SRC_DIR)/%, \
			RetsSqlLexer.hpp RetsSqlParser.hpp \
			DmqlTreeParser.hpp GetObjectTreeParser.hpp)
LIBRETS_ANTLR_SRC_FILES = $(patsubst %, $(LIBRETS_ANTLR_SRC_DIR)/%, \
			RetsSqlLexer.cpp RetsSqlParser.cpp \
			DmqlTreeParser.cpp GetObjectTreeParser.cpp)
LIBRETS_ANTLR_OBJECTS := $(LIBRETS_ANTLR_SRC_FILES:.cpp=.o)
LIBRETS_ANTLR_DEPENDS := $(LIBRETS_ANTLR_SRC_FILES:.cpp=.d)

ANTLR_FLAGS = -o $(LIBRETS_ANTLR_SRC_DIR)
ANTLR_TREE_FLAGS = $(ANTLR_FLAGS) -glib $(LIBRETS_ANTLR_PARSER)

$(LIBRETS_ANTLR_TRIGGER): $(LIBRETS_ANTLR_GRAMMARS)
	$(ANTLR) $(ANTLR_FLAGS) $(LIBRETS_ANTLR_PARSER)
	$(ANTLR) $(ANTLR_TREE_FLAGS) $(LIBRETS_ANTLR_TREE_PARSER)
	$(ANTLR) $(ANTLR_TREE_FLAGS) $(LIBRETS_ANTLR_GET_OBJECT_TREE_PARSER)
	touch $(LIBRETS_ANTLR_TRIGGER)

$(LIBRETS_ANTLR_HDR_FILES): $(LIBRETS_ANTLR_TRIGGER)
$(LIBRETS_ANTLR_SRC_FILES): $(LIBRETS_ANTLR_TRIGGER)
$(LIBRETS_ANTLR_OBJECTS): $(LIBRETS_ANTLR_TRIGGER)
$(LIBRETS_ANTLR_DEPENDS): $(LIBRETS_ANTLR_TRIGGER)

$(LIBRETS_ANTLR_OBJECTS): \
	$(LIBRETS_ANTLR_OBJ_DIR)/%.o:  $(LIBRETS_ANTLR_SRC_DIR)/%.cpp
	$(CXX) $(CFLAGS) -I$(LIBRETS_INC_DIR) -c $< -o $@

$(LIBRETS_ANTLR_DEPENDS): \
	$(LIBRETS_ANTLR_OBJ_DIR)/%.d: $(LIBRETS_ANTLR_SRC_DIR)/%.cpp
	@echo Generating dependencies for $<
	@mkdir -p $(dir $@)
	@$(CC) -MM $(CFLAGS) -I$(LIBRETS_INC_DIR) $< \
	| $(FIXDEP) $(LIBRETS_ANTLR_SRC_DIR) $(LIBRETS_ANTLR_OBJ_DIR) > $@

LIBRETS_SRC_DIR = project/librets/src
LIBRETS_INC_DIR = project/librets/include
LIBRETS_OBJ_DIR = build/librets/objects
LIBRETS_SRC_FILES := $(wildcard ${LIBRETS_SRC_DIR}/*.cpp)
LIBRETS_OBJECTS	:= $(LIBRETS_ANTLR_OBJECTS) $(patsubst $(LIBRETS_SRC_DIR)/%.cpp, \
	$(LIBRETS_OBJ_DIR)/%.o, $(LIBRETS_SRC_FILES))
LIBRETS_DEPENDS	:= $(patsubst $(LIBRETS_SRC_DIR)/%.cpp, \
	$(LIBRETS_OBJ_DIR)/%.d, $(LIBRETS_SRC_FILES)) $(LIBRETS_ANTLR_DEPENDS)
LIBRETS_LIB	= build/librets/lib/librets.a
LIBRETS_CFLAGS = $(CFLAGS) -I$(LIBRETS_INC_DIR) -I$(LIBRETS_ANTLR_SRC_DIR)


$(filter $(LIBRETS_OBJ_DIR)/%.o, $(LIBRETS_OBJECTS)): \
	$(LIBRETS_OBJ_DIR)/%.o: $(LIBRETS_SRC_DIR)/%.cpp
	$(CXX) $(LIBRETS_CFLAGS) -c $< -o $@

$(filter $(LIBRETS_OBJ_DIR)/%.d, $(LIBRETS_DEPENDS)): \
	$(LIBRETS_OBJ_DIR)/%.d: $(LIBRETS_SRC_DIR)/%.cpp
	@echo Generating dependencies for $<
	@mkdir -p $(dir $@)
	@$(CC) -MM $(LIBRETS_CFLAGS) $< \
	| $(FIXDEP) $(LIBRETS_SRC_DIR) $(LIBRETS_OBJ_DIR) > $@

$(LIBRETS_LIB): $(LIBRETS_OBJECTS)
	$(AR) -rs $(LIBRETS_LIB) $(LIBRETS_OBJECTS)

########################################################################
#
# librets test
#

LIBRETS_TEST_SRC_DIR	= project/librets/test/src
LIBRETS_TEST_INC_DIR	= 
LIBRETS_TEST_OBJ_DIR	= build/librets/test/objects
LIBRETS_TEST_SRC_FILES	:= $(wildcard $(LIBRETS_TEST_SRC_DIR)/*.cpp)
LIBRETS_TEST_OBJECTS	:= $(patsubst $(LIBRETS_TEST_SRC_DIR)/%.cpp, \
	$(LIBRETS_TEST_OBJ_DIR)/%.o, $(LIBRETS_TEST_SRC_FILES))
LIBRETS_TEST_DEPENDS	:= $(patsubst $(LIBRETS_TEST_SRC_DIR)/%.cpp, \
	$(LIBRETS_TEST_OBJ_DIR)/%.d, $(LIBRETS_TEST_SRC_FILES))
LIBRETS_TEST_EXE	= build/librets/test/bin/test

$(LIBRETS_TEST_OBJ_DIR)/%.o: $(LIBRETS_TEST_SRC_DIR)/%.cpp
	$(CXX) $(CFLAGS) -I$(LIBRETS_INC_DIR) -c $< -o $@

$(LIBRETS_TEST_OBJ_DIR)/%.d: $(LIBRETS_TEST_SRC_DIR)/%.cpp
	@echo Generating dependencies for $<
	@mkdir -p $(dir $@)
	@$(CC) -MM $(CFLAGS) -I$(LIBRETS_INC_DIR) $< \
	| $(FIXDEP) $(LIBRETS_TEST_SRC_DIR) $(LIBRETS_TEST_OBJ_DIR) > $@

$(LIBRETS_TEST_EXE): $(LIBRETS_TEST_OBJECTS) $(LIBRETS_LIB)
	$(CXX) -o $(LIBRETS_TEST_EXE) $(LIBRETS_TEST_OBJECTS) $(LIBRETS_LIB) \
	$(LIBRETS_LDFLAGS) $(CPPUNIT_LDFLAGS)

########################################################################
#
# examples
#

EXAMPLES_SRC_DIR = project/examples/src
EXAMPLES_OBJ_DIR = build/examples/objects
EXAMPLES_LDFLAGS = $(LIBRETS_LDFLAGS) \
	$(BOOST_LIB_PATH)/libboost_program_options.a

OPTIONS_EXAMPLE_SRC = $(EXAMPLES_SRC_DIR)/Options.cpp
LOGIN_EXAMPLE_SRC_FILES := $(EXAMPLES_SRC_DIR)/login.cpp $(OPTIONS_EXAMPLE_SRC)
LOGIN_EXAMPLE_OBJECTS	 := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(LOGIN_EXAMPLE_SRC_FILES))
LOGIN_EXAMPLE_DEPENDS	 := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(LOGIN_EXAMPLE_SRC_FILES))
LOGIN_EXE = build/examples/bin/login

SEARCH_EXAMPLE_SRC_FILES := ${EXAMPLES_SRC_DIR}/search.cpp \
	$(OPTIONS_EXAMPLE_SRC)
SEARCH_EXAMPLE_OBJECTS	 := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(SEARCH_EXAMPLE_SRC_FILES))
SEARCH_EXAMPLE_DEPENDS	 := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(SEARCH_EXAMPLE_SRC_FILES))
SEARCH_EXE = build/examples/bin/search

DEMO_SEARCH_EXAMPLE_SRC_FILES := ${EXAMPLES_SRC_DIR}/demo-search.cpp \
	$(OPTIONS_EXAMPLE_SRC)
DEMO_SEARCH_EXAMPLE_OBJECTS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(DEMO_SEARCH_EXAMPLE_SRC_FILES))
DEMO_SEARCH_EXAMPLE_DEPENDS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(DEMO_SEARCH_EXAMPLE_SRC_FILES))
DEMO_SEARCH_EXE = build/examples/bin/demo-search

METADATA_EXAMPLE_SRC_FILES := $(EXAMPLES_SRC_DIR)/metadata.cpp \
	$(OPTIONS_EXAMPLE_SRC)
METADATA_EXAMPLE_OBJECTS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(METADATA_EXAMPLE_SRC_FILES))
METADATA_EXAMPLE_DEPENDS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(METADATA_EXAMPLE_SRC_FILES))
METADATA_EXE = build/examples/bin/metadata

XML_EXAMPLE_SRC_FILES := ${EXAMPLES_SRC_DIR}/xml.cpp
XML_EXAMPLE_OBJECTS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(XML_EXAMPLE_SRC_FILES))
XML_EXAMPLE_DEPENDS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(XML_EXAMPLE_SRC_FILES))
XML_EXE = build/examples/bin/xml

HTTP_EXAMPLE_SRC_FILES := ${EXAMPLES_SRC_DIR}/http.cpp
HTTP_EXAMPLE_OBJECTS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(HTTP_EXAMPLE_SRC_FILES))
HTTP_EXAMPLE_DEPENDS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(HTTP_EXAMPLE_SRC_FILES))
HTTP_EXE = build/examples/bin/http

RAW_RETS_EXAMPLE_SRC_FILES := ${EXAMPLES_SRC_DIR}/raw-rets.cpp
RAW_RETS_EXAMPLE_OBJECTS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(RAW_RETS_EXAMPLE_SRC_FILES))
RAW_RETS_EXAMPLE_DEPENDS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(RAW_RETS_EXAMPLE_SRC_FILES))
RAW_RETS_EXE = build/examples/bin/raw-rets

SQL2DMQL_EXAMPLE_SRC_FILES := ${EXAMPLES_SRC_DIR}/sql2dmql.cpp
SQL2DMQL_EXAMPLE_OBJECTS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(SQL2DMQL_EXAMPLE_SRC_FILES))
SQL2DMQL_EXAMPLE_DEPENDS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(SQL2DMQL_EXAMPLE_SRC_FILES))
SQL2DMQL_EXE = build/examples/bin/sql2dmql

GET_OBJECT_EXAMPLE_SRC_FILES := ${EXAMPLES_SRC_DIR}/get-object.cpp
GET_OBJECT_EXAMPLE_OBJECTS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(GET_OBJECT_EXAMPLE_SRC_FILES))
GET_OBJECT_EXAMPLE_DEPENDS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(GET_OBJECT_EXAMPLE_SRC_FILES))
GET_OBJECT_EXE = build/examples/bin/get-object

EXAMPLES_DEPENDS = $(LOGIN_EXAMPLE_DEPENDS) $(SEARCH_EXAMPLE_DEPENDS) \
	$(METADATA_EXAMPLE_DEPENDS) $(XML_EXAMPLE_DEPENDS) \
	$(HTML_EXAMPLE_DEPENDS) $(SQL2DMQL_EXAMPLE_DEPENDS) \
	$(HTTP_EXAMPLE_DEPENDS) $(GET_OBJECT_EXAMPLE_DEPENDS)

EXAMPLES_EXE = $(LOGIN_EXE) $(SEARCH_EXE) $(METADATA_EXE) $(XML_EXE) \
	$(HTTP_EXE) $(RAW_RETS_EXE) $(SQL2DMQL_EXE) $(GET_OBJECT_EXE) \
	$(DEMO_SEARCH_EXE)

$(EXAMPLES_OBJ_DIR)/%.o: $(EXAMPLES_SRC_DIR)/%.cpp
	$(CXX) $(CFLAGS) -I$(LIBRETS_INC_DIR) -c $< -o $@

$(EXAMPLES_OBJ_DIR)/%.d: $(EXAMPLES_SRC_DIR)/%.cpp
	@echo Generating dependencies for $<
	@mkdir -p $(dir $@)
	@$(CC) -MM $(CFLAGS) -I$(LIBRETS_INC_DIR) $< \
	| $(FIXDEP) $(EXAMPLES_SRC_DIR) $(EXAMPLES_OBJ_DIR) > $@


$(LOGIN_EXE): $(LOGIN_EXAMPLE_OBJECTS) $(LIBRETS_LIB)
	$(CXX) -o $(LOGIN_EXE) $(LOGIN_EXAMPLE_OBJECTS) $(LIBRETS_LIB) \
	$(EXAMPLES_LDFLAGS)

$(SEARCH_EXE): $(SEARCH_EXAMPLE_OBJECTS) $(LIBRETS_LIB)
	$(CXX) -o $(SEARCH_EXE) $(SEARCH_EXAMPLE_OBJECTS) $(LIBRETS_LIB) \
	$(EXAMPLES_LDFLAGS)

$(DEMO_SEARCH_EXE): $(DEMO_SEARCH_EXAMPLE_OBJECTS) $(LIBRETS_LIB)
	$(CXX) -o $(DEMO_SEARCH_EXE) $(DEMO_SEARCH_EXAMPLE_OBJECTS) \
	$(LIBRETS_LIB) $(EXAMPLES_LDFLAGS)

$(METADATA_EXE): $(METADATA_EXAMPLE_OBJECTS) $(LIBRETS_LIB)
	$(CXX) -o $(METADATA_EXE) $(METADATA_EXAMPLE_OBJECTS) $(LIBRETS_LIB) \
	$(EXAMPLES_LDFLAGS)

$(XML_EXE): $(XML_EXAMPLE_OBJECTS) $(LIBRETS_LIB)
	$(CXX) -o $(XML_EXE) $(XML_EXAMPLE_OBJECTS) $(LIBRETS_LIB) \
	$(LIBRETS_LDFLAGS)

$(HTTP_EXE): $(HTTP_EXAMPLE_OBJECTS) $(LIBRETS_LIB)
	$(CXX) -o $(HTTP_EXE) $(HTTP_EXAMPLE_OBJECTS) $(LIBRETS_LIB) \
	$(LIBRETS_LDFLAGS)

$(RAW_RETS_EXE): $(RAW_RETS_EXAMPLE_OBJECTS) $(LIBRETS_LIB)
	$(CXX) -o $(RAW_RETS_EXE) $(RAW_RETS_EXAMPLE_OBJECTS) $(LIBRETS_LIB) \
	$(LIBRETS_LDFLAGS)

$(SQL2DMQL_EXE): $(SQL2DMQL_EXAMPLE_OBJECTS) $(LIBRETS_LIB)
	$(CXX) -o $(SQL2DMQL_EXE) $(SQL2DMQL_EXAMPLE_OBJECTS) $(LIBRETS_LIB) \
	$(LIBRETS_LDFLAGS)

$(GET_OBJECT_EXE): $(GET_OBJECT_EXAMPLE_OBJECTS) $(LIBRETS_LIB)
	$(CXX) -o $(GET_OBJECT_EXE) $(GET_OBJECT_EXAMPLE_OBJECTS) \
	$(LIBRETS_LIB) $(LIBRETS_LDFLAGS)



########################################################################
#
# misc
#

DISTCLEAN_FILES = \
	config.status config.log config.cache \
	project/librets/src/config.h \
	project/build/Doxyfile
