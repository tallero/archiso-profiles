#
# SPDX-License-Identifier: GPL-3.0-or-later

PREFIX ?= /usr/local
BIN_DIR=$(DESTDIR)$(PREFIX)/bin
LIB_DIR=$(DESTDIR)$(PREFIX)/lib/archiso
DOC_DIR=$(DESTDIR)$(PREFIX)/share/doc/archiso
PROFILE_DIR=$(DESTDIR)$(PREFIX)/share/archiso

DOC_FILES=$(wildcard docs/*) $(wildcard *.rst)
SCRIPT_FILES=$(wildcard archiso/*) $(wildcard scripts/*.sh) $(wildcard .gitlab/ci/*.sh) \
             $(wildcard configs/*/profiledef.sh) $(wildcard configs/*/airootfs/usr/local/bin/*)
GIT_FILES=$(shell find . -name "*.git*")

all:

check: shellcheck

shellcheck:
	shellcheck -s bash $(SCRIPT_FILES)

install: install-scripts clean-profiles install-profiles install-doc

install-scripts:
	install -vDm 755 .gitlab/ci/build_repo.sh -t "$(BIN_DIR)/mkarchisoprofile"
	install -vDm 755 .gitlab/ci/build_swap.sh  "$(BIN_DIR)/mkarchisoswap"
	install -vDm 755 .gitlab/ci/setup_user.sh  "$(LIB_DIR)/setup_user.sh"
	install -vDm 755 .gitlab/ci/setup_user.sh  "$(LIB_DIR)/build_archiso_profiles.sh"

clean-profiles:
	rm -rf $(GIT_FILES)

install-profiles:
	install -d -m 755 $(PROFILE_DIR)
	cp -a --no-preserve=ownership configs $(PROFILE_DIR)/

install-doc:
	install -vDm 644 $(DOC_FILES) -t $(DOC_DIR)

.PHONY: check install install-doc install-profiles install-scripts shellcheck
