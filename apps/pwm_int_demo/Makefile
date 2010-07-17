# Hey Emacs, this is a -*- makefile -*-
###########################################################################
## The AVR-Ada Library is free software;  you can redistribute it and/or ##
## modify it under terms of the  GNU General Public License as published ##
## by  the  Free Software  Foundation;  either  version 2, or  (at  your ##
## option) any later version.  The AVR#Ada Library is distributed in the ##
## hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even ##
## the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR ##
## PURPOSE. See the GNU General Public License for more details.         ##
###########################################################################

# This makefile is adapted from the sample Makefile of WinAVR by Eric
# B. Wedington, Jörg Wunsch and others.  As they released it to the
# Public Domain, I could pretend that I wrote it myself.  Honestly, I
# removed many (probably useful) parts to better fit the GNAT project makes. 
# 

# On command line:
#
# make all = Make software.
#
# make clean = Clean out built project files.
#
# make program = Download the hex file to the device, using avrdude.
#                Please customize the avrdude settings below first!
#
# make filename.s = Just compile filename.c into the assembler code only.
#
#
# To rebuild project do "make clean" then "make all".
#----------------------------------------------------------------------------


# MCU name
MCU := at90s2313


# Processor frequency.
#     This will define a symbol, F_CPU, in all C source code files equal
#     to the processor frequency. You can then use this symbol in your
#     source code to calculate timings. Do NOT tack on a 'UL' at the
#     end, this will be done automatically to create a 32-bit value in
#     your source code.
F_CPU = 3686400


# Output format. (can be srec, ihex, binary)
FORMAT = ihex


# put the names of the target files here (without extension)
ADA_TARGETS := demo


# GNAT project file
GPR := demo.gpr


# Optimization level, can be [0, 1, 2, 3, s]. 
#     0 = turn off optimization. s = optimize for size.
#     (Note: 3 is not always the best optimization level. See avr-libc FAQ.)
# Setting OPT here overrides the setting in the GPR file for Ada.
OPT = s


# Debugging format.
#     Native formats for AVR-GCC's -g are dwarf-2 [default] or stabs.
#     AVR Studio 4.10 requires dwarf-2.
#     AVR [Extended] COFF format requires stabs, plus an avr-objcopy run.
DEBUG = dwarf-2


#---------------- GNATMAKE Options ----------------
MFLAGS = -O$(OPT) -XMCU=$(MCU) -P$(GPR) --RTS=$(ADA_RTS)


#---------------- Assembler Options ----------------
#  -Wa,...:   tell GCC to pass this to the assembler.
#  -ahlms:    create listing
#  -gstabs:   have the assembler create line number information; note that
#             for use in COFF files, additional information about filenames
#             and function names needs to be present in the assembler source
#             files -- see avr-libc docs [FIXME: not yet described there]
ASFLAGS = -Wa,-adhlns=$(<:.S=.lst),-gstabs 


#---------------- External Memory Options ----------------

# 64 KB of external RAM, starting after internal RAM (ATmega128!),
# used for variables (.data/.bss) and heap (malloc()).
#EXTMEMOPTS = -Wl,-Tdata=0x801100,--defsym=__heap_end=0x80ffff

# 64 KB of external RAM, starting after internal RAM (ATmega128!),
# only used for heap (malloc()).
#EXTMEMOPTS = -Wl,--defsym=__heap_start=0x801100,--defsym=__heap_end=0x80ffff

EXTMEMOPTS =



#---------------- Programming Options (avrdude) ----------------

# Programming hardware: alf avr910 avrisp bascom bsd 
# dt006 pavr picoweb pony-stk200 sp12 stk200 stk500
#
# Type: avrdude -c ?
# to get a full listing.
#
AVRDUDE_PROGRAMMER = stk500

# com1 = serial port. Use lpt1 to connect to parallel port.
AVRDUDE_PORT = com1    # programmer connected to serial device

AVRDUDE_WRITE_FLASH = -U flash:w:
AVRDUDE_WRITE_EEPROM = -U eeprom:w:


# Uncomment the following if you want avrdude's erase cycle counter.
# Note that this counter needs to be initialized first using -Yn,
# see avrdude manual.
#AVRDUDE_ERASE_COUNTER = -y

# Uncomment the following if you do /not/ wish a verification to be
# performed after programming the device.
#AVRDUDE_NO_VERIFY = -V

# Increase verbosity level.  Please use this when submitting bug
# reports about avrdude. See <http://savannah.nongnu.org/projects/avrdude> 
# to submit bug reports.
#AVRDUDE_VERBOSE = -v -v

AVRDUDE_FLAGS = -p $(MCU) -P $(AVRDUDE_PORT) -c $(AVRDUDE_PROGRAMMER)
AVRDUDE_FLAGS += $(AVRDUDE_NO_VERIFY)
AVRDUDE_FLAGS += $(AVRDUDE_VERBOSE)
AVRDUDE_FLAGS += $(AVRDUDE_ERASE_COUNTER)


#============================================================================


# Define programs and commands.
SHELL    := sh
CC       := avr-gcc
OBJCOPY  := avr-objcopy
OBJDUMP  := avr-objdump
SIZE     := avr-size
NM       := avr-nm
AVRDUDE  := avrdude
REMOVE   := rm -f
COPY     := cp
RENAME   := mv
WINSHELL := cmd
GNATMAKE := avr-gnatmake


# Define Messages
# English
MSG_ERRORS_NONE := Errors: none
MSG_BEGIN := -------- begin --------
MSG_END := --------  end  --------
MSG_SIZE_BEFORE := Size before: 
MSG_SIZE_AFTER := Size after:
MSG_FLASH := Creating load file for Flash:
MSG_EEPROM = Creating load file for EEPROM:
MSG_EXTENDED_LISTING := Creating Extended Listing:
MSG_SYMBOL_TABLE := Creating Symbol Table:
MSG_ASSEMBLING := Assembling:
MSG_CLEANING := Cleaning project:
MSG_ADAMAKEING := Making:


# Combine all necessary flags and optional flags.
# Add target processor to flags.
ALL_ASFLAGS = -mmcu=$(MCU) -I. -x assembler-with-cpp $(ASFLAGS)


# Default target.
all: begin gccversion build sizeafter end


ADA_TARGETS_ELF = $(addsuffix .elf, $(ADA_TARGETS))
ADA_TARGETS_HEX = $(addsuffix .hex, $(ADA_TARGETS))
ADA_TARGETS_EEP = $(addsuffix .eep, $(ADA_TARGETS))
ADA_TARGETS_LSS = $(addsuffix .lss, $(ADA_TARGETS))
ADA_TARGETS_SYM = $(addsuffix .sym, $(ADA_TARGETS))
ADA_TARGETS_SIZE = $(addsuffix .size, $(ADA_TARGETS))


# where is the AVR library installed
GCC_PREFIX := $(dir $(shell avr-gcc -print-libgcc-file-name))../../../../
AVR_PRJ = $(GCC_PREFIX)avr/ada

# where is the runtime system.  The path is relative to the compiler gnat1
ADA_RTS := rts/$(MCU)


build: $(ADA_TARGETS_ELF) $(ADA_TARGETS_HEX) $(ADA_TARGETS_EEP) \
   $(ADA_TARGETS_LSS) $(ADA_TARGETS_SYM)


# Eye candy.
# AVR Studio 3.x does not check make's exit code but relies on
# the following magic strings to be generated by the compile job.
begin:
	@echo
	@echo $(MSG_BEGIN)

end:
	@echo $(MSG_END)
	@echo


# Display size of file.
sizeafter: $(ADA_TARGETS_SIZE)

%.size: %.elf FORCE
	echo $(MSG_SIZE_AFTER)
	$(SIZE) --format=avr --mcu=$(MCU) $<


# Display compiler version information.
gccversion : 
	@$(CC) --version


# Program the device.  
%.program: %.hex %.eep
	$(AVRDUDE) $(AVRDUDE_FLAGS) $(AVRDUDE_WRITE_FLASH)$*.hex
# $(AVRDUDE_WRITE_EEPROM)


# Create final output files (.hex, .eep) from ELF output file.
%.hex: %.elf
	@echo
	@echo $(MSG_FLASH) $@
	$(OBJCOPY) -O $(FORMAT) -R .eeprom $< $@

%.eep: %.elf
	@echo
	@echo $(MSG_EEPROM) $@
	-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom="alloc,load" \
	--change-section-lma .eeprom=0 -O $(FORMAT) $< $@

# Create extended listing file from ELF output file.
%.lss: %.elf
	@echo
	@echo $(MSG_EXTENDED_LISTING) $@
	$(OBJDUMP) -h -S $< > $@

# Create a symbol table from ELF output file.
%.sym: %.elf
	@echo
	@echo $(MSG_SYMBOL_TABLE) $@
	$(NM) -n $< > $@


# Link: create ELF output file from object files.

# --- build and link using gnatmake, force rebuilding by gnatmake to
#     make sure dependencies are resolved
%.elf: $(GPR) obj FORCE
	@echo
	@echo $(MSG_ADAMAKEING) $@
	ADA_PROJECT_PATH=$(AVR_PRJ) $(GNATMAKE) $(MFLAGS) -XMAIN=$*


# Compile: create assembler files from Ada source files.
%.s : %.adb
	ADA_PROJECT_PATH=$(AVR_PRJ) $(GNATMAKE) -f -u $(MFLAGS) $< -cargs -S 


%.s : %.ads
	ADA_PROJECT_PATH=$(AVR_PRJ) $(GNATMAKE) -f -u $(MFLAGS) $< -cargs -S 


# Assemble: create object files from assembler source files.
%.o : %.S
	@echo
	@echo $(MSG_ASSEMBLING) $<
	$(CC) -c $(ALL_ASFLAGS) $< -o $@


# Create the directory where all objects are stored
obj:
	$(RM) obj
	mkdir obj


# Target: clean project.
clean: begin clean_gnat clean_list end

clean_gnat:
	@echo
	@echo $(MSG_CLEANING)
	ADA_PROJECT_PATH=$(AVR_PRJ) avr-gnatclean -XMCU=$(MCU) -P$(GPR)

clean_list :
	$(REMOVE) *.hex
	$(REMOVE) *.eep
	$(REMOVE) *.elf
	$(REMOVE) *.map
	$(REMOVE) *.sym
	$(REMOVE) *.lss
	$(REMOVE) *.ali
	$(REMOVE) b~*.ad?
	$(REMOVE) obj/*

FORCE:


# Listing of phony targets.
.PHONY : all begin finish end sizebefore sizeafter gccversion \
   build elf hex eep lss sym clean clean_list program 

# -*- makefile -*-

ifdef TRACE
.PHONY: _trace _value

_trace:
	@$(MAKE) --no-print-directory TRACE= $(TRACE)='$$(warning TRACE $(TRACE))$(shell $(MAKE) TRACE=$(TRACE) _value)'
_value:
	@echo '$(value $(TRACE))'
endif


print-%:
	@echo $* = $($*)

.PHONY: printvars

printvars:
	@$(foreach V,$(sort $(.VARIABLES)), \
           $(if $(filter-out environment% default automatic, \
           $(origin $V)),$(warning $V=$($V) ($(value $V)))))
