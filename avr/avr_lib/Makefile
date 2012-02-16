###########################################################################
## The AVR-Ada Library is free software;  you can redistribute it and/or ##
## modify it under terms of the  GNU General Public License as published ##
## by  the  Free Software  Foundation;  either  version 2, or  (at  your ##
## option) any later version.  The AVR-Ada Library is distributed in the ##
## hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even ##
## the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR ##
## PURPOSE.  See the GNU General Public License for more details.        ##
###########################################################################

#
# list of primary devices
#
PRIMARY_MCU_LIST := attiny2313 atmega8 atmega168 atmega169 \
   atmega32 atmega328p atmega644 atmega644p

#
# list of not yet supported devices
# excluded_parts should be in sync with AVR-Ada/Makefile:excluded_parts
include ../../excldevs.mk

#
# list of all supported devices
#
# MCU_LIST := $(filter-out $(excluded_parts), $(shell ls -d at*))
MCU_LIST = $(PRIMARY_MCU_LIST)

# ARCH_LIST := avr2 avr25 avr3 avr31 avr35 avr4 avr5 avr51 avr6


# we build separate libraries for each supported device
libs := $(patsubst %, %/lib/libavrada.a, $(MCU_LIST))
thread_libs := $(patsubst %, %/lib/libavr-threads.a, $(MCU_LIST))

# all part specific registers and definitions are made available
mcu_specs := $(patsubst %, %/avr-mcu.ads, $(MCU_LIST))

#
# default target, build all libraries
all:	stamp-links stamp-libs


# first set the variable MCU
at%/lib/libavrada.a : MCU = $(patsubst %/lib/libavrada.a,%, $@)
at%/avr-mcu.ads     : MCU = $(patsubst %/avr-mcu.ads,%, $@)
at%/lib/libavr-threads.a : MCU = $(patsubst %/lib/libavr-threads.a,%, $@)

# then provide the rules for building
at%/lib/libavrada.a: stamp-links at%/obj at%/lib ../avr_lib.gpr ../avr_tools.gpr ../mcu.gpr at%/avr-mcu.ads
	avr-gnatmake -P../avr_lib.gpr -XMCU=$(MCU)

# rule for building the thread library per architecture
at%/lib/libavr-threads.a: at%/obj at%/lib ../avr_threads.gpr ../mcu.gpr
	gprbuild -p --config=../avr.cgpr -P../avr_threads.gpr -XMCU=$(MCU)

at%/avr-mcu.ads:
	echo "pragma Style_Checks (Off);"  > $@
	echo "with AVR.${MCU};"                    >> $@
	echo "package AVR.MCU renames AVR.${MCU};" >> $@

at%/lib at%/obj:
	mkdir -p $@

stamp-links: $(mcu_specs)
	touch $@

stamp-libs: $(thread_libs) $(libs)
	touch $@

# Compile: create assembler files from Ada source files.
%.s : %.adb
	avr-gnatmake -f -u -P../avr_lib -XMCU=$(MCU) $< -cargs -S

%.s : %.ads
	avr-gnatmake -f -u -P../avr_lib -XMCU=$(MCU) $< -cargs -S

clean:
	$(RM) stamp-*
	$(RM) *.o
	$(RM) *.ali
	$(RM) b_*.*
	$(RM) b~*.*
	$(RM) -rf obj lib
	$(RM) -rf at*/obj at*/lib
	$(RM) avr-mcu.ads at*/avr-mcu.ads


# don't delete these intermediate files
.PRECIOUS: at%/avr-mcu.ads at%/lib at%/obj

# always run these commands
.PHONY: clean

# Makefile debug
print-%:
	@echo $* = $($*)
