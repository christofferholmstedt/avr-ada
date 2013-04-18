#!/bin/bash

#--------------------------------------------------------------------------
#-                AVR-Ada - A GCC Ada environment for AVR-Atmel          --
#-                                      *                                --
#-                                 AVR-Ada 1.3.0                         --
#-                     Copyright (C) 2005, 2007, 2012, 2013 Rolf Ebert   --
#-                     Copyright (C) 2009 Neil Davenport                 --
#-                     Copyright (C) 2005 Stephane Riviere               --
#-                     Copyright (C) 2003-2005 Bernd Trog                --
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
#-                          AVR-Ada EasyBake Build script                --
#-                                      *                                --
#-  This script  will download,  prepare and build  AVR-Ada without      --
#-  any human interaction and is designed to make the build process      --
#-  easier for beginners and experts alike                               --
#-                                      *                                --
#-  To use simply create a directory and copy this script to it then     --
#-  cd into the directory and type ./build-avr-ada.sh                    --
#-
#-  N.B. This script was written for BASH. If you use another shell      --
#-  invoke with bash ./build-avr-ada.sh                                  --
#-                                                                       --
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Under Windows XP, you need :
#
# MinGW-5.1.6.exe (Windows installer).
# MSYS-1.0.10.exe (Windows installer).
# msysCORE-1.0.11-<latestdate>
# msysDTK-1.0.1.exe (Windows installer).
# flex-2.5.35-MSYS-1.0.11-1
# bison-2.4.2-MSYS-1.0.11-1
# regex-0.12-MSYS-1.0.11-1
# gettext-0.16.1-1
# tar-1.13.19-MSYS-2005.06.08
# autoconf 2.59
# automake 1.8.2
# wget
# cvs
#
#---------------------------------------------------------------------------
#
# $DOWNLOAD  : should point to directory which contains the files
#              specified by : FILE_BINUTILS, FILE_GCC and FILE_LIBC
# $AVR_BUILD : the temporary directory used to build AVR-Ada
# $PREFIX    : the root of the installation directory
# $FILE_...  : filenames of the source distributions without extension
# $BIN_PATCHES : blank separated list of binutils patch files
# $GCC_PATCHES : blank separated list of patch files for gcc
#
#---------------------------------------------------------------------------


BASE_DIR=$PWD
OS=`uname -s`
case "$OS" in
    "Linux" )
        PREFIX="/opt/avr_472_gnat"
        WITHGMP="/usr"
        WITHMPFR="/usr";;
        # line below may be needed to fix Debian multiarch..
        # export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu
    "Darwin" )
        PREFIX="/opt/avr_472_gnat"
        WITHGMP="/opt/local"
        WITHMPFR="/opt/local";;
    * )
        PREFIX="/mingw/avr_472_gnat"
        WITHGMP="/mingw"
        WITHMPFR="/mingw";;
        export PATH=/mingw/local/bin:${PATH}
        export LIBRARY_PATH=/mingw/lib
esac

# add PREFIX/bin to the PATH
# Be sure to have the local directory very late in your PATH, best at the
# very end.
export PATH="${PREFIX}/bin:${PATH}"


VER_BINUTILS=2.20.1
VER_GCC=4.7.2
VER_MPFR=3.1.0
VER_MPC=0.8.2
VER_GMP=4.3.2
VER_LIBC=1.8.0
VER_AVRADA=1.3.0

FILE_BINUTILS="binutils-$VER_BINUTILS"
FILE_GCC="gcc-$VER_GCC"
FILE_MPFR="mpfr-$VER_MPFR"
FILE_MPC="mpc-$VER_MPC"
FILE_GMP="gmp-$VER_GMP"
FILE_LIBC="avr-libc-$VER_LIBC"
FILE_AVRADA="avr-ada-$VER_AVRADA"

BASE_DIR=$PWD
DOWNLOAD="$BASE_DIR/src"
AVR_BUILD="$BASE_DIR/build"

AVRADA_DIR=$AVR_BUILD/avr-ada-$VER_AVRADA/patches
AVRADA_GCC_DIR="$AVRADA_DIR/gcc/$VER_GCC"
AVRADA_BIN_DIR="$AVRADA_DIR/binutils/$VER_BINUTILS"

# To overcome discrepancy beween patches downloaded by current script
# and patches required...
# Modify this below to point to extra patches - or an empty directory
EXTRA_AVRADA_GCC_PATCH_DIR="$BASE_DIR/../$FILE_AVRADA/patches/gcc/$VER_GCC"

# Location of any patches to the AVRAda RTS or library files
AVRADA_PATCH_DIR="$BASE_DIR/../$FILE_AVRADA/patches/avrada/$VER_AVRADA"


# actions:

# Download necessary tarbals and patches using wget and cvs
download_files="no"
delete_obj_dirs="no"
delete_build_dir="yes"
delete_install_dir="yes"
build_binutils="yes"
build_gcc="yes"
build_mpfr="no"
build_mpc="no"
build_gmp="no"
build_libc="yes"
build_avrada="yes"

# The following are advanced options not required for a normal build
# either delete the build directory completely
#
#   delete_build_dir="yes"
#
# or delete only the obj directories.  You probably want to keep the
# extracted and patched sources
#
#   delete_build_dir="no"
#   delete_obj_dirs="yes"
#   no_extract="yes"
#   no_patch="yes"
#

#CC="gcc -mno-cygwin"
CC=gcc
export CC

#echo "Please adjust the variables above to your environment."
#echo "No need to change anything below."
#exit


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

echo "--------------------------------------------------------------"
echo "GCC AVR-Ada build script: all output is saved in log files"
echo "--------------------------------------------------------------"
echo

GCC_VERSION=`$CC -dumpversion`
# GCC_MAJOR=`echo $GCC_VERSION | awk -F. ' { print $1; } '`
# GCC_MINOR=`echo $GCC_VERSION | awk -F. ' { print $2; } '`
# GCC_PATCH=`echo $GCC_VERSION | awk -F. ' { print $3; } '`

if [[ "$GCC_VERSION" < "4.7.0" ]] ; then  # string comparison (?)
    echo "($GCC_VERSION) is too old"
    echo "AVR-Ada V1.3 requires gcc-4.7 as build compiler"
    exit 2
else
    echo "Found native compiler gcc-"$GCC_VERSION
fi

if test "x$delete_build_dir" = "xyes" ; then
    echo
    echo "--------------------------------------------------------------"
    echo "Deleting previous build and source files"
    echo "--------------------------------------------------------------"
    echo

    echo "Deleting :" $AVR_BUILD
    rm -fr $AVR_BUILD

else
    if test "x$delete_obj_dirs" = "xyes" ; then
        echo
        echo "--------------------------------------------------------------"
        echo "Deleting previous obj dirs"
        echo "--------------------------------------------------------------"
        echo

        echo "Deleting :" $AVR_BUILD/binutils-obj
        rm -fr $AVR_BUILD/binutils-obj

        echo "Deleting :" $AVR_BUILD/gcc-obj
        rm -fr $AVR_BUILD/gcc-obj

    fi
fi

mkdir $AVR_BUILD

rm -f $AVR_BUILD/build.sum; touch $AVR_BUILD/build.sum
rm -f $AVR_BUILD/build.log; touch $AVR_BUILD/build.log


if test $delete_install_dir = "yes" ; then
    echo "Deleting :" $PREFIX
    rm -fr $PREFIX
fi


if test "x$download_files" = "xyes" ; then
   #########################################################################
    header "Downloading Files"

    WGET="wget --no-clobber --directory-prefix=$DOWNLOAD"
    if test ! -d $DOWNLOAD ; then
        mkdir -p $DOWNLOAD
    fi

    display "--------------------------------------------------------------"
    display "Downloading Binutils"
    display "--------------------------------------------------------------"
    display
    $WGET "ftp://anonymous:fireftp@mirrors.kernel.org/gnu/binutils/$FILE_BINUTILS.tar.bz2"


    display "--------------------------------------------------------------"
    display "Downloading GCC"
    display "--------------------------------------------------------------"
    display
    $WGET "ftp://anonymous:fireftp@mirrors.kernel.org/gnu/gcc/$FILE_GCC/$FILE_GCC.tar.bz2"


    display "--------------------------------------------------------------"
    display "Downloading GMP"
    display "--------------------------------------------------------------"
    display
    $WGET "ftp://ftp.gnu.org/gnu/gmp/$FILE_GMP.tar.bz2"


    display "--------------------------------------------------------------"
    display "Downloading MPFR"
    display "--------------------------------------------------------------"
    display
    $WGET "http://www.mpfr.org/mpfr-$VER_MPFR/$FILE_MPFR.tar.bz2"


    display "--------------------------------------------------------------"
    display "Downloading MPC"
    display "--------------------------------------------------------------"
    display
    $WGET "http://www.multiprecision.org/mpc/download/$FILE_MPC.tar.gz"


    display "--------------------------------------------------------------"
    display "Downloading AVR-Libc"
    display "--------------------------------------------------------------"
    display
    $WGET "http://savannah.nongnu.org/download/avr-libc/$FILE_LIBC.tar.bz2"


    display "--------------------------------------------------------------"
    display "Downloading AVR-Ada"
    display "--------------------------------------------------------------"
    display
    $WGET "http://downloads.sourceforge.net/avr-ada/$FILE_AVRADA.tar.bz2"

fi
print_time > $AVR_BUILD/time_run.log

#---------------------------------------------------------------------------

#
# unpack AVR-Ada first to get access to the patches
#

cd $AVR_BUILD

display "Extracting $DOWNLOAD/$FILE_AVRADA.tar.bz2 ..."
bunzip2 -c $DOWNLOAD/$FILE_AVRADA.tar.bz2 | tar xf -

#
# set the list of patches after downloading
#
AVRADA_BIN_PATCHES=`(cd $AVRADA_BIN_DIR; ls -1 [0-9][0-9][0-9]-*binutils-*.patch)`
BIN_PATCHES=`echo "$AVRADA_BIN_PATCHES" | sort | uniq`

AVRADA_GCC_PATCHES=`(cd $AVRADA_GCC_DIR; ls -1 [0-9][0-9]-*gcc-*.patch)`
EXTRA_GCC_PATCHES=`(cd $EXTRA_AVRADA_GCC_PATCH_DIR; ls -1 [0-9][0-9]-*gcc-*.patch)`
GCC_PATCHES=`echo "$AVRADA_GCC_PATCHES $EXTRA_GCC_PATCHES" | sort | uniq`

# AVRADA_LIBC_PATCHES=`(cd $AVRADA_LIBC_DIR; ls -1 [0-9][0-9]-*libc-*.patch)`
# LIBC_PATCHES=`echo "$AVRADA_LIBC_PATCHES" | sort | uniq`

#---------------------------------------------------------------------------

cd $AVR_BUILD

#---------------------------------------------------------------------------

if test "x$build_binutils" = "xyes" ; then
   #########################################################################
    header "Building Binutils"

    if test "x$no_extract" != "xyes" ; then
        display "Extracting $DOWNLOAD/$FILE_BINUTILS.tar.bz2 ..."
        bunzip2 -c $DOWNLOAD/$FILE_BINUTILS.tar.bz2 | tar xf -
    fi


    if test "x$no_patch" != "xyes" ; then

        display "patching binutils"

        cd $AVR_BUILD/$FILE_BINUTILS
        for p in $BIN_PATCHES; do
            display "   $p"
            patch --verbose --strip=0 --input=$AVRADA_BIN_DIR/$p  2>&1 >> $AVR_BUILD/build.log
            check_return_code
        done
    fi

    mkdir $AVR_BUILD/binutils-obj

    cd $AVR_BUILD/binutils-obj

    display "Configure binutils ... (log in $AVR_BUILD/step01_bin_configure.log)"

    case "$OS" in
        "Linux" | "Darwin" )
            BINUTILS_OPS=;;
        * )
            BINUTILS_OPS=--build=x86-winnt-mingw32;;
    esac
    ../$FILE_BINUTILS/configure \
        --prefix=$PREFIX \
        --target=avr \
        --disable-nls \
        --enable-doc \
        --disable-werror \
        $BINUTILS_OPS \
        &>$AVR_BUILD/step01_bin_configure.log
    check_return_code


    display "Make binutils bfd-headers ... (log in $AVR_BUILD/step02_bin_make.log)"
    make all-bfd TARGET-bfd=headers &>$AVR_BUILD/step02.0_bin_make_bfd_headers.log
    check_return_code

    rm -f bfd/Makefile
    check_return_code

    make configure-host             &>$AVR_BUILD/step02.1_bin_configure.log
    check_return_code

    make all                        &>$AVR_BUILD/step02.2_bin_make_all.log
    check_return_code

    display "Install binutils ...   (log in $AVR_BUILD/step03_bin_install.log)"

    make install &>$AVR_BUILD/step03_bin_install.log
    check_return_code
