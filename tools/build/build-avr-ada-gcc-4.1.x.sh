#!/bin/sh
 
#--------------------------------------------------------------------------
#-                AVR-Ada - A GCC Ada environment for AVR-Atmel          --
#-                                      *                                --
#-                                 AVR-Ada 0.6                           --
#-                     Copyright (C) 2003-2006 Bernd Trog               --
#-                     Copyright (C) 2005 Stephane Riviere               --
#-                        Copyright (C) 2005 Rolf Ebert                  --
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
 

# $DOWNLOAD         : should point to directory which contains the files
#                     specified by : FILE_BINUTILS, FILE_GCC and FILE_AVR_LIBC
# $AVR_BUILD        : the temporary directory used to build AVR-Ada
# $PREFIX           : the root of the installation directory
# $AVR_ADA_HOME     : AVR-Ada's home (avr/ rts/ patches/ etc.)
# $PATCH_DIR        : the directory containing patches
# $FILE_EXT         : choose "tar.gz", "tgz" or "tar.bz2" (lower case mandatory)
# $FILE_...         : filenames of the source distributions without extension
# $BINUTILS_PATCHES : blank separated list of binutils patch files (which 
#                     reside in the $PATCH_DIR) 
# $GCC_PATCHES      : blank separated list of patch files for gcc
#
#---------------------------------------------------------------------------
 
FILE_EXT=tar.bz2
FILE_BINUTILS=binutils-2.16
FILE_GCC=gcc-4.1.1

FILE_AVR_LIBC=avr-libc-1.4.4

DOWNLOAD=/src/dl
AVR_BUILD=/src/build/avr-$FILE_GCC
PREFIX=/src/install/avr-ada-$FILE_GCC
AVR_ADA_HOME=/src/source/avr-ada
PATCH_DIR=$AVR_ADA_HOME/patches

BINUTILS_PATCHES="binutils-2.16-avr.sc.patch binutils-2.16-avr-new-devs3.patch"
GCC_PATCHES=`(cd $PATCH_DIR; ls gcc-4.1-*.patch)`

# actions:
delete_build_dir="yes"
delete_install_dir="yes"
build_binutils="yes"
build_gcc="yes"
build_libc="yes"
build_avrada="yes"


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
 
echo "Please adjust this file to your environment before launching it again."

exit
 


echo "--------------------------------------------------------------"
echo "GCC AVR-Ada build script: all output is saved in log files"
echo "--------------------------------------------------------------"
echo


GCC_VERSION=`gcc -dumpversion`
GCC_MAJOR=`echo $GCC_VERSION | awk -F. ' { print $1; } '`
GCC_MINOR=`echo $GCC_VERSION | awk -F. ' { print $2; } '`
GCC_PATCH=`echo $GCC_VERSION | awk -F. ' { print $3; } '`
 
if [ $GCC_MAJOR -lt 4 ] ; then
    echo "($version) **** too old ****"
    echo "AVR-Ada requires gcc-4.1.0 or newer"
    exit 2
elif [ $GCC_MAJOR -eq 4 ] ; then
    if [ $GCC_MINOR -lt 1 ] ; then
        echo "($version) **** too old ****"
        echo "AVR-Ada requires gcc-4.1.0 or newer"
        exit 2
    fi
fi

echo "Found native compiler gcc-"$GCC_VERSION
 
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
       patch --verbose --strip=1 --input=$PATCH_DIR/$p  2>&1 >> $AVR_BUILD/build.log
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
 
   make -j3 &>$AVR_BUILD/step02_bin_make.log 
   check_return_code
 
   display "Install binutils ...   (log in $AVR_BUILD/step03_bin_install.log)"
 
   make install &>$AVR_BUILD/step03_bin_install.log
   check_return_code
fi
 
export PATH=$PREFIX/bin:$PATH
 
if test $build_gcc = "yes" ; then
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
	patch --verbose --strip=1 --input=$PATCH_DIR/$p  2>&1 >> $AVR_BUILD/build.log
        check_return_code
    done
 
 
    mkdir $AVR_BUILD/gcc-obj
    cd $AVR_BUILD/gcc-obj
 
    display "Configure GCC-AVR ... (log in $AVR_BUILD/step04_gcc_configure.log)"
 
    ../$FILE_GCC/configure --prefix=$PREFIX \
	--target=avr \
	--enable-languages=ada,c,c++ \
	--with-dwarf2 \
	--disable-nls \
	--disable-fixincludes \
	--disable-libssp \
	--disable-libada \
	--with-gnu-ld \
	--with-gnu-as \
	&>$AVR_BUILD/step04_gcc_configure.log
    check_return_code

    display "Make GCC ...          (log in $AVR_BUILD/step05_gcc_gcc_obj.log)"
 
    make &> $AVR_BUILD/step05_gcc_make.log
    check_return_code
 
    display "Install GCC ...       (log in $AVR_BUILD/step06_gcc_install.log)"
 
    cd $AVR_BUILD/gcc-obj
    make install &>$AVR_BUILD/step06_gcc_install.log
    check_return_code
fi
 
 
if test $build_libc = "yes" ; then
    header "Building AVR libc"
 
    cd $AVR_BUILD
 
    display "Extracting $DOWNLOAD/$FILE_AVR_LIBC.$FILE_EXT ..."
    if test "$FILE_EXT" = "tar.bz2" ; then
	tar xjf $DOWNLOAD/$FILE_AVR_LIBC.$FILE_EXT
    else
	tar xzf $DOWNLOAD/$FILE_AVR_LIBC.$FILE_EXT
    fi
 
 
    cd $AVR_BUILD/$FILE_AVR_LIBC

    display "configure AVR-LIBC ... (log in $AVR_BUILD/step07_libc_conf.log)"
    CC=avr-gcc ./configure --build=`./config.guess` --host=avr \
      --prefix=$PREFIX &>$AVR_BUILD/step07_libc_conf.log
    check_return_code

    display "Make AVR-LIBC ... (log in $AVR_BUILD/step08_libc_make.log)"
    make &>$AVR_BUILD/step08_libc_make.log
    check_return_code

    display "Install AVR-LIBC ... (log in $AVR_BUILD/step09_libc_install.log)"
    make install &>$AVR_BUILD/step09_libc_install.log
    check_return_code
fi
 

if test $build_avrada = "yes" ; then
    header "Building AVR Ada"
 
    cd $AVR_BUILD
 
    display "Coping $AVR_ADA_HOME ..."
    cp -a $AVR_ADA_HOME $AVR_BUILD
    cd $AVR_BUILD/avr-ada*

    display "configure AVR-Ada ... (log in $AVR_BUILD/step10_avr_ada_conf.log)"

    display "Make AVR-Ada ... (log in $AVR_BUILD/step11_avr_ada_make.log)"
    make &>$AVR_BUILD/step11_avr_ada_make.log
    check_return_code

    display "Install AVR-Ada ... (log in $AVR_BUILD/step12_avr_ada_install.log)"
    make install &>$AVR_BUILD/step12_avr_ada_install.log
    check_return_code
fi
 
#---------------------------------------------------------------------------
 
print_time >> $AVR_BUILD/time_run.log

cd ..
 
header  "Build end"
 
display
display "Build logs are located in $AVR_BUILD"
display "Programs are in the $PREFIX hierarchy"
display "You may remove $AVR_BUILD directory"
 
#---------------------------------------------------------------------------
# eof
#---------------------------------------------------------------------------
