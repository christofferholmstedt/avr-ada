#!/bin/sh
 
#--------------------------------------------------------------------------
#-                AVR-Ada - A GCC Ada environment for AVR-Atmel          --
#-                                      *                                --
#-                                 AVR-Ada 0.5                           --
#-                     Copyright (C) 2003-2005 Bernd Trog                --
#-                     Copyright (C) 2005 Stephane Riviere               --
#-                     Copyright (C) 2005, 2007 Rolf Ebert               --
#-                            avr-ada.sourceforge.net                    --
#-                                      *                                --
#-                                                                       --
#--------------------------------------------------------------------------
#- The AVR-Ada Library is free software;  you can redistribute it and/or --
#- modify it under terms of the  GNU General Public License as published --
#- by  the  Free Software  Foundation;  either  version 2, or  (at  your --
#- option) any later version.  The AVR-Ada Library is distributed in the --
#- hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even --
#- the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR --
#- PURPOSE. See the GNU General Public License for more details.         --
#--------------------------------------------------------------------------
 
#--------------------------------------------------------------------------
# Under Windows 2K/XP, you need : 
# - MinGW-3.2.0 RC3 (which contains GCC 3.4.2 with Ada support)
# - MSYS-1.0.10 or MSYS-1.0.11
# - Windows versions of flex and bison (either from WinAVR or cygwin)
#
# Building binutils requires a working "makeinfo" from the texinfo
# distribution.  Current MSYS contains makeinfo 4.3 which does *not*
# work correctly.  I use makeinfo from Cygwin by putting the Cygwin
# bin directory at the end of the PATH variable and removing the old
# copy from /bin.
#
# rm /bin/makeinfo.exe
# export PATH=$PATH:/d/Programme/cygwin/bin
#
#---------------------------------------------------------------------------
#
# $DOWNLOAD  : should point to directory which contains the files
#              specified by : FILE_BINUTILS, FILE_GCC and FILE_AVR_LIBC
# $AVR_BUILD : the temporary directory used to build AVR-Ada
# $PREFIX    : the root of the installation directory
# $PATCH_DIR : the directory containing patches
# $FILE_EXT  : choose "tar.gz", "tgz" or "tar.bz2" (lower case mandatory)
# $FILE_...  : filenames of the source distributions without extension
# $BINUTILS_PATCHES : blank separated list of binutils patch files (which 
#                     reside in the $PATCH_DIR) 
# $GCC_PATCHES      : blank separated list of patch files for gcc
#
#---------------------------------------------------------------------------
 
VER_GCC=4.2.0
VER_BINUTILS=2.17
VER_LIBC=1.4.6

FILE_EXT=tar.bz2
FILE_BINUTILS=binutils-2.17
FILE_GCC=gcc-4.2.1
FILE_AVR_LIBC=avr-libc-1.4.6

DOWNLOAD=/k/Data/Development/gcc-cvs/src
AVR_BUILD=/k/Data/Development/gcc-cvs/build-avr-$FILE_GCC
PREFIX=/mingw/avr

AVRADA_PATCH_DIR=/k/Data/Development/AVR-Ada/patches
AVRADA_GCC_DIR="$AVRADA_PATCH_DIR/gcc/$VER_GCC"

WINAVR_PATCH_DIR=/k/Data/Development/gcc-cvs/WinAVR/patches
WINAVR_BINUTILS_DIR="$WINAVR_PATCH_DIR/binutils/$VER_BINUTILS"
WINAVR_GCC_DIR="$WINAVR_PATCH_DIR/gcc/$VER_GCC"

BINUTILS_PATCHES=`(cd $WINAVR_BINUTILS_DIR; ls -1 [0-9][0-9]-binutils-*.patch)`

WINAVR_GCC_PATCHES=`(cd $WINAVR_GCC_DIR; ls -1 [0-9][0-9]-gcc-*.patch)`
AVRADA_GCC_PATCHES=`(cd $AVRADA_GCC_DIR; ls -1 [0-9][0-9]-gcc-*.patch)`
GCC_PATCHES="$WINAVR_GCC_PATCHES $AVRADA_GCC_PATCHES"

# actions:
delete_build_dir="yes"
delete_install_dir="no"
build_binutils="yes"
build_gcc="yes"
build_libc="yes"
#CC="gcc -mno-cygwin"
CC=gcc
export CC

