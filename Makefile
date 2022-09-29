#
# SPDX-License-Identifier: GPL-3.0-or-later

PREFIX ?= /usr/local
BIN_DIR=$(DESTDIR)$(PREFIX)/bin
LIB_DIR=$(DESTDIR)$(PREFIX)/lib/archiso
DOC_DIR=$(DESTDIR)$(PREFIX)/share/doc/archiso
PROFILE_DIR=$(DESTDIR)$(PREFIX)/share/archiso

PROFILES=desktop desktopbase ebaseline ereleng
DOC_FILES=$(wildcard docs/*) $(wildcard *.md)
SCRIPT_FILES=$(wildcard archiso/*) $(wildcard scripts/*.sh) $(wildcard .gitlab/ci/*.sh) \
             $(wildcard */profiledef.sh) $(wildcard */packages.extra) \
             $(wildcard */airootfs/usr/local/bin/*)
GIT_FILES=$(shell find . -name ".gitignore" -o -name ".gitattributes" -o -name ".gitkeep")

all:

check: shellcheck

shellcheck:
	shellcheck -s bash $(SCRIPT_FILES)

install: install-scripts clean-profiles install-profiles install-doc

install-scripts:
	install -d -m 755 $(LIB_DIR)/jupyter
	install -vDm 755 .gitlab/ci/build_swap.sh "$(BIN_DIR)/mkarchisoswap"
	install -vDm 755 .gitlab/ci/setup_user.sh "$(LIB_DIR)/setup_user.sh"
	install -vDm 755 .gitlab/ci/build_archiso_profiles.sh "$(LIB_DIR)/build_archiso_profiles.sh"
	cp -a --no-preserve=ownership .gitlab/ci/jupyter/* "$(LIB_DIR)/jupyter"

clean-profiles:
	rm -rf $(GIT_FILES)

install-profiles:
	install -d -m 755 $(PROFILE_DIR)/configs
	cp -a --no-preserve=ownership $(PROFILES) $(PROFILE_DIR)/configs

install-doc:
	install -vDm 644 README.md $(DOC_DIR)/extra-profiles.md
	install -vDm 644 $(DOC_FILES) -t $(DOC_DIR)

.PHONY: check install install-doc install-profiles install-scripts shellcheck
