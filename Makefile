PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

.PHONY: install uninstall

install:
	@install -Dm755 hyprsummon $(DESTDIR)$(BINDIR)/hyprsummon
	@echo "Installed hyprsummon → $(DESTDIR)$(BINDIR)/hyprsummon"

uninstall:
	@rm -f $(DESTDIR)$(BINDIR)/hyprsummon
	@echo "Removed hyprsummon from $(DESTDIR)$(BINDIR)/hyprsummon"
