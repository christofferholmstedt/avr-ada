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
# all (default)   : Build RTS
# clean           : Clean RTS and Library
# install         : Build and Install RTS and Library
# uninstall       : Uninstall RTS and Library
#
#
#             Run Time System
#
# build_rts       : Build the standard Ada runtime system for all supported
#                   AVR parts
# clean_rts       : Clean RTS (remove a potentially existing runtime 
#                   installation in the compiler's default adainclude and 
#                   adalib directories)
# install_rts     : Build and install RTS
# uninstall_rts   : Uninstall RTS
#
#
#             Library
#
# build_libs      : Build Library (all support libraries)
# clean_libs      : Clean Library
# install_libs    : Build and install RTS and Library
# uninstall_libs  : Uninstall Library
#
#
#             Sample Applications
#
# build_apps      : Build Sample Applications
# clean_apps      : Clean Sample Applications
# install_apps    : Copy the Sample Applications to $(PREFIX)/share/doc/avr-ada/apps
# uninstall_apps  : Uninstall Sample Applications


###############################################################
#
#  Top
#
all: build_rts build_libs
clean: clean_rts clean_libs
distclean: clean clean_config
install: install_rts install_libs install_apps
uninstall: uninstall_rts uninstall_libs uninstall_cgpr uninstall_apps

.PHONY: all clean distclean install uninstall


###############################################################
#
#  Config
#
config:
	./configure

include config

###############################################################
#
#  Settings
#
RTS_DIR = gcc-$(major).$(minor)-rts
INSTALL_APPS_DIR = $(PREFIX)/share/doc/avr-ada
INSTALL_CGPR_DIR = $(PREFIX)/share/gpr

# Modes for installed items
INSTALL_FILE_MODE = u=rw,go=r
INSTALL_DIR_MODE = u=rwx,go=rx


###############################################################
#
#  Tools
#
CP        = cp
RM        = rm -f
MKDIR     = mkdir
TAR       = tar
CHMOD     = chmod
FIND      = find
GPRCONFIG = gprconfig


###############################################################
#
#  Build
#
build_rts:
	$(MAKE) -C $(RTS_DIR) $@

build_libs:
	$(MAKE) -C avr $@

build_apps:
	$(MAKE) -C apps all

.PHONY: build_rts build_libs build_apps


###############################################################
#
#  Clean
#
clean_rts:
	-$(MAKE) -C $(RTS_DIR) $@

clean_libs:
	-$(MAKE) -C avr $@

clean_apps:
	-$(MAKE) -C apps clean

clean_config:
	-$(RM) config

.PHONY: clean_rts clean_libs clean_apps


###############################################################
#
#  Install
#
install_rts_part:
	$(MAKE) -C $(RTS_DIR) install_rts

install_rts: build_rts install_rts_part install_cgpr

install_libs: build_libs
	$(MAKE) -C avr $@

$(INSTALL_APPS_DIR) $(INSTALL_CGPR_DIR):
	$(MKDIR) -p $@
	$(CHMOD) $(INSTALL_DIR_MODE) $@

install_apps: $(INSTALL_APPS_DIR)
	$(TAR) cf - apps | (cd $(INSTALL_APPS_DIR); tar xvf -)
	$(FIND) $(INSTALL_APPS_DIR) -type f -exec $(CHMOD) $(INSTALL_FILE_MODE) '{}' \;
	$(FIND) $(INSTALL_APPS_DIR) -type d -exec $(CHMOD) $(INSTALL_DIR_MODE) '{}' \;


# If RTS isn't installed then this will fail to find Ada compiler yet it
# will leave the avr.cgpr file without an Ada compiler; don't copy a bad file
$(INSTALL_CGPR_DIR)/avr.cgpr : V := $(strip $(major).$(minor).$(patch))
$(INSTALL_CGPR_DIR)/avr.cgpr : V_Ada := $(strip $(major).$(minor))
$(INSTALL_CGPR_DIR)/avr.cgpr: $(INSTALL_CGPR_DIR)
	$(GPRCONFIG) --batch --target=avr \
	  --config=Asm,$(V) \
	  --config=Asm2,$(V) \
	  --config=Asm_Cpp,$(V) \
	  --config=C,$(V) \
	  --config=Ada,$(V_Ada) -o tmp-avr.cgpr
	$(CP) tmp-avr.cgpr $(INSTALL_CGPR_DIR)/avr.cgpr
	$(RM) tmp-avr.cgpr
	$(CHMOD) $(INSTALL_FILE_MODE) $(INSTALL_CGPR_DIR)/avr.cgpr

install_cgpr: $(INSTALL_CGPR_DIR)/avr.cgpr

.PHONY: install_rts install_libs install_apps install_cgpr


###############################################################
#
#  Uninstall
#
uninstall_rts:
	$(MAKE) -C $(RTS_DIR) $@

uninstall_libs:
	$(MAKE) -C avr $@

uninstall_apps:
	$(RM) -r $(INSTALL_APPS_DIR)

uninstall_cgpr:
	$(RM) $(INSTALL_CGPR_DIR)/avr.cgpr

.PHONY: uninstall_rts uninstall_libs uninstall_apps uninstall_cgpr


###############################################################
#
#  prepare building the installer program
#
DIST_PREP_DIR := /c/temp/avr-ada-dist
dist_prep:
	$(MKDIR) -p $(DIST_PREP_DIR)
	$(MKDIR) -p $(DIST_PREP_DIR)/examples
	$(MKDIR) -p $(DIST_PREP_DIR)/doc
	$(CP) COPYING.txt          $(DIST_PREP_DIR)
	$(CP) -a apps/examples     $(DIST_PREP_DIR)/examples
	$(CP) -a apps/largedemo    $(DIST_PREP_DIR)/examples

unix_eol:
	find . -type f | xargs d2u

-include $(Makefile_post)
