#!/bin/sh 
#set -x
#
# Pre-requisites: 
#  - cd to the directory of this script before running the script   
#  - ensure you have sourced setenv.sh, e.g. . ./setenv.sh
#  - ensure you have GNU make installed (4.1 or later)
#  - ensure you have access to c99
#  - network connectivity to pull git source from org
#
if [ "${PERL_ROOT}" = '' ]; then
	echo "Need to set PERL_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${PERL_VRM}" = '' ]; then
	echo "Need to set PERL_VRM - source setenv.sh" >&2
	exit 16
fi

make --version >/dev/null 2>&1 
if [ $? -gt 0 ]; then
	echo "You need GNU Make on your PATH in order to build PERL" >&2
	exit 16
fi

whence c99 >/dev/null
if [ $? -gt 0 ]; then
	echo "c99 required to build PERL. " >&2
	exit 16
fi

if ! [ -d perl5 ]; then
	git clone https://github.com/Perl/perl5.git --branch "${PERL_VRM}" --single-branch --depth 1 
fi

MY_ROOT="${PWD}"

cd perl5
chtag -R -h -t -cISO8859-1 "${MY_ROOT}/perl5"
if [ $? -gt 0 ]; then
	echo "Unable to tag PERL directory tree as ASCII" >&2
	exit 16
fi

#
# Apply patches
# To create a new patch:
# cd to perl5 directory
# copy original file in perl5 directory to: <file>.orig
# diff -C 2 -f <file>.c <file>.orig >../patches/<file>.patch  
#
if [ "${PERL_VRM}" = "maint-5.34" ]; then
	# Copy files to 'orig' version if not already copied
	# otherwise restore so that this step can be repeated
	if ! [ -f doio.c.orig ]; then
		cp doio.c doio.c.orig
	else
		
	fi

	patch -c doio.c <${MY_ROOT}/patches/doio.patch
	if [ $? -gt 0 ]; then
  		echo "Patch of perl tree failed (doio.c)." >&2
                exit 16
	fi      
	patch -c iperlsys.h <${MY_ROOT}/patches/iperlsys.patch
  	if [ $? -gt 0 ]; then
                echo "Patch of perl tree failed (iperlsys.h)." >&2
                exit 16
        fi      
	patch -R -c hints/os390.sh <${MY_ROOT}/patches/os390.patch
  	if [ $? -gt 0 ]; then
                echo "Patch of perl tree failed (hints/os390.sh)." >&2
                exit 16
        fi      
	patch -c cpan/Perl-OSType/lib/Perl/OSType.pm <${MY_ROOT}/patches/OSType.patch
  	if [ $? -gt 0 ]; then
                echo "Patch of perl tree failed (cpan/Perl-OSType/lib/Perl/OSType.pm)." >&2
                exit 16
        fi      
fi  

#
# Setup the configuration 
#
sh Configure -de
if [ $? -gt 0 ]; then
	echo "Configure of PERL tree failed." >&2
	exit 16
fi

make
if [ $? -gt 0 ]; then
	echo "MAKE of PERL tree failed." >&2
	exit 16
fi


cd "${DELTA_ROOT}/tests"
export PATH="${PERL_ROOT}/${PERL_VRM}/src:${PATH}"

./runbasic.sh
if [ $? -gt 0 ]; then
	echo "Basic test of PERL failed." >&2
	exit 16
fi
./runexamples.sh
if [ $? -gt 0 ]; then
	echo "Example tests of PERL failed." >&2
	exit 16
fi
exit 0
