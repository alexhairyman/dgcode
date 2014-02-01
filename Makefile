
BDIR=build
DIRFLAGS=-od$(BDIR)
DMD=dmd
DFLAGS ?= -version=testmain
$(BDIR)/%.o : %.d
	$(DMD) $(DFLAGS) -c $(DIRFLAGS) $^

parse: $(BDIR)/test.o $(BDIR)/parse.o $(BDIR)/command.o
	$(DMD) $(DFLAGS) -of$@ $+

.PHONY: clean
clean:
	rm -rf $(BDIR) ./parse
