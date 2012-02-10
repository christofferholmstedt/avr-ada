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
PRIM_MCU_LIST := atmega8 atmega168 atmega169 \
   atmega32 atmega328p atmega644 atmega644p

#
# list of not yet supported devices
# excluded_parts should be in sync with AVR-Ada/Makefile:excluded_parts
include ../../excldevs.mk
# excluded_parts := at86rf401 atmega2560 atmega2561 atmega128a atmega168pa \
#    atmega16a atmega324pa atmega32a atmega32u6 atmega64a atmega88pa atmega8a \
#    attiny13a

#
# list of all supported devices
#
MCU_LIST := $(filter-out $(excluded_parts), $(shell ls -d at*))
# MCU_LIST := atmega169

# we build separate libraries for each supported device
libs := $(patsubst %, %/lib/libavrada.a, $(MCU_LIST))

# all part specific registers and definitions are made available
mcu_specs := $(patsubst %, %/avr-mcu.ads, $(MCU_LIST))

#
# default target, build all libraries
all:	stamp-links stamp-libs


# first set the variable MCU
at%/lib/libavrada.a : MCU = $(patsubst %/lib/libavrada.a,%, $@)
at%/avr-mcu.ads     : MCU = $(patsubst %/avr-mcu.ads,%, $@)

# then provide the rules for building
at%/lib/libavrada.a: stamp-links at%/obj at%/lib ../avr_lib.gpr ../avr_tools.gpr ../mcu.gpr at%/avr-mcu.ads
	avr-gnatmake -P../avr_lib.gpr -XMCU=$(MCU)

avr-real_time.ads: avr-real_time.ads.gp
	$(GNATPREP) -b -DTICK=tick_1ms $< $@

avr-real_time_1s.ads: avr-real_time.ads.gp
	$(GNATPREP) -b -DTICK=tick_1s $< $@

avr-real_time_5us.ads: avr-real_time.ads.gp
	$(GNATPREP) -b -DTICK=tick_5us $< $@

at%/avr-mcu.ads:
	echo "pragma Style_Checks (Off);"  > $@
	echo "with AVR.${MCU};"                    >> $@
	echo "package AVR.MCU renames AVR.${MCU};" >> $@

at%/obj :
	mkdir -p $@

at%/lib :
	mkdir -p $@

stamp-links: $(mcu_specs)
	touch $@

stamp-libs: $(libs)
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
