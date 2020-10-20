#!/bin/bash 
#-ex

#  pack.*.bash - Bash script to help packaging samd core releases.
#  Copyright (c) 2015 Arduino LLC.  All right reserved.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

source ./extras/versions.sh

VERSION=$ENERGIA_VER
echo $VERSION

PWD=`pwd`
FOLDERNAME=`basename $PWD`
echo $FOLDERNAME
THIS_SCRIPT_NAME=`basename $0`

rm -f extras/build/cores/msp430elf-$VERSION.tar.bz2
rm -f extras/build/cores/msp430elf-$VERSION.tar.bz2.sha256

#filter board.txt and platform.txt
sed -r s/version=xxx/version=$VERSION/ platform.txt.template | sed -r s/dslite-xxx/dslite-$DSLITE_VER/ > platform.txt
sed -z 's/[0-9]+\s*[\n\r]+[^\.]+\.upload\.maximum_size_ext=//g' boards.txt > boards.txt.elfgcc

cd ..
tar --transform "s|$FOLDERNAME|msp430elf-$VERSION|g" --transform "s|boards.txt.elfgcc|boards.txt|g" --exclude=*.sha256 --exclude=*.bz2 --exclude=platform.txt.oldgcc --exclude=platform.txt.template --exclude=boards.txt --exclude=extras --exclude=.git* --exclude=.idea -cjf msp430elf-$VERSION.tar.bz2 $FOLDERNAME
cd -
rm boards.txt.elfgcc

[ -d "extras/build" ] || mkdir extras/build 
[ -d "extras/build/cores" ] || mkdir extras/build/cores 
mv ../msp430elf-$VERSION.tar.bz2 ./extras/build/cores

cd extras/build/cores
if [ "$(expr substr $(uname -s) 1 6)" == "CYGWIN" ]; then
	sha256sum msp430elf-$VERSION.tar.bz2 > msp430elf-$VERSION.tar.bz2.sha256
else
	shasum -a 256 msp430elf-$VERSION.tar.bz2 > msp430elf-$VERSION.tar.bz2.sha256
fi

cd ../../..
#stat -f -c %z msp430elf-$VERSION.tar.bz2
