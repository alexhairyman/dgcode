
BDIR=build
DIRFLAGS=-od$(BDIR)
DMD=dmd
$(BDIR)/%.o : %.d
	$(DMD) -c $(DIRFLAGS) $^
parse: $(BDIR)/test.o $(BDIR)/parse.o $(BDIR)/command.o
	$(DMD) -of$@ $+
