# Copyright 2003 Tematic Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Makefile for USBDriver
#

COMPONENT       = USBDriver
UNAME           = "RISC_OS"
VPATH           = build dev/usb machine sys
HDRS            = USBDevFS usb usbdi usbdivar usb_port device bus usbdevs queue uio
ASMHDRS         = USBDriver
ASMCHDRS        = USBDriver
CMHGAUTOHDR     = USBDriver
CURDIR         ?= USBDriver
LIBDIR         ?= <Lib$Dir>
C_EXP_HDR       = ${LIBDIR}${SEP}USB
DEVICELIST      = Resources${SEP}${LOCALE}${SEP}USBDevs
CUSTOMEXP       = custom
CINCLUDES       = ${TBOXINC} ${TCPIPINC} ${OSINC} ${USBINC}
CDEFINES       += ${CDEBUG} -DKERNEL -D_KERNEL "-D__P(A)=A" -DKLD_MODULE -DDISABLE_PACKED
RES_AREA        = resource_files
LIBS            = ${CALLXLIB} ${ASMUTILS}
CMHGDEPENDS     = usbmouse usbmodule usbkboard
INSTRES_FILES   = USBDevs
INSTRES_DEPENDS = ${DEVICELIST}
OBJS            = usbmodule port usb usbdi usb_subr \
                  usbdi_util usb_quirks uhub usbmouse usbkboard \
                  hid bufman triggercbs call_veneer
CFLAGS          = ${C_NOWARN_NON_ANSI_INCLUDES}

ifeq (${TOOLCHAIN},GNU)
CDEFINES       += -D_BSD_SOURCE -D_POSIX_PATH_MAX=1024
CFLAGS         += -idirafter ${LIBDIR}/TCPIPLibs -include sys/types.h
BSD_USB_OBJS    = usb usbdi usb_subr usbdi_util usb_quirks uhub usbmouse usbkboard hid bufman triggercbs port
${BSD_USB_OBJS:%=%.o}: CFLAGS += -I${LIBDIR}/TCPIPLibs -include ../gnu_compat.h -include ${LIBDIR}/TCPIPLibs/sys/param.h -include ${LIBDIR}/TCPIPLibs/sys/signal.h -include ./sys/uio.h
endif

SOURCES_TO_SYMLINK = $(wildcard build/c/*) $(wildcard build/cmhg/*) $(wildcard build/h/*) build//makedevs.mk $(wildcard build/s/*) $(wildcard dev/usb/c/*) dev/usb//devlist2h.awk $(wildcard dev/usb/h/*) dev/usb//usbdevs $(wildcard machine/h/*) $(wildcard sys/h/*)

#
# Debug switch
#
DEBUG ?= FALSE
ifeq (${DEBUG},TRUE)
CFLAGS         += -DUSB_DEBUG -DDEBUGLIB
CMHGDEFINES    += -DUSB_DEBUG
LIBS           += ${DEBUGLIBS} ${NET5LIBS}
endif

include CModule

#
# Produce the devices list
#
makedevs:
	${MAKE} -f build${SEP}makedevs${EXT}mk COMPONENT=makedevs TARGET=makedevs THROWBACK=${THROWBACK}

${DEVICELIST}: dev/usb/usbdevs.h makedevs dev/usb/usbdevs.h dev/usb/usbdevs_data.h
	${RUN}makedevs > $@

dev/usb/usbdevs.h dev/usb/usbdevs_data.h: dev/usb/usbdevs
	${GAWK} -v os=${UNAME} -v curdir=$(notdir ${CURDIR}) -f dev${SEP}usb${SEP}devlist2h${EXT}awk dev${SEP}usb${SEP}usbdevs

ifeq (,${MAKE_VERSION})

# RISC OS / amu case

create_exp_dirs:
	${MKDIR} ${C_EXP_HDR}.h
	${MKDIR} ${C_EXP_HDR}.dev.usb.h
	${MKDIR} ${C_EXP_HDR}.machine.h
	${MKDIR} ${C_EXP_HDR}.sys.h

export_hdrs_custom: ${EXPORTING_ASMCHDRS} ${EXPORTING_ASMHDRS} ${EXPORTING_HDRS} create_exp_dirs
	${CP} ${C_EXP_HDR}.h.USBDriver <CExport$Dir>.Interface.h.USBDriver ${CPFLAGS}
	${RM} ${C_EXP_HDR}.h.USBDriver
	${CP} VersionNum ${C_EXP_HDR}.LibVersion ${CPFLAGS}
	@${ECHO} ${COMPONENT}: header export complete

export_libs_custom:
	@${NOP}

exphdr.usbdevs: dev/usb/usbdevs.h
	${CP} dev.usb.h.$* ${C_EXP_HDR}.dev.usb.h.$* ${CPFLAGS}

clean::
	${RM} ${DEVICELIST}
	${RM} dev.usb.h.usbdevs
	${RM} dev.usb.h.usbdevs_data
	${MAKE} -f build.makedevs/mk clean COMPONENT=makedevs
	${STRIPDEPEND} build.makedevs/mk

else

# Posix / gmake case

ifeq (objs,$(notdir ${CURDIR}))

create_exp_dirs:
	${MKDIR} ${C_EXP_HDR}/dev/usb
	${MKDIR} ${C_EXP_HDR}/machine
	${MKDIR} ${C_EXP_HDR}/sys

export_hdrs_custom: create_exp_dirs ${EXPORTING_HDRS} ${EXPORTING_ASMHDRS} ${EXPORTING_ASMCHDRS}
	${CP} ${C_EXP_HDR}/USBDriver.h ${CEXPORTDIR}/Interface/USBDriver.h
	${RM} ${C_EXP_HDR}/USBDriver.h
	${CP} ../gnu_compat.h ${C_EXP_HDR}/gnu_compat.h
	${CP} VersionNum ${C_EXP_HDR}/LibVersion
	@${ECHO} ${COMPONENT}: header export complete

export_libs_custom:
	@${NOP}

endif
endif

# Dynamic dependencies:
