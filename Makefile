
BDIR=build
DIRFLAGS=-od$(BDIR)
DMD=dmd
SDIR = source
BFLAGS = -I$(SDIR)
DFLAGS ?= $(BFLAGS) -version=testmaina
OFLAGS ?= $(BFLAGS)

$(BDIR)/%.o : $(SDIR)/%.d
	$(DMD) $(OFLAGS) -c $(DIRFLAGS) $^

parse: $(BDIR)/test.o $(BDIR)/parse.o $(BDIR)/command.o
	$(DMD) $(DFLAGS) -of$@ $+

.PHONY: clean
clean:
	rm -rf $(BDIR) ./parse
