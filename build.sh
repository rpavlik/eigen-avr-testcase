#!/bin/sh -e
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


CC="${AVRTOOLDIR}/avr-gcc"
AR="${AVRTOOLDIR}/avr-ar"
OBJDUMP="${AVRTOOLDIR}/avr-objdump"
MYDIR=$(dirname $(readlink -f "$0"))
OBJDIR="${MYDIR}/build"
mkdir -p ${OBJDIR}
INCLUDES="-I${ARDUINODIR}/hardware/arduino/cores/arduino
         -I${ARDUINODIR}/hardware/arduino/variants/standard
         -I${MYDIR}/libraries/StandardCplusplus
         -I${MYDIR}/libraries/Eigen30"
DEFINES="-DF_CPU=16000000L
        -DARDUINO=${ARDUINO_VER}
        -DUSB_VID=null
        -DUSB_PID=null"

SHAREDFLAGS="-c
			-g
			-Wall
            -ffunction-sections
            -fdata-sections
            -mmcu=atmega328p
            ${DEFINES}
            ${INCLUDES}"

CXXFLAGS="-fno-exceptions"
LIBS=${MYDIR}/core.a
LINKFLAGS="-g -mmcu=atmega328p -Wl,--gc-sections -lm"

# Build the libraries
if [ ! -f ${MYDIR}/core.a ]; then
	templib=${OBJDIR}/core.a
	for fn in ${ARDUINODIR}/hardware/arduino/cores/arduino/*.c*; do
		outname=${OBJDIR}/$(basename $fn).o
		if [ "$(basename $fn .cpp)" = "$(basename $fn)" ]; then
			#couldn't remove .cpp, so it's a c file.
			${CC} -Os ${SHAREDFLAGS} $fn -o $outname
		else
			${CXX} -Os ${CXXFLAGS} ${SHAREDFLAGS} $fn -o $outname
		fi
		${AR} rcs ${templib} ${outname}
	done
	cp ${templib} ${MYDIR}/core.a
fi

build_and_disasm() {
	NAME=build_with_$1
	OPT=-${1}
	echo
	echo ----------------------- Building with ${OPT}
	echo
	echo ${CXX} ${OPT} ${SHAREDFLAGS}  ${MYDIR}/main.cpp -o ${OBJDIR}/${NAME}.o
	echo
	${CXX} ${OPT} ${SHAREDFLAGS}  ${MYDIR}/main.cpp -o ${OBJDIR}/${NAME}.o && \
	${CXX} ${OPT} ${LINKFLAGS} ${OBJDIR}/${NAME}.o -o ${OBJDIR}/${NAME}.elf ${LIBS} &&
	${OBJDUMP} -d -S --line-numbers ${OBJDIR}/${NAME}.elf > ${MYDIR}/${NAME}.S
}

if [ "x$1" = "x" ]; then
	build_and_disasm O1 && \
	build_and_disasm Os && \
	build_and_disasm O2
else
	build_and_disasm $1
fi

