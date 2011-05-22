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
#LIBS		= ${DEBUGLIB} ${NET5LIBS} ${CALLXLIB} ${ASMUTILS} ${TBOXLIBS}
LIBS            = ${DEBUGLIB} ${MODMALLOCLIB} ${WILDLIB} ${DDTLIB} ${DESKLIB}  ${NET5LIBS} ${CALLXLIB} ${ASMUTILS} ${TBOXLIBS}
RDIR            = ${RESDIR}.${COMPONENT}
USBDIR          = <Lib$Dir>.USB

CINCLUDES       = -Itbox:,TCPIPLibs:,^.,OS:
CDEFINES        += ${CDEBUG} -DKERNEL -D_KERNEL -Dpaddr_t=int -D__P(A)=A -DKLD_MODULE -DDISABLE_PACKED
CMHGINCLUDES    = ${CINCLUDES}
CMHGDEFINES     = ${CDEBUG}
CFLAGS          += -ff -wp -wc -zm -zps1
LDFLAGS         = -LIST maps.${TARGET} -MAP -Xref -Symbols rm.sym${TARGET}

VPATH = ^.build ^.dev.usb

include OBJ${COMPONENT}

include StdTools
include ModStdRule
#MODSQZ = echo not squeezing... 
include ModuleLibs
include RAMCModule
include ROMCModule

UNAME=	"RISC_OS"



clean:
        ${WIPE} o      ${WFLAGS}
        ${WIPE} o_hal  ${WFLAGS}
        ${WIPE} aif    ${WFLAGS}
        ${WIPE} aof    ${WFLAGS}
        ${WIPE} rm     ${WFLAGS}
        ${WIPE} i      ${WFLAGS}
        ${WIPE} maps   ${WFLAGS}
        ${WIPE} gpa    ${WFLAGS}
        ${WIPE} bin    ${WFLAGS}
        ${WIPE} linked ${WFLAGS}
        ${RM}   h.ehcimodhead
        ${RM}   h.ohcimodhead
        ${RM}   h.usbmodhead
        ${RM}   Resources.<Locale>.USBDevs
        ${RM}   ^.dev.usb.h.usbdevs
        ${RM}   ^.dev.usb.h.usbdevs_data
        
all: o._dirs

export: export_${PHASE}

export_libs: ${USBDIR}.o.${COMPONENT}
        @echo ${COMPONENT}: export complete (libs)

export_hdrs:   ^.dev.usb.h.usbdevs
        ${MKDIR} ${USBDIR}.dev.usb.h
        ${MKDIR} ${USBDIR}.h
        ${MKDIR} ${USBDIR}.sys.h
        ${MKDIR} ${USBDIR}.Hdr
        ${CP} ^.dev.usb.h.usb      ${USBDIR}.dev.usb.h.usb      ${CPFLAGS}
        ${CP} ^.dev.usb.h.usbdevs  ${USBDIR}.dev.usb.h.usbdevs  ${CPFLAGS}
        ${CP} ^.dev.usb.h.usbdi    ${USBDIR}.dev.usb.h.usbdi    ${CPFLAGS}
        ${CP} ^.dev.usb.h.usb_port ${USBDIR}.dev.usb.h.usb_port ${CPFLAGS}
        ${CP} h.USBDevFS           ${USBDIR}.h.USBDevFS         ${CPFLAGS}
        ${CP} ^.sys.h.device       ${USBDIR}.sys.h.device       ${CPFLAGS}
        ${CP} ^.VersionNum         ${USBDIR}.NetBSDVersion      ${CPFLAGS}
        ${CP} Hdr.usbhal           ${USBDIR}.Hdr.usbhal         ${CPFLAGS}
        @echo ${COMPONENT}: export complete (hdrs)

resources: resources_${COMPONENT}

resources_OHCIDriver: LocalRes:OHCIMessages
        ${MKDIR} ${RDIR}
        ${CP} LocalRes:OHCIMessages ${RDIR}.Messages ${CPFLAGS}
        @echo ${COMPONENT}: resource files copied

resources_EHCIDriver: LocalRes:EHCIMessages
        ${MKDIR} ${RDIR}
        ${CP} LocalRes:EHCIMessages ${RDIR}.Messages ${CPFLAGS}
        @echo ${COMPONENT}: resource files copied

