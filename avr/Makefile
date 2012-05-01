###########################################################################
## The AVR-Ada Library is free software;  you can redistribute it and/or ##
## modify it under terms of the  GNU General Public License as published ##
## by  the  Free Software  Foundation;  either  version 2, or  (at  your ##
## option) any later version.  The AVR-Ada Library is distributed in the ##
## hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even ##
## the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR ##
## PURPOSE.  See the GNU General Public License for more details.        ##
###########################################################################

# inherit some vars from above
-include ../config
include ../excldevs.mk
MCU_LIST := $(filter-out $(excluded_parts), $(shell (cd avr_lib; ls -d at*)))

#
# Installation directory
#
# default search directories for gpr-files of gnatmake and gprbuild
# 1: <prefix>/<target>/lib/gnat (gprbuild requires --target)
# 2: <prefix>/share/gpr/
# 3: <prefix>/lib/gnat
PREFIX = $(RTS_BASE)/../../../..
INSTALL_DIR = $(PREFIX)/avr/lib/gnat

libraries := debug lcd sensirion onewire slip threads
library_objs := $(patsubst %,%/obj, $(libraries))
library_libs := $(patsubst %,%/lib, $(libraries))
library_gprs := $(patsubst %,%_lib.gpr, $(libraries))

OBJ_DIRS := $(patsubst %,$(INSTALL_DIR)/avr_lib/%/obj, $(MCU_LIST)) $(patsubst %,$(INSTALL_DIR)/%/obj, $(libraries))

#
#
# default target, build all libraries
all:	avr_lib/stamp-links
# avr_lib/stamp-libs

avr_lib/stamp-links:
	$(MAKE) -C avr_lib stamp-links

avr_lib/stamp-libs:
	$(MAKE) -C avr_lib stamp-libs

../config:
	$(MAKE) -C .. config

install: $(INSTALL_DIR) $(library_objs) $(library_libs) copy_libs $(OBJ_DIRS)
#   restrict_permissions

restrict_permissions:
	chmod -R a-w $(INSTALL_DIR)
	-chown -R root $(INSTALL_DIR)  &>/dev/null

$(library_objs) $(library_libs) $(OBJ_DIRS) ${INSTALL_DIR}:
	mkdir -p $@

copy_libs:
	tar --create --file - \
           --exclude .svn \
           --exclude obj \
           --exclude Makefile \
           --exclude "*~" \
           --exclude "*.o" \
           --exclude */*~ \
           avr_lib avr.cgpr avr_tools.gpr avr_lib.gpr threads_lib.gpr mcu.gpr gnat.adc avr_app.gpr \
           $(libraries) \
           $(library_gprs) \
           | (cd $(INSTALL_DIR); tar xpvf -)

clean:
	$(RM) stamp-*
	$(RM) *.o
	$(RM) *.ali
	$(RM) b_*.*
	$(RM) b~*.*
	$(RM) -rf obj lib
	$(RM) sensirion/obj/*
	$(MAKE) -C avr_lib clean

# always run these commands
.PHONY: clean install copy_libs restrict_permissions

# Makefile debug
print-%:
	@echo $* = $($*)
