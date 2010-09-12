#--------------------------------------------------------------------------
#- The AVR-Ada Library is free software;  you can redistribute it and/or --
#- modify it under terms of the  GNU General Public License as published --
#- by  the  Free Software  Foundation;  either  version 2, or  (at  your --
#- option) any later version.  The AVR-Ada Library is distributed in the --
#- hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even --
#- the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR --
#- PURPOSE. See the GNU General Public License for more details.         --
#--------------------------------------------------------------------------

# This is the top level Makefile of AVR-Ada
#
# useful make targets:
#
#
#             Run Time System
#
# build_rts   : rebuild the standard Ada runtime system for all supported
#               AVR parts
# rtsclean    : remove a potentially existing runtime installation in the
#               compiler's default adainclude and adalib directories.
# install_rts : copy the just built Ada runtime system into the
#               compiler's default adainclude and adalib directories.
#
#
#             Support Library
#
# build_libs  : build all the support libraries
# install_libs: copy the support libraries to $(PREFIX)/avr/ada
#
#
#             Documentation
#
# install_doc : copy the documentation to $(PREFIX)/doc/AVR-Ada/web and the 
#               examples to $(PREFIX)/doc/AVR-Ada/examples.
#
###############################################################


-include config

# excluded devices should be in sync with avr/avr_lib/Makefile:excluded_parts
include excldevs.mk

MCU_LIST := $(filter-out $(excluded_parts), $(shell (cd avr/avr_lib; ls -d at*)))
# MCU_LIST := atmega169
ARCH_LIST := avr2 avr25 avr3 avr35 avr4 avr5 avr6

DOC_DIR := $(PREFIX)/share/doc/avr-ada
DOC_DIR_APPS := $(DOC_DIR)/apps
DOC_DIR_DOCS := $(DOC_DIR)/.
DOC_DIRS := $(DOC_DIR) $(DOC_DIR_APPS) $(DOC_DIR_DOCS)


RTS_SOURCE   := gcc-$(major).$(minor)-rts

# default rule: build rts and avrlib;
all: build_rts build_libs


###############################################################
#
#  build and install the run time system (RTS)
#
build_rts install_rts rtsclean:
	$(MAKE) -C $(RTS_SOURCE) $@



###############################################################
#
#  make the AVR library
#
build_libs: build_rts
	make -C avr all


###############################################################
#
#  install the AVR library
#
install_libs:
	make -C avr install

###############################################################
#
#  install RTS and avrlib in the final gcc tree
#
install: install_rts install_libs install_doc

###############################################################
#
#  install docs and example programs
#
install_doc: $(DOC_DIRS)
	cp -a apps $(DOC_DIR)


$(DOC_DIRS):
	mkdir -p $@


###############################################################
#
#  make the sample projects
#

samples:
	make -C apps all


###############################################################
#
#  prepare building the installer program
#

DIST_PREP_DIR := /c/temp/avr-ada-dist
dist_prep:
	mkdir -p $(DIST_PREP_DIR)
	mkdir -p $(DIST_PREP_DIR)/Examples
	mkdir -p $(DIST_PREP_DIR)/doc
	cp COPYING.txt          $(DIST_PREP_DIR)
	cp -a apps/examples     $(DIST_PREP_DIR)/Examples
	cp -a apps/largedemo    $(DIST_PREP_DIR)/Examples

unix_eol:
	find . -type f | xargs d2u


###############################################################
#
#  clean machinery
#

config:
	./configure

clean:
	-rm -f test.adb
	-rm -f test.ali
	-rm -f b~test.*
	-rm -fr build

distclean:  clean
	-make -C $(RTS_SOURCE) clean
	-make -C avr clean
	-make -C apps clean
	-rm config


###############################################################
#
#  remove RTS and avrlib from the gcc tree
#

avrlibclean:
	-chmod a+w -R $(PREFIX)/avr/ada
	-rm -rf $(PREFIX)/avr/ada


maintclean: rtsclean avrlibclean distclean


###############################################################
#
#  Makefile stuff
#

.PHONY: clean distclean rtsclean maintclean samples install_rts

print-%:
	@echo $* = $($*)

.PHONY: printvars

printvars:
	@$(foreach V,$(sort $(.VARIABLES)), \
           $(if $(filter-out environment% default automatic, \
           $(origin $V)),$(warning $V=$($V) ($(value $V)))))