#---------------------------------------------------------------------------
# utility functions
#---------------------------------------------------------------------------
 
# print date/time in ISO format
function print_time () {
    date +"%Y-%m-%d_%H:%M:%S"
}
 
function display_noeol () {
  printf "$@"
  printf "$@" >> $AVR_BUILD/build.log
}
 
function display () {
  echo "$@"
  echo "$@" >> $AVR_BUILD/build.log
}
 
function log () {
  echo "$@" >> $AVR_BUILD/build.log
}
 
function header () {
    display
    display       "--------------------------------------------------------------"
    display_noeol `print_time`
    display "  $@"
    display       "--------------------------------------------------------------"
    display
}

function check_return_code () {
   if [ $? != 0 ]; then 
       echo  
       echo " **** The last command failed :(" 
       echo "Please check the generated log files for errors and warnings." 
       echo "Exiting.." 
       exit 2
   fi 
}
 
#---------------------------------------------------------------------------
# build script
#---------------------------------------------------------------------------
 
#echo "Please adjust this file to your environment before launching it again."
#exit
 
 
echo "--------------------------------------------------------------"
echo "GCC AVR-Ada build script: all output is saved in log files"
echo "--------------------------------------------------------------"
echo
 
GCC_VERSION=`$CC -dumpversion`
GCC_MAJOR=`echo $GCC_VERSION | awk -F. ' { print $1; } '`
GCC_MINOR=`echo $GCC_VERSION | awk -F. ' { print $2; } '`
GCC_PATCH=`echo $GCC_VERSION | awk -F. ' { print $3; } '`
 
if [ $GCC_VERSION < "3.4.0" ] ; then
    echo "($version) **** too old ****"
    echo "AVR-Ada requires gcc-3.4.0 or newer"
    exit 2
else
    echo "Found native compiler gcc-"$GCC_VERSION
fi

if test $delete_build_dir = "yes" ; then
    echo
    echo "--------------------------------------------------------------"
    echo "Deleting previous build"
    echo "--------------------------------------------------------------"
    echo

    echo "Deleting :" $AVR_BUILD
    rm -fr $AVR_BUILD
 
    mkdir $AVR_BUILD
 
    touch $AVR_BUILD/build.sum
    touch $AVR_BUILD/build.log
else
    mkdir $AVR_BUILD
fi
 
if test $delete_install_dir = "yes" ; then
    echo "Deleting :" $PREFIX
    rm -fr $PREFIX
fi
 
 
print_time > $AVR_BUILD/time_run.log
 
if test $build_binutils = "yes" ; then
   #########################################################################
   header "Building Binutils"
 
 
   cd $AVR_BUILD
 
   display "Extracting $DOWNLOAD/$FILE_BINUTILS.$FILE_EXT ..."
   if test "$FILE_EXT" = "tar.bz2" ; then
       tar xjf $DOWNLOAD/$FILE_BINUTILS.$FILE_EXT
   else
       tar xzf $DOWNLOAD/$FILE_BINUTILS.$FILE_EXT
   fi
 
   display "patching binutils"

   cd $AVR_BUILD/$FILE_BINUTILS
   for p in $BINUTILS_PATCHES; do
       display "   $p"
       if test -f $PATCH_DIR/$p ; then
	   PDIR=$PATCH_DIR
	   STRP=1
       elif test -f $WINAVR_BINUTILS_DIR/$p ; then
	   PDIR=$WINAVR_BINUTILS_DIR
	   STRP=0
       else
	   display "cannot find $p in any of the patch directories"
	   exit 2
       fi
       patch --verbose --strip=$STRP --input=$PDIR/$p  2>&1 >> $AVR_BUILD/build.log
       check_return_code
   done
   
   
   mkdir $AVR_BUILD/binutils-obj
 
   cd $AVR_BUILD/binutils-obj
 
   display "Configure binutils ... (log in $AVR_BUILD/step01_bin_configure.log)"
 
   ../$FILE_BINUTILS/configure --prefix=$PREFIX \
       --target=avr \
       &>$AVR_BUILD/step01_bin_configure.log
   check_return_code
 
   display "Make binutils ...      (log in $AVR_BUILD/step02_bin_make.log)"
 
   make &>$AVR_BUILD/step02_bin_make.log 
   check_return_code
 
   display "Install binutils ...   (log in $AVR_BUILD/step03_bin_install.log)"
 
   make install &>$AVR_BUILD/step03_bin_install.log
   check_return_code
fi
 
 
if test $build_gcc = "yes" ; then
    #########################################################################
    header "Building gcc cross compiler for AVR"
 
    cd $AVR_BUILD
 
    display "Extracting $DOWNLOAD/$FILE_GCC.$FILE_EXT ..."
    if test "$FILE_EXT" = "tar.bz2" ; then
	tar xjf $DOWNLOAD/$FILE_GCC.$FILE_EXT
    else
	tar xzf $DOWNLOAD/$FILE_GCC.$FILE_EXT 
    fi
 
    display "patching gcc"
 
    cd $AVR_BUILD/$FILE_GCC
    for p in $GCC_PATCHES; do
	display "   $p"
	if test -f $AVRADA_GCC_DIR/$p ; then
	    PDIR=$AVRADA_GCC_DIR
	    STRP=0
	elif test -f $WINAVR_GCC_DIR/$p ; then
	    PDIR=$WINAVR_GCC_DIR
	    STRP=0
	else
	    display "cannot find $p in any of the patch directories"
	    exit 2
	fi
	patch --verbose --strip=$STRP --input=$PDIR/$p  2>&1 >> $AVR_BUILD/build.log
        check_return_code
    done
 
 
    export PATH=$PREFIX/bin:$PATH
 
    mkdir $AVR_BUILD/gcc-obj
    cd $AVR_BUILD/gcc-obj
 
    display "Configure GCC-AVR ... (log in $AVR_BUILD/step04_gcc_configure.log)"
 
    ../$FILE_GCC/configure --prefix=$PREFIX \
	--target=avr \
	--enable-languages=ada,c \
	--with-dwarf2 \
	--disable-nls \
    	--disable-libssp \
    	--disable-libada \
	&>$AVR_BUILD/step04_gcc_configure.log
    check_return_code

    display "Make GCC ...          (log in $AVR_BUILD/step05_gcc_gcc_obj.log)"
 
    make &> $AVR_BUILD/step05_gcc_gcc_obj.log
    check_return_code
 
    # gnattools required a separate build step in gcc-3.*
    if test $GCC_MAJOR = "3" ; then
        display "Make gnattools ...    (log in $AVR_BUILD/step06_cross_make.log)"
 
        cd $AVR_BUILD/gcc-obj/gcc

        make cross-gnattools &> $AVR_BUILD/step06_cross_make.log
        check_return_code

        make                 &> $AVR_BUILD/step07_gcc_make.log
        check_return_code
    fi
    
    display "Install GCC ...       (log in $AVR_BUILD/step08_gcc_install.log)"
 
    cd $AVR_BUILD/gcc-obj
    make install &>$AVR_BUILD/step08_gcc_install.log
    check_return_code
fi
 
 
if test $build_libc = "yes" ; then
    #########################################################################
    header "Building AVR libc"
 
    cd $AVR_BUILD
 
    display "Extracting $DOWNLOAD/$FILE_AVR_LIBC.$FILE_EXT ..."
    if test "$FILE_EXT" = "tar.bz2" ; then
	tar xjf $DOWNLOAD/$FILE_AVR_LIBC.$FILE_EXT
    else
	tar xzf $DOWNLOAD/$FILE_AVR_LIBC.$FILE_EXT
    fi
 
 
    cd $AVR_BUILD/$FILE_AVR_LIBC

    display "configure AVR-LIBC ... (log in $AVR_BUILD/step09_libc_conf.log)"
    CC=avr-gcc ./configure --build=`./config.guess` --host=avr --prefix=$PREFIX &>$AVR_BUILD/step09_libc_conf.log
    check_return_code

    display "Make AVR-LIBC ... (log in $AVR_BUILD/step10_libc_make.log)"
    make &>$AVR_BUILD/step10_libc_make.log
    check_return_code

    display "Install AVR-LIBC ... (log in $AVR_BUILD/step11_libc_install.log)"
    make install &>$AVR_BUILD/step11_libc_install.log
    check_return_code
fi
 
#---------------------------------------------------------------------------
 
print_time >> $AVR_BUILD/time_run.log
 
cd ..
 
#########################################################################
header  "Build end"
 
display
display "Build logs are located in $AVR_BUILD"
display "Programs are in the $PREFIX hierarchy"
display "You may remove $AVR_BUILD directory"
 
#---------------------------------------------------------------------------
# eof
#---------------------------------------------------------------------------
