#!/bin/sh
# You may need to change this.

ARDUINODIR="/usr/share/arduino"
AVRTOOLDIR="$(dirname $(which avr-gcc))"
# Probably autodetected below.
ARDUINO_VER=

if [ ! -d "${ARDUINODIR}" ]; then
	echo "Please modify ARDUINODIR in the script."
	exit 1
fi

CXX="${AVRTOOLDIR}/avr-g++"

if [ ! -x "${CXX}" ]; then
	echo "Can't find AVR-GCC toolchain - might need to set AVRTOOLDIR in script"
	exit 1
fi

if [ "x${ARDUINO_VER}" = "x" ] ; then
	case "$(cat ${ARDUINODIR}/lib/version.txt)" in
		1.0)
			ARDUINO_VER=100
			;;
		1.0.1)
			ARDUINO_VER=101
			;;
		*)
			echo "Could not guess ARDUINO_VER - please set it!"
			exit 1
			;;
	esac
fi

OBJDUMP="${AVRTOOLDIR}/avr-objdump"
MYDIR=$(dirname $(readlink -f "$0"))
INCLUDES="-I${ARDUINODIR}/hardware/arduino/cores/arduino
         -I${ARDUINODIR}/hardware/arduino/variants/standard
         -I${MYDIR}/libraries/StandardCplusplus
         -I${MYDIR}/libraries/Eigen30"
DEFINES="-DF_CPU=16000000L
        -DARDUINO=${ARDUINO_VER}
        -DUSB_VID=null
        -DUSB_PID=null"

SHAREDFLAGS="-Wall
            -ffunction-sections
            -fdata-sections
            -fno-exceptions
            -mmcu=atmega328p
            ${DEFINES}
            ${INCLUDES}"

build_and_disasm() {
	NAME=$1
	OPT=-${1}
	echo
	echo ----------------------- Building with ${OPT}
	
	set -x verbose
	${CXX} -c -g ${OPT} ${SHAREDFLAGS}  ${MYDIR}/main.cpp -o ${NAME}.o && \
	${OBJDUMP} -d -S --line-numbers ${NAME}.o > ${NAME}.S
}

if [ "x$1" = "x" ]; then
	build_and_disasm O1 && \
	build_and_disasm Os && \
	build_and_disasm O2
else
	build_and_disasm $1
fi

