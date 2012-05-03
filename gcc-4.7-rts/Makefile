#--------------------------------------------------------------------------
#- The AVR-Ada Library is free software;  you can redistribute it and/or --
#- modify it under terms of the  GNU General Public License as published --
#- by  the  Free Software  Foundation;  either  version 2, or  (at  your --
#- option) any later version.  The AVR-Ada Library is distributed in the --
#- hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even --
#- the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR --
#- PURPOSE. See the GNU General Public License for more details.         --
#-                                                                       --
#- As a special exception, if other files instantiate generics from this --
#- unit,  or  you  link  this  unit  with  other  files  to  produce  an --
#- executable   this  unit  does  not  by  itself  cause  the  resulting --
#- executable to  be  covered by the  GNU General  Public License.  This --
#- exception does  not  however  invalidate  any  other reasons why  the --
#- executable file might be covered by the GNU Public License.           --
#--------------------------------------------------------------------------

# This makefile compiles the AVR Ada run time system (RTS)

# Ada source files
ADASRC = system.ads \
   s-maccod.ads \
   s-stoele.ads s-stoele.adb \
   s-unstyp.ads \
   s-bitops.ads s-bitops.adb \
   s-stalib.ads \
   s-parame.ads \
   s-secsta.ads s-secsta.adb \
   s-memory.ads s-memory.adb \
   s-gccbui.ads \
   interfac.ads i-c.ads \
   ada.ads \
   unchconv.ads a-unccon.ads \
   a-charac.ads a-chlat1.ads a-chlat9.ads \
   a-calend.ads a-caldel.ads \
   a-except.ads a-except.adb \
   a-tags.ads a-tags.adb \
   gnat.ads g-souinf.ads

#   s-htable.ads s-htable.adb
#   a-stream.ads
#   s-finroo.ads s-finroo.adb a-finali.ads a-finali.adb
#   a-reatim.adb a-reatim.ads
#   a-interr.ads a-intnam.ads a-intsig.ads s-interr.adb s-interr.ads
#

OBJ = $(ADASRC:.ads=.o)

LIBGNAT_OBJS = s-bitops.o a-except.o s-memory.o a-tags.o s-secsta.o
LIBGNAT_ALIS = $(filter %.ali,$(ADASRC:.ads=.ali)) # filter out the .adb from ADASRC

ARCH_LIST := avr25 avr3 avr31 avr35 avr4 avr5 avr51 avr6

RTS_LIB_LIST := $(patsubst %, rts/%/adalib/libgnat.a, $(ARCH_LIST))
RTS_INC_LIST := $(patsubst %, rts/%/adainclude, $(ARCH_LIST))
RTS_SOURCE   := .

vpath %.ads adainclude
vpath %.adb adainclude

# includes to compile
INC	= -I- -Iadainclude

#compiler flags
ADAFLAGS = -g -Os -gnatn -gnatpg -mmcu=$(MCU)


###### define some variables based on the AVR base path in $(AVR) #######
CC	= avr-gcc
RM	= rm -f
COPY	= cp -p
MOVE    = mv
AR	= avr-ar
RANLIB  = avr-ranlib


# ------------------------------------------
-include ../config


###############################################################
#
#  build the run time system (RTS)
#
all build_rts: ${RTS_LIB_LIST}

rts/%/adalib/libgnat.a : MCU = $(patsubst rts/%/adalib/libgnat.a,%, $@)

rts/%/adalib/libgnat.a: rts/%/adalib rts/%/adainclude
	$(MAKE) clean
	$(MAKE) libgnat.a MCU=$(MCU)
	$(MOVE) libgnat.a $@
	$(MAKE) $(LIBGNAT_ALIS) MCU=$(MCU)
	$(COPY) $(LIBGNAT_ALIS) rts/$(MCU)/adalib
	$(COPY) $(patsubst %,adainclude/%,$(ADASRC)) rts/$(MCU)/adainclude
	$(MAKE) clean

rts/%/adalib:
	mkdir -p $@

rts/%/adainclude:
	mkdir -p $@

libgnat.a: $(LIBGNAT_OBJS)
	$(AR) cr $@ $^
	$(RANLIB) $@

.PRECIOUS: rts/%/adalib rts/%/adainclude

###############################################################
#
#  install the RTS
#
install_rts: build_rts clean_rts
	$(COPY) -r rts $(RTS_BASE)
	chmod a-w -R $(RTS_BASE)/rts
	-mkdir $(RTS_BASE)/adainclude
	-$(COPY) $(RTS_SOURCE)/adainclude/system.ads $(RTS_BASE)/adainclude
	-$(COPY) $(RTS_SOURCE)/README.gnatlink_inst  $(RTS_BASE)/adainclude


###############################################################
#
#  remove RTS from the gcc tree
#
clean_rts:
	-chmod a+w -R $(RTS_BASE)/rts
	-rm -rf $(RTS_BASE)/rts


# keep the order of the following two implicit rules.  This way it
# tries to build a .ali first from .adb if available.  Only if there
# is no .adb, it tries to build from .ads.
%.ali %.o : %.adb
	$(CC) -c $(ADAFLAGS) $(INC) $<

%.ali %.o : %.ads
	$(CC) -c $(ADAFLAGS) $(INC) $<

# --- make instruction to delete created files ---
clean:
	$(RM) *.o
	$(RM) *.ali
	$(RM) libgnat.a


###############################################################
#
#  Makefile stuff
#
.PHONY: clean clean_rts install_rts

print-%:
	@echo $* = $($*)

.PHONY: printvars

printvars:
	@$(foreach V,$(sort $(.VARIABLES)), \
           $(if $(filter-out environment% default automatic, \
           $(origin $V)),$(warning $V=$($V) ($(value $V)))))
