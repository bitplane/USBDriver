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
# Make file for RISC OS port of NetBSD USB code
# 
# This makefile generates the main USBDriver and the controller drivers
# by including the relevant object file.

TARGET          = ${COMPONENT}
DIRS            = o._dirs
MSGLOC          = Resources.${COMPONENT}.Messages
DEVICELIST      = Resources.<Locale>.USBDevs
LIBS            = ${DEBUGLIB} ${NET5LIBS} ${CALLXLIB} ${ASMUTILS} ${TBOXLIBS}
RDIR            = ${RESDIR}.${COMPONENT}

CINCLUDES       = -Itbox:,TCPIPLibs:,^.,OS:
CDEFINES        += ${CDEBUG} -DKERNEL -Dpaddr_t=int -D__P(A)=A -DKLD_MODULE
CMHGINCLUDES    = ${CINCLUDES}
CMHGDEFINES     = -DMSGLOC=${MSGLOC} ${CDEBUG}
CFLAGS          += -ff -wp -wc -zm -zps1
LDFLAGS         = -LIST maps.${TARGET} -MAP -Xref

VPATH = ^.build ^.dev.usb

include OBJ${COMPONENT}

include StdTools
include ModStdRule
#MODSQZ = echo not squeezing... 
include ModuleLibs
include RAMCModule
include ROMCModule

clean:
        ${WIPE} o      ${WFLAGS}
        ${WIPE} aif    ${WFLAGS}
        ${WIPE} aof    ${WFLAGS}
        ${WIPE} rm     ${WFLAGS}
        ${WIPE} i      ${WFLAGS}
        ${WIPE} maps   ${WFLAGS}
        ${WIPE} gpa    ${WFLAGS}
        ${WIPE} bin    ${WFLAGS}
        ${WIPE} linked ${WFLAGS}
        ${RM}   h.ohcimodhead
        ${RM}   h.usbmodhead
        ${RM}   Resources.UK.USBDevs

all: o._dirs

resources: resources_${COMPONENT}

resources_OHCIDriver: LocalRes:OHCIMessages
        ${MKDIR} ${RDIR}
        ${CP} LocalRes:OHCIMessages ${RDIR}.Messages ${CPFLAGS}
        @echo ${COMPONENT}: resource files copied

resources_USBDriver: LocalRes:USBDriver ${DEVICELIST}
        ${MKDIR} ${RDIR}
        ${CP} LocalRes:USBMessages ${RDIR}.Messages ${CPFLAGS}
        ${CP} ${DEVICELIST} ${RDIR}.USBDevs ${CPFLAGS}
        @echo ${COMPONENT}: resource files copied

o._dirs:
        ${MKDIR} o
        ${MKDIR} aif
        ${MKDIR} aof
        ${MKDIR} rm
        ${MKDIR} i
        ${MKDIR} maps
        ${MKDIR} gpa
        ${MKDIR} bin
        ${TOUCH} o._dirs

ohcimodule.o:   ohcimodhead.h USBDriver.h
usbmodule.o usbkboard.o:        usbmodhead.h

Resources.<Locale>.USBDevs: bin.makedevs
        bin.makedevs > Resources.UK.USBDevs

# Remove the usbmodhead after creating the SWI table because if OHCIDriver
# makes it then it has the wrong messages file in it
USBDriver.h: usbmodhead.h
        ${SED} -n "/define USBDriver_/p" h.usbmodhead > h.USBDriver
        ${RM}   h.usbmodhead
        ${RM}   o.usbmodhead

bin.makedevs: o.makedevs ${CLIB} ${DIRS}
        ${LD} -o $@ o.makedevs ${CLIB}

usbmsgs.o: Resources.UK.USBMessages Resources.UK.USBDevs
        resgen resource_files o.usbmsgs Resources.UK.USBMessages ${MSGLOC} Resources.UK.USBDevs Resources.USBDriver.USBDevs

ohcimsgs.o: Resources.UK.OHCIMessages
        resgen resource_files o.ohcimsgs Resources.UK.OHCIMessages ${MSGLOC}

# RISC OS debug:
aif.${COMPONENT}: ${RAM_OBJS} ${RAM_LIBS} ${CLIB} ${DIRS}
        link -base 0 -aif -bin -d -o $@ ${RAM_OBJS} ${RAM_LIBS} ${CLIB}

gpa.${COMPONENT}: aif.${COMPONENT}
        togpa -s aif.${COMPONENT} $@

debug: gpa.${COMPONENT} ${DIRS}

.SUFFIXES: .i

.c.i:;  ${CC} -E ${CFLAGS} $< > $@

listing: i.ohci i.ohcimodule i.usb i.usbdi i.usbdi_util i.usb_subr i.ugen i.usbmodule


# Dynamic dependencies:
