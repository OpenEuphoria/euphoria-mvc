
ifeq ($(OS),Windows_NT)
    DLL_EXT = .dll
    EXE_EXT = .exe
else
    DLL_PRE = lib
    DLL_EXT = .so
    EXE_EXT =
endif

CC = gcc
LD = gcc
EUC = euc

MAKEFLAGS += --no-print-directory --output-sync=target

JSONTOOLS_TARGET = build/jsonconv$(EXE_EXT) build/jsonfetch$(EXE_EXT) build/jsontidy$(EXE_EXT)
JSONTOOLS_EUCFLAGS = -batch -keep -makefile -silent -build-dir="$(patsubst tools/json%.ex,build/json%.d,$^)"
JSONTOOLS_OUTPUT = $(patsubst tools/json%.ex,build/json%$(EXE_EXT),$^)
JSONTOOLS_BUILDDIR = $(patsubst build/json%$(EXE_EXT),build/json%.d,$@)
JSONTOOLS_MAKEFILE = $(patsubst build/json%$(EXE_EXT),json%.mak,$@)

SQLITE3_TARGET = build/$(DLL_PRE)sqlite3$(DLL_EXT)
SQLITE3_CFLAGS =  -O2 -Isrc \
	-DSQLITE_ENABLE_FTS3 \
	-DSQLITE_ENABLE_FTS5 \
	-DSQLITE_ENABLE_RTREE \
	-DSQLITE_ENABLE_DBSTAT_VTAB \
	-DSQLITE_ENABLE_JSON1 \
	-DSQLITE_ENABLE_RBU
SQLITE3_LDFLAGS = -shared

all : jsontools sqlite3

jsontools : $(JSONTOOLS_TARGET)

build/jsonconv.d/jsonconv.mak   : tools/jsonconv.ex  | build/jsonconv.d
build/jsonfetch.d/jsonfetch.mak : tools/jsonfetch.ex | build/jsonfetch.d
build/jsontidy.d/jsontidy.mak   : tools/jsontidy.ex  | build/jsontidy.d

build/jsonconv.d/jsonconv.mak build/jsonfetch.d/jsonfetch.mak build/jsontidy.d/jsontidy.mak:
	$(EUC) $(JSONTOOLS_EUCFLAGS) -o $(JSONTOOLS_OUTPUT) $^

build/jsonconv$(EXE_EXT)  : build/jsonconv.d/jsonconv.mak | build
build/jsonfetch$(EXE_EXT) : build/jsonfetch.d/jsonfetch.mak | build
build/jsontidy$(EXE_EXT)  : build/jsontidy.d/jsontidy.mak | build

$(JSONTOOLS_TARGET):
	$(MAKE) -C $(JSONTOOLS_BUILDDIR) -f $(JSONTOOLS_MAKEFILE)

sqlite3 : $(SQLITE3_TARGET)

build/sqlite3.d/sqlite3.o : src/sqlite3.c | build/sqlite3.d
	$(CC) $(SQLITE3_CFLAGS) -o $@ -c $^

$(SQLITE3_TARGET) : build/sqlite3.d/sqlite3.o | src/sqlite3.h src/sqlite3ext.h
	$(LD) $(SQLITE3_LDFLAGS) -o $@ $^

build build/jsonconv.d build/jsonfetch.d build/jsontidy.d build/sqlite3.d :
ifeq ($(OS),Windows_NT)
	@mkdir $(subst /,\,$@)
else
	@mkdir -p $@
endif

.PHONY : all jsontools sqlite3
