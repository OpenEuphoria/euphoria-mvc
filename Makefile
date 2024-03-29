
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

HTMLTOOLS_TARGET = bin/htmlparse$(EXE_EXT)
HTMLTOOLS_EUCFLAGS = -batch -extra-lflags="-no-pie" -keep -makefile -silent -build-dir="$(patsubst tools/html%.ex,build/html%.d,$^)"
HTMLTOOLS_OUTPUT = $(patsubst tools/html%.ex,bin/html%$(EXE_EXT),$^)
HTMLTOOLS_BUILDDIR = $(patsubst bin/html%$(EXE_EXT),build/html%.d,$@)
HTMLTOOLS_MAKEFILE = $(patsubst bin/html%$(EXE_EXT),html%.mak,$@)

JSONTOOLS_TARGET = bin/jsonconv$(EXE_EXT) bin/jsonfetch$(EXE_EXT) bin/jsontidy$(EXE_EXT)
JSONTOOLS_EUCFLAGS = -batch -extra-lflags="-no-pie" -keep -makefile -silent -build-dir="$(patsubst tools/json%.ex,build/json%.d,$^)"
JSONTOOLS_OUTPUT = $(patsubst tools/json%.ex,bin/json%$(EXE_EXT),$^)
JSONTOOLS_BUILDDIR = $(patsubst bin/json%$(EXE_EXT),build/json%.d,$@)
JSONTOOLS_MAKEFILE = $(patsubst bin/json%$(EXE_EXT),json%.mak,$@)

SQLITE3_TARGET = bin/$(DLL_PRE)sqlite3$(DLL_EXT)
SQLITE3_CFLAGS =  -O2 -s -fPIC -Isrc -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_DBSTAT_VTAB \
	-DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_RBU
SQLITE3_LDFLAGS = -shared

all: sqlite3

tools: htmltools jsontools

htmltools: $(HTMLTOOLS_TARGET)

jsontools: $(JSONTOOLS_TARGET)

sqlite3: $(SQLITE3_TARGET)

build/htmlparse.d/htmlparse.mak: tools/htmlparse.ex | build/htmlparse.d
build/jsonconv.d/jsonconv.mak: tools/jsonconv.ex  | build/jsonconv.d
build/jsonfetch.d/jsonfetch.mak: tools/jsonfetch.ex | build/jsonfetch.d
build/jsontidy.d/jsontidy.mak: tools/jsontidy.ex  | build/jsontidy.d

build/htmlparse.d/htmlparse.mak:
	$(EUC) $(HTMLTOOLS_EUCFLAGS) -o $(HTMLTOOLS_OUTPUT) $^

build/jsonconv.d/jsonconv.mak build/jsonfetch.d/jsonfetch.mak build/jsontidy.d/jsontidy.mak:
	$(EUC) $(JSONTOOLS_EUCFLAGS) -o $(JSONTOOLS_OUTPUT) $^

bin/htmlparse$(EXE_EXT): build/htmlparse.d/htmlparse.mak | bin build
bin/jsonconv$(EXE_EXT): build/jsonconv.d/jsonconv.mak | bin build
bin/jsonfetch$(EXE_EXT): build/jsonfetch.d/jsonfetch.mak | bin build
bin/jsontidy$(EXE_EXT): build/jsontidy.d/jsontidy.mak | bin build

$(HTMLTOOLS_TARGET):
	$(MAKE) -C $(HTMLTOOLS_BUILDDIR) -f $(HTMLTOOLS_MAKEFILE)

$(JSONTOOLS_TARGET):
	$(MAKE) -C $(JSONTOOLS_BUILDDIR) -f $(JSONTOOLS_MAKEFILE)

build/sqlite3.d/sqlite3.o: src/sqlite3.c | build/sqlite3.d
	$(CC) $(SQLITE3_CFLAGS) -o $@ -c $^

$(SQLITE3_TARGET): build/sqlite3.d/sqlite3.o | src/sqlite3.h src/sqlite3ext.h
	$(LD) $(SQLITE3_LDFLAGS) -o $@ $^

bin build build/htmlparse.d build/jsonconv.d build/jsonfetch.d build/jsontidy.d build/sqlite3.d:
ifeq ($(OS),Windows_NT)
	@mkdir $(subst /,\,$@)
else
	@mkdir -p $@
endif

clean:
ifneq ($(OS),Windows_NT)
	@rm -f $(HTMLTOOLS_TARGET) $(JSONTOOLS_TARGET) $(SQLITE3_TARGET)
	@rm -f build/htmlparse.d/*.[cho] build/htmlparse.d/htmlparse.mak
	@rm -f build/jsonconv.d/*.[cho] build/jsonconv.d/jsonconv.mak
	@rm -f build/jsonfetch.d/*.[cho] build/jsonfetch.d/jsonfetch.mak
	@rm -f build/jsontidy.d/*.[cho] build/jsontidy.d/jsontidy.mak
	@rm -f build/sqlite3.d/sqlite3.o
	@rmdir build/htmlparse.d
	@rmdir build/jsonconf.d
	@rmdir build/jsonfetch.d
	@rmdir build/jsontidy.d
	@rmdir build/sqlite3.d
	@rmdir build
endif

.PHONY: all clean htmltools jsontools sqlite3
