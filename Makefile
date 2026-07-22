PREFIX ?= /usr
LIBDIR = $(PREFIX)/lib
BINDIR = $(PREFIX)/bin
FLATPAK_DIR = $(LIBDIR)/releng-tools/flatpak

.PHONY: all install uninstall

all:
	@echo "Nothing to build. Run 'make install' to install."

install:
	install -d $(DESTDIR)$(LIBDIR)/releng-tools
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(FLATPAK_DIR)/io
	install -d $(DESTDIR)$(FLATPAK_DIR)/scripts
	install -d $(DESTDIR)$(FLATPAK_DIR)/test

	install -m 755 build_changelog.py $(DESTDIR)$(LIBDIR)/releng-tools/
	install -m 755 build_package.sh $(DESTDIR)$(LIBDIR)/releng-tools/

	install -m 755 flatpak/common.sh $(DESTDIR)$(FLATPAK_DIR)/
	install -m 755 flatpak/build_flatpak.sh $(DESTDIR)$(FLATPAK_DIR)/
	install -m 755 flatpak/deploy_flatpak.sh $(DESTDIR)$(FLATPAK_DIR)/
	install -m 755 flatpak/io/invoke_flatpak_builder.sh $(DESTDIR)$(FLATPAK_DIR)/io/
	install -m 755 flatpak/io/sign_ostree_with_gpg.sh $(DESTDIR)$(FLATPAK_DIR)/io/
	install -m 755 flatpak/io/sync_repo_via_rsync.sh $(DESTDIR)$(FLATPAK_DIR)/io/
	install -m 755 flatpak/scripts/ci_build.sh $(DESTDIR)$(FLATPAK_DIR)/scripts/
	install -m 755 flatpak/scripts/ci_deploy.sh $(DESTDIR)$(FLATPAK_DIR)/scripts/
	install -m 755 flatpak/scripts/local_build.sh $(DESTDIR)$(FLATPAK_DIR)/scripts/
	install -m 755 flatpak/scripts/local_deploy.sh $(DESTDIR)$(FLATPAK_DIR)/scripts/

	ln -sf ../lib/releng-tools/build_changelog.py $(DESTDIR)$(BINDIR)/releng-build-changelog
	ln -sf ../lib/releng-tools/build_package.sh $(DESTDIR)$(BINDIR)/releng-build-package
	ln -sf ../lib/releng-tools/flatpak/scripts/ci_build.sh $(DESTDIR)$(BINDIR)/releng-build-flatpak
	ln -sf ../lib/releng-tools/flatpak/scripts/ci_deploy.sh $(DESTDIR)$(BINDIR)/releng-deploy-flatpak

uninstall:
	rm -rf $(DESTDIR)$(LIBDIR)/releng-tools
	rm -f $(DESTDIR)$(BINDIR)/releng-build-changelog
	rm -f $(DESTDIR)$(BINDIR)/releng-build-package
	rm -f $(DESTDIR)$(BINDIR)/releng-build-flatpak
	rm -f $(DESTDIR)$(BINDIR)/releng-deploy-flatpak