resources_USBDriver: LocalRes:USBDriver ${DEVICELIST}
        ${MKDIR} ${RDIR}
        ${CP} LocalRes:USBMessages ${RDIR}.Messages ${CPFLAGS}
        ${CP} ${DEVICELIST} ${RDIR}.USBDevs ${CPFLAGS}
        @echo ${COMPONENT}: resource files copied

o._dirs:
        ${MKDIR} o
        ${MKDIR} o_hal
        ${MKDIR} aif
        ${MKDIR} aof
        ${MKDIR} rm
        ${MKDIR} i
        ${MKDIR} maps
        ${MKDIR} gpa
        ${MKDIR} bin
        ${TOUCH} o._dirs

ehcimodule.o:   ehcimodhead.h
ohcimodule.o:   ohcimodhead.h USBDriver.h
usbmodule.o usbkboard.o:        usbmodhead.h

^.dev.usb.h.usbdevs ^.dev.usb.h.usbdevs_data: ^.dev.usb.usbdevs ^.dev.usb.devlist2h/awk
	${GAWK} -v os="${UNAME} -s" -f ^.dev.usb.devlist2h/awk ^.dev.usb.usbdevs

Resources.<Locale>.USBDevs: bin.makedevs ^.dev.usb.h.usbdevs ^.dev.usb.h.usbdevs_data
        ${RUN}bin.makedevs > Resources.<Locale>.USBDevs

USBDriver.h: usbmodhead.h
        ${SED} -n "/define USBDriver_/p" h.usbmodhead > h.USBDriver

bin.makedevs: c.makedevs ${CLIB} ${DIRS}
        ${MAKE} -f makedevs/mk COMPONENT=makedevs THROWBACK=${THROWBACK}

usbmsgs.o: Resources.<Locale>.USBMessages Resources.<Locale>.USBDevs
        resgen resource_files o.usbmsgs Resources.<Locale>.USBMessages ${MSGLOC} Resources.<Locale>.USBDevs Resources.USBDriver.USBDevs

ohcimsgs.o: Resources.<Locale>.OHCIMessages
        resgen resource_files o.ohcimsgs Resources.<Locale>.OHCIMessages ${MSGLOC}

ehcimsgs.o: Resources.<Locale>.EHCIMessages
        resgen resource_files o.ehcimsgs Resources.<Locale>.EHCIMessages ${MSGLOC}

# HAL libraries:
.SUFFIXES: .o_hal
.c.o_hal:; ${CC} -APCS 3/nofp/noswst -wp -ff -DUSBHAL -c -depend !Depend -DKERNEL -D_KERNEL -Dpaddr_t=int -D__P(A)=A -DKLD_MODULE -DDISABLE_PACKED ${CINCLUDES} ${THROWBACK} -o $@ $<
.s.o_hal:; ${AS} ${ASFLAGS} -APCS 3/nofp/noswst -o $@ $<

${USBDIR}.o.${COMPONENT}: ${OBJS_HAL} ${DIRS}
        ${MKDIR} ${USBDIR}.o
        ${AR} ${ARFLAGS} ${USBDIR}.o.${COMPONENT} ${OBJS_HAL}

# RISC OS debug:
aif.${COMPONENT}: ${RAM_OBJS} ${RAM_LIBS} ${CLIB} ${DIRS}
        link -base 0 -aif -bin -d -o $@ ${RAM_OBJS} ${RAM_LIBS} ${CLIB}

gpa.${COMPONENT}: aif.${COMPONENT}
        togpa -s aif.${COMPONENT} $@

debug: gpa.${COMPONENT} ${DIRS}

.SUFFIXES: .i

.c.i:;  ${CC} -E ${CFLAGS} $< > $@

listing: i.ohci i.ohcimodule i.usb i.usbdi i.usbdi_util i.usb_subr i.ugen i.usbmodule i.ehcimodule

BBETYPE = usb
bbe-usb: bbe-generic
        ${MKDIR} ${BBEDIR}.aof
        BBE_Export_File aof.${TARGET}
        ${CP} rom_link_v.${TARGET} ${VERBATIMROMLINK} ${CPFLAGS}
        BBE_Export_File ^.VersionNum

# Static dependencies:
o.makedevs o.usbmouse: ^.dev.usb.h.usbdevs

# Dynamic dependencies:
