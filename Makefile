PREFIX ?= /usr
LIBDIR = $(PREFIX)/lib
BINDIR = $(PREFIX)/bin

.PHONY: all install uninstall

all:
	@echo "Nothing to build. Run 'make install' to install."

install:
	install -d $(DESTDIR)$(LIBDIR)/releng-tools
	install -d $(DESTDIR)$(BINDIR)

	install -m 755 build_changelog.py $(DESTDIR)$(LIBDIR)/releng-tools/
	install -m 755 build_package.sh $(DESTDIR)$(LIBDIR)/releng-tools/

	ln -sf ../lib/releng-tools/build_changelog.py $(DESTDIR)$(BINDIR)/releng-build-changelog
	ln -sf ../lib/releng-tools/build_package.sh $(DESTDIR)$(BINDIR)/releng-build-package

uninstall:
	rm -rf $(DESTDIR)$(LIBDIR)/releng-tools
	rm -f $(DESTDIR)$(BINDIR)/releng-build-changelog
	rm -f $(DESTDIR)$(BINDIR)/releng-build-package
