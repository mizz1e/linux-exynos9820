#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Check ncurses compatibility

# What library to link
ldflags()
{
	pkg-config --libs ncursesw 2>/dev/null && exit
	pkg-config --libs ncurses 2>/dev/null && exit
	for ext in so a dll.a dylib ; do
		for lib in ncursesw ncurses curses ; do
			$cc -print-file-name=lib${lib}.${ext} | grep -q /
			if [ $? -eq 0 ]; then
				echo "-l${lib}"
				exit
			fi
		done
	done
	exit 1

	echo "-l"
}

# Where is ncurses.h?
ccflags()
{
	echo '-DCURSES_LOC="<curses.h>"'
}

# Temp file, try to clean up after us
tmp=.lxdialog.tmp
trap "rm -f $tmp" 0 1 2 3 15

# Check if we can link to ncurses
check() {
        $cc -std=c89 -DCURSES_LOC="<curses.h>"  -x c - -o $tmp 2>/dev/null <<'EOF'
#include CURSES_LOC
main() {}
EOF
	if [ $? != 0 ]; then
	    echo " *** Unable to find the ncurses libraries or the"       1>&2
	    echo " *** required header files."                            1>&2
	    echo " *** 'make menuconfig' requires the ncurses libraries." 1>&2
	    echo " *** "                                                  1>&2
	    echo " *** Install ncurses (ncurses-devel) and try again."    1>&2
	    echo " *** "                                                  1>&2
	    exit 1
	fi
}

usage() {
	printf "Usage: $0 [-check compiler options|-ccflags|-ldflags compiler options]\n"
}

if [ $# -eq 0 ]; then
	usage
	exit 1
fi

cc=""
case "$1" in
	"-check")
		shift
		cc="$@"
		check
		;;
	"-ccflags")
		ccflags
		;;
	"-ldflags")
		shift
		cc="$@"
		ldflags
		;;
	"*")
		usage
		exit 1
		;;
esac