fi

#---------------------------------------------------------------------------

if test "$build_gcc" = "yes" ; then
    #########################################################################
    header "Building gcc cross compiler for AVR"

    cd $AVR_BUILD

    if test "x$no_extract" != "xyes" ; then
        display "Extracting $DOWNLOAD/$FILE_GCC.tar.bz2 ..."
        bunzip2 -c $DOWNLOAD/$FILE_GCC.tar.bz2 | tar xf -

	if test "x$build_mpfr" = "xyes" ; then
            bunzip2 -c $DOWNLOAD/$FILE_MPFR.tar.bz2 | \
		(cd $FILE_GCC; tar xf -; mv $FILE_MPFR mpfr)
	else
	    GCC_OPS="$GCC_OPS --with-mpfr=$WITHMPFR"
	fi
	if test "x$build_mpc" = "xyes" ; then
            gunzip -c $DOWNLOAD/$FILE_MPC.tar.gz | \
		(cd $FILE_GCC; tar xf -; mv $FILE_MPC mpc)
	else
	    GCC_OPS="$GCC_OPS --with-mpc=$PREFIX"
	fi
	if test "x$build_gmp" = "xyes" ; then
            bunzip2 -c $DOWNLOAD/$FILE_GMP.tar.bz2 | \
		(cd $FILE_GCC; tar xf -; mv $FILE_GMP gmp)
	else
	    GCC_OPS="$GCC_OPS --with-gmp=$WITHGMP"
	fi
    fi


    if test x$no_patch = "xyes" ; then
        true
        # do nothing
    else
        display "patching gcc"

        cd $AVR_BUILD/$FILE_GCC
        for p in $GCC_PATCHES; do
            display "   $p"
            if test -f $AVRADA_GCC_DIR/$p ; then
                PDIR=$AVRADA_GCC_DIR
            elif test -f $EXTRA_AVRADA_GCC_PATCH_DIR/$p ; then
                PDIR=$EXTRA_AVRADA_GCC_PATCH_DIR
            else
                display "cannot find $p in any of the patch directories"
                exit 2
            fi
            patch --verbose --strip=0 --input=$PDIR/$p  2>&1 >> $AVR_BUILD/build.log
            check_return_code
        done
    fi

    mkdir $AVR_BUILD/gcc-obj
    cd $AVR_BUILD/gcc-obj

    display "Configure GCC-AVR ... (log in $AVR_BUILD/step04_gcc_configure.log)"

    echo "AVR-Ada V$VER_AVRADA" > ../$FILE_GCC/gcc/PKGVERSION

    ../$FILE_GCC/configure --prefix=$PREFIX \
        --target=avr \
        --enable-languages=ada,c,c++ \
        --with-dwarf2 \
        --disable-nls \
        --disable-libssp \
        --disable-libada \
        --with-bugurl=http://avr-ada.sourceforge.net \
	--with-gmp=$WITHGMP \
	--with-mpfr=$WITHMPFR \
        &>$AVR_BUILD/step04_gcc_configure.log
    check_return_code

    if test "$build_gmp" = "yes" ; then
        display "Make GMP ...          (log in $AVR_BUILD/step05.1_gcc_gmp.log)"

        make all-gmp &> $AVR_BUILD/step05.1_gcc_gmp.log
        check_return_code

        display "Install GMP ...       (log in $AVR_BUILD/step05.1_install_gmp.log)"
 
        make -C gmp install &> $AVR_BUILD/step05.1_install_gmp.log
        check_return_code
    fi

    if test "$build_mpfr" = "yes" ; then
        display "Make MPFR ...         (log in $AVR_BUILD/step05.2_gcc_mpfr.log)"

        make all-mpfr &> $AVR_BUILD/step05.2_gcc_mpfr.log
        check_return_code

        display "Install MPFR ...      (log in $AVR_BUILD/step05.2_install_mpfr.log)"

        make -C mpfr install &> $AVR_BUILD/step05.2_install_mpfr.log
        check_return_code
    fi

    display "Make GCC ...          (log in $AVR_BUILD/step05_gcc_gcc_obj.log)"

    make &> $AVR_BUILD/step05_gcc_gcc_obj.log
    check_return_code

    display "Install GCC ...       (log in $AVR_BUILD/step08_gcc_install.log)"

    cd $AVR_BUILD/gcc-obj
    make install &>$AVR_BUILD/step08_gcc_install.log
    check_return_code
fi

#---------------------------------------------------------------------------

if test "x$build_libc" = "xyes" ; then
    #########################################################################
    header "Building AVR libc"

    cd $AVR_BUILD

    if test "x$no_extract" != "xyes" ; then
        display "Extracting $DOWNLOAD/$FILE_LIBC.tar.bz2 ..."
        bunzip2 -c $DOWNLOAD/$FILE_LIBC.tar.bz2 | tar xf -
    fi

    cd $AVR_BUILD/$FILE_LIBC

    display "configure AVR-LIBC ... (log in $AVR_BUILD/step09_libc_conf.log)"
    CC="avr-gcc -v" ./configure --build=`./config.guess` --host=avr --prefix=$PREFIX &>$AVR_BUILD/step09_libc_conf.log
    check_return_code

    display "Make AVR-LIBC ...       (log in $AVR_BUILD/step10_libc_make.log)"
    make &>$AVR_BUILD/step10_libc_make.log
    check_return_code

    display "Install AVR-LIBC ...    (log in $AVR_BUILD/step11_libc_install.log)"
    make install &>$AVR_BUILD/step11_libc_install.log
    check_return_code
fi
print_time >> $AVR_BUILD/time_run.log

#---------------------------------------------------------------------------

if test "x$build_avradarts" = "xyes" ; then
    #########################################################################
    header "Building AVR-Ada RTS"

    cd $AVR_BUILD

    if test "x$no_extract" != "xyes" ; then
        display "Extracting $DOWNLOAD/$FILE_AVRADA.tar.bz2 ..."
        bunzip2 -c $DOWNLOAD/$FILE_AVRADA.tar.bz2 | tar xf -
    fi

    cd $AVR_BUILD/$FILE_AVRADA

    display "configure AVR-Ada ... (log in $AVR_BUILD/step12_avrada_conf.log)"
    ./configure >& ../step12_avrada_conf.log
    check_return_code

    display "build AVR-Ada RTS ... (log in $AVR_BUILD/step13_avrada_rts.log)"
    make build_rts >& ../step13_avrada_rts.log
    check_return_code
    make install_rts >& ../step13_avrada_rts_inst.log
    check_return_code
fi

if test "x$build_avrada" = "xyes" ; then
    #########################################################################
    header "Building AVR-Ada libraries"

    cd $AVR_BUILD/$FILE_AVRADA

    display "build AVR-Ada libs ... (log in $AVR_BUILD/step14_avrada_libs.log)"
    make build_libs >& ../step14_avrada_libs.log
    check_return_code
    make install_libs >& ../step14_avrada_libs_inst.log
    check_return_code
fi

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
