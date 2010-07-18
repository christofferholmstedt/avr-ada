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
# tools
#
GNATPREP := avr-gnatprep

#
# list of primary devices
#
PRIM_MCU_LIST := at90s2313 at90s8515 atmega8 atmega162 atmega168 atmega169 \
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

# devices with 8 bit wide EEPROM addresses
EEPROM_8BIT := at90s2313 at90s2323 at90s2343 at90s4414 at90s4433 \
   at90s4434 atmega48 attiny13 attiny22 attiny2313 attiny26 
eeprom_8bit_bodies := $(patsubst %,%/avr-eeprom.adb, $(EEPROM_8BIT))
# the name of the "write enable" bit is PE on some devices (otherwise it is WE)
EEPROM_PE := atmega168 atmega328p atmega644 atmega644p
eeprom_pe_bodies := $(patsubst %,%/avr-eeprom.adb, $(EEPROM_PE))

# the devices that use USART0
UART_USART0 := atmega162 atmega168 atmega169 atmega328p atmega644 atmega644p
usart0_bodies := $(patsubst %,%/avr-uart.adb, $(UART_USART0))

# the devices that use USART
UART_USART  := atmega8 atmega32
usart_bodies := $(patsubst %,%/avr-uart.adb, $(UART_USART))

# old UART devices
UART_UART   := at90s2313 at90s8515
uart_bodies := $(patsubst %,%/avr-uart.adb, $(UART_UART))

# detailed power management
POWER        := atmega168 atmega169 atmega328p
power_bodies := $(patsubst %,%/avr-power.adb, $(POWER))

#
#
#
# default target, build all libraries
all:	stamp-links stamp-libs


# first set the variable MCU
at%/lib/libavrada.a : MCU = $(patsubst %/lib/libavrada.a,%, $@)
at%/avr-mcu.ads     : MCU = $(patsubst %/avr-mcu.ads,%, $@)
at%/avr-power.adb   : MCU = $(patsubst %/avr-power.adb,%, $@)
at%/avr-uart.adb    : MCU = $(patsubst %/avr-uart.adb,%, $@)

# then provide the rules for building
at%/lib/libavrada.a: stamp-links at%/obj at%/lib ../avr.gpr ../mcu.gpr at%/avr-mcu.ads 
	avr-gnatmake -P../avr -XMCU=$(MCU)


$(eeprom_8bit_bodies): avr-eeprom.adb.gp
	$(GNATPREP) -b -Deeprom_addr_8bit=true -Dwrite_bit_name_is_WE=true $< $@
$(eeprom_pe_bodies): avr-eeprom.adb.gp
	$(GNATPREP) -b -Deeprom_addr_8bit=false -Dwrite_bit_name_is_WE=false $< $@
avr-eeprom.adb: avr-eeprom.adb.gp
	$(GNATPREP) -b -Deeprom_addr_8bit=false -Dwrite_bit_name_is_WE=true $< $@

$(uart_bodies): avr-uart.adb.gp
	$(GNATPREP) -b -DUART=UART -DMCU=$(MCU) $< $@

$(usart_bodies): avr-uart.adb.gp
	$(GNATPREP) -b -DUART=USART -DMCU=$(MCU) $< $@

$(usart0_bodies): avr-uart.adb.gp
	$(GNATPREP) -b -DUART=USART0 -DMCU=$(MCU) $< $@

$(power_bodies): avr-power.adb.gp
	$(GNATPREP) -b -DMCU=$(MCU) $< $@

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

stamp-links: $(mcu_specs) \
   $(eeprom_8bit_bodies) $(eeprom_pe_bodies) avr-eeprom.adb \
   $(uart_bodies) $(usart0_bodies) $(usart_bodies) \
   $(power_bodies)
	touch $@

stamp-libs: $(libs)
	touch $@

clean:
	$(RM) stamp-*
	$(RM) *.o
	$(RM) *.ali
	$(RM) b_*.*
	$(RM) b~*.*
	$(RM) -rf obj lib
	$(RM) -rf at*/obj at*/lib
	$(RM) avr-mcu.ads at*/avr-mcu.ads
	$(RM) $(eeprom_8bit_bodies)
	$(RM) avr-eeprom.adb-8bit
	$(RM) avr-eeprom.adb
	$(RM) $(uart_bodies) $(usart_bodies) $(usart0_bodies)
	$(RM) avr-uart.adb
	$(RM) avr-uart.adb-*


# don't delete these intermediate files
.PRECIOUS: at%/avr-mcu.ads at%/lib at%/obj

# always run these commands
.PHONY: clean

# Makefile debug
print-%:
	@echo $* = $($*)
