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
        ${RM}   h.ehcimodhead
        ${RM}   h.ohcimodhead
        ${RM}   h.usbmodhead
        ${RM}   Resources.<Locale>.USBDevs

all: o._dirs

export: export_${PHASE}

export_libs:
        @echo ${COMPONENT}: export complete (libs)

export_hdrs:
        ${MKDIR} ${USBDIR}.dev.usb.h
        ${MKDIR} ${USBDIR}.h
        ${MKDIR} ${USBDIR}.sys.h
        ${CP} ^.dev.usb.h.usb      ${USBDIR}.dev.usb.h.usb      ${CPFLAGS}
        ${CP} ^.dev.usb.h.usbdevs  ${USBDIR}.dev.usb.h.usbdevs  ${CPFLAGS}
        ${CP} ^.dev.usb.h.usbdi    ${USBDIR}.dev.usb.h.usbdi    ${CPFLAGS}
        ${CP} ^.dev.usb.h.usb_port ${USBDIR}.dev.usb.h.usb_port ${CPFLAGS}
        ${CP} h.USBDevFS           ${USBDIR}.h.USBDevFS         ${CPFLAGS}
        ${CP} ^.sys.h.device       ${USBDIR}.sys.h.device       ${CPFLAGS}
        ${CP} ^.VersionNum         ${USBDIR}.NetBSDVersion      ${CPFLAGS}
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

Resources.<Locale>.USBDevs: bin.makedevs
        bin.makedevs > Resources.<Locale>.USBDevs

# Remove the usbmodhead after creating the SWI table because if OHCIDriver
# makes it then it has the wrong messages file in it
USBDriver.h: usbmodhead.h
        ${SED} -n "/define USBDriver_/p" h.usbmodhead > h.USBDriver
        ${RM}   h.usbmodhead
        ${RM}   o.usbmodhead

bin.makedevs: o.makedevs ${CLIB} ${DIRS}
        ${LD} -o $@ o.makedevs ${CLIB}

usbmsgs.o: Resources.<Locale>.USBMessages Resources.<Locale>.USBDevs
        resgen resource_files o.usbmsgs Resources.<Locale>.USBMessages ${MSGLOC} Resources.<Locale>.USBDevs Resources.USBDriver.USBDevs

ohcimsgs.o: Resources.<Locale>.OHCIMessages
        resgen resource_files o.ohcimsgs Resources.<Locale>.OHCIMessages ${MSGLOC}

ehcimsgs.o: Resources.<Locale>.EHCIMessages
        resgen resource_files o.ehcimsgs Resources.<Locale>.EHCIMessages ${MSGLOC}

# RISC OS debug:
aif.${COMPONENT}: ${RAM_OBJS} ${RAM_LIBS} ${CLIB} ${DIRS}
        link -base 0 -aif -bin -d -o $@ ${RAM_OBJS} ${RAM_LIBS} ${CLIB}

gpa.${COMPONENT}: aif.${COMPONENT}
        togpa -s aif.${COMPONENT} $@

debug: gpa.${COMPONENT} ${DIRS}

.SUFFIXES: .i

.c.i:;  ${CC} -E ${CFLAGS} $< > $@

listing: i.ohci i.ohcimodule i.usb i.usbdi i.usbdi_util i.usb_subr i.ugen i.usbmodule i.ehcimodule


# Dynamic dependencies:
o.usb:	^.dev.usb.c.usb
o.usb:	TCPIPLibs:sys.h.cdefs
o.usb:	TCPIPLibs:sys.h.param
o.usb:	TCPIPLibs:sys.h.types
o.usb:	TCPIPLibs:sys.h.cdefs
o.usb:	TCPIPLibs:machine.h.endian
o.usb:	TCPIPLibs:machine.h.ansi
o.usb:	TCPIPLibs:machine.h.types
o.usb:	TCPIPLibs:sys.h.syslimits
o.usb:	TCPIPLibs:sys.h.cdefs
o.usb:	TCPIPLibs:sys.h.errno
o.usb:	TCPIPLibs:sys.h.time
o.usb:	TCPIPLibs:sys.h.resource
o.usb:	TCPIPLibs:sys.h.types
o.usb:	TCPIPLibs:sys.h.ucred
o.usb:	TCPIPLibs:sys.h.uio
o.usb:	TCPIPLibs:sys.h.rtprio
o.usb:	TCPIPLibs:sys.h.signal
o.usb:	TCPIPLibs:machine.h.signal
o.usb:	TCPIPLibs:machine.h.param
o.usb:	TCPIPLibs:machine.h.limits
o.usb:	TCPIPLibs:sys.h.systm
o.usb:	TCPIPLibs:machine.h.cpufunc
o.usb:	TCPIPLibs:machine.h.stdarg
o.usb:	TCPIPLibs:sys.h.callout
o.usb:	TCPIPLibs:sys.h.queue
o.usb:	TCPIPLibs:sys.h.kernel
o.usb:	TCPIPLibs:sys.h.linker_set
o.usb:	TCPIPLibs:sys.h.malloc
o.usb:	^.sys.h.device
o.usb:	TCPIPLibs:sys.h.queue
o.usb:	TCPIPLibs:sys.h.proc
o.usb:	TCPIPLibs:machine.h.proc
o.usb:	TCPIPLibs:sys.h.queue
o.usb:	TCPIPLibs:sys.h.rtprio
o.usb:	TCPIPLibs:sys.h.select
o.usb:	TCPIPLibs:sys.h.time
o.usb:	TCPIPLibs:sys.h.conf
o.usb:	TCPIPLibs:sys.h.fcntl
o.usb:	^.sys.h.poll
o.usb:	TCPIPLibs:sys.h.select
o.usb:	TCPIPLibs:sys.h.vnode
o.usb:	TCPIPLibs:sys.h.queue
o.usb:	TCPIPLibs:sys.h.signalvar
o.usb:	^.dev.usb.h.usb
o.usb:	TCPIPLibs:sys.h.types
o.usb:	TCPIPLibs:sys.h.time
o.usb:	^.dev.usb.h.usb_port
o.usb:	h.opt_usbverbose
o.usb:	^.sys.h.device
o.usb:	TCPIPLibs:h.errno
o.usb:	TCPIPLibs:sys.h.ioccom
o.usb:	^.dev.usb.h.usbdi
o.usb:	^.dev.usb.h.usbdi_util
o.usb:	^.machine.h.bus
o.usb:	TCPIPLibs:sys.h.types
o.usb:	^.dev.usb.h.usbdivar
o.usb:	^.dev.usb.h.usb_quirks
o.usbdi:	^.dev.usb.c.usbdi
o.usbdi:	TCPIPLibs:sys.h.cdefs
o.usbdi:	TCPIPLibs:sys.h.param
o.usbdi:	TCPIPLibs:sys.h.types
o.usbdi:	TCPIPLibs:sys.h.cdefs
o.usbdi:	TCPIPLibs:machine.h.endian
o.usbdi:	TCPIPLibs:machine.h.ansi
o.usbdi:	TCPIPLibs:machine.h.types
o.usbdi:	TCPIPLibs:sys.h.syslimits
o.usbdi:	TCPIPLibs:sys.h.cdefs
o.usbdi:	TCPIPLibs:sys.h.errno
o.usbdi:	TCPIPLibs:sys.h.time
o.usbdi:	TCPIPLibs:sys.h.resource
o.usbdi:	TCPIPLibs:sys.h.types
o.usbdi:	TCPIPLibs:sys.h.ucred
o.usbdi:	TCPIPLibs:sys.h.uio
o.usbdi:	TCPIPLibs:sys.h.rtprio
o.usbdi:	TCPIPLibs:sys.h.signal
o.usbdi:	TCPIPLibs:machine.h.signal
o.usbdi:	TCPIPLibs:machine.h.param
o.usbdi:	TCPIPLibs:machine.h.limits
o.usbdi:	TCPIPLibs:sys.h.systm
o.usbdi:	TCPIPLibs:machine.h.cpufunc
o.usbdi:	TCPIPLibs:machine.h.stdarg
o.usbdi:	TCPIPLibs:sys.h.callout
o.usbdi:	TCPIPLibs:sys.h.queue
o.usbdi:	TCPIPLibs:sys.h.malloc
o.usbdi:	TCPIPLibs:sys.h.proc
o.usbdi:	TCPIPLibs:machine.h.proc
o.usbdi:	TCPIPLibs:sys.h.queue
o.usbdi:	TCPIPLibs:sys.h.rtprio
o.usbdi:	TCPIPLibs:sys.h.select
o.usbdi:	TCPIPLibs:sys.h.time
o.usbdi:	^.machine.h.bus
o.usbdi:	TCPIPLibs:sys.h.types
o.usbdi:	^.dev.usb.h.usb
o.usbdi:	TCPIPLibs:sys.h.types
o.usbdi:	TCPIPLibs:sys.h.time
o.usbdi:	^.dev.usb.h.usb_port
o.usbdi:	h.opt_usbverbose
o.usbdi:	^.sys.h.device
o.usbdi:	TCPIPLibs:sys.h.queue
o.usbdi:	TCPIPLibs:h.errno
o.usbdi:	TCPIPLibs:sys.h.ioccom
o.usbdi:	^.dev.usb.h.usbdi
o.usbdi:	^.dev.usb.h.usbdi_util
o.usbdi:	^.dev.usb.h.usbdivar
o.usbdi:	^.dev.usb.h.usb_mem
o.usb_subr:	^.dev.usb.c.usb_subr
o.usb_subr:	TCPIPLibs:sys.h.cdefs
o.usb_subr:	TCPIPLibs:sys.h.param
o.usb_subr:	TCPIPLibs:sys.h.types
o.usb_subr:	TCPIPLibs:sys.h.cdefs
o.usb_subr:	TCPIPLibs:machine.h.endian
o.usb_subr:	TCPIPLibs:machine.h.ansi
o.usb_subr:	TCPIPLibs:machine.h.types
o.usb_subr:	TCPIPLibs:sys.h.syslimits
o.usb_subr:	TCPIPLibs:sys.h.cdefs
o.usb_subr:	TCPIPLibs:sys.h.errno
o.usb_subr:	TCPIPLibs:sys.h.time
o.usb_subr:	TCPIPLibs:sys.h.resource
o.usb_subr:	TCPIPLibs:sys.h.types
o.usb_subr:	TCPIPLibs:sys.h.ucred
o.usb_subr:	TCPIPLibs:sys.h.uio
o.usb_subr:	TCPIPLibs:sys.h.rtprio
o.usb_subr:	TCPIPLibs:sys.h.signal
o.usb_subr:	TCPIPLibs:machine.h.signal
o.usb_subr:	TCPIPLibs:machine.h.param
o.usb_subr:	TCPIPLibs:machine.h.limits
o.usb_subr:	TCPIPLibs:sys.h.systm
o.usb_subr:	TCPIPLibs:machine.h.cpufunc
o.usb_subr:	TCPIPLibs:machine.h.stdarg
o.usb_subr:	TCPIPLibs:sys.h.callout
o.usb_subr:	TCPIPLibs:sys.h.queue
o.usb_subr:	TCPIPLibs:sys.h.kernel
o.usb_subr:	TCPIPLibs:sys.h.linker_set
o.usb_subr:	TCPIPLibs:sys.h.malloc
o.usb_subr:	TCPIPLibs:sys.h.proc
o.usb_subr:	TCPIPLibs:machine.h.proc
o.usb_subr:	TCPIPLibs:sys.h.queue
o.usb_subr:	TCPIPLibs:sys.h.rtprio
o.usb_subr:	TCPIPLibs:sys.h.select
o.usb_subr:	TCPIPLibs:sys.h.time
o.usb_subr:	^.machine.h.bus
o.usb_subr:	TCPIPLibs:sys.h.types
o.usb_subr:	^.dev.usb.h.usb
o.usb_subr:	TCPIPLibs:sys.h.types
o.usb_subr:	TCPIPLibs:sys.h.time
o.usb_subr:	^.dev.usb.h.usb_port
o.usb_subr:	h.opt_usbverbose
o.usb_subr:	^.sys.h.device
o.usb_subr:	TCPIPLibs:sys.h.queue
o.usb_subr:	TCPIPLibs:h.errno
o.usb_subr:	TCPIPLibs:sys.h.ioccom
o.usb_subr:	^.dev.usb.h.usbdi
o.usb_subr:	^.dev.usb.h.usbdi_util
o.usb_subr:	^.dev.usb.h.usbdivar
o.usb_subr:	^.dev.usb.h.usbdevs
o.usb_subr:	^.dev.usb.h.usb_quirks
o.usbdi_util:	^.dev.usb.c.usbdi_util
o.usbdi_util:	TCPIPLibs:sys.h.cdefs
o.usbdi_util:	TCPIPLibs:sys.h.param
o.usbdi_util:	TCPIPLibs:sys.h.types
o.usbdi_util:	TCPIPLibs:sys.h.cdefs
o.usbdi_util:	TCPIPLibs:machine.h.endian
o.usbdi_util:	TCPIPLibs:machine.h.ansi
o.usbdi_util:	TCPIPLibs:machine.h.types
o.usbdi_util:	TCPIPLibs:sys.h.syslimits
o.usbdi_util:	TCPIPLibs:sys.h.cdefs
o.usbdi_util:	TCPIPLibs:sys.h.errno
o.usbdi_util:	TCPIPLibs:sys.h.time
o.usbdi_util:	TCPIPLibs:sys.h.resource
o.usbdi_util:	TCPIPLibs:sys.h.types
o.usbdi_util:	TCPIPLibs:sys.h.ucred
o.usbdi_util:	TCPIPLibs:sys.h.uio
o.usbdi_util:	TCPIPLibs:sys.h.rtprio
o.usbdi_util:	TCPIPLibs:sys.h.signal
o.usbdi_util:	TCPIPLibs:machine.h.signal
o.usbdi_util:	TCPIPLibs:machine.h.param
o.usbdi_util:	TCPIPLibs:machine.h.limits
o.usbdi_util:	TCPIPLibs:sys.h.systm
o.usbdi_util:	TCPIPLibs:machine.h.cpufunc
o.usbdi_util:	TCPIPLibs:machine.h.stdarg
o.usbdi_util:	TCPIPLibs:sys.h.callout
o.usbdi_util:	TCPIPLibs:sys.h.queue
o.usbdi_util:	TCPIPLibs:sys.h.kernel
o.usbdi_util:	TCPIPLibs:sys.h.linker_set
o.usbdi_util:	TCPIPLibs:sys.h.malloc
o.usbdi_util:	TCPIPLibs:sys.h.proc
o.usbdi_util:	TCPIPLibs:machine.h.proc
o.usbdi_util:	TCPIPLibs:sys.h.queue
o.usbdi_util:	TCPIPLibs:sys.h.rtprio
o.usbdi_util:	TCPIPLibs:sys.h.select
o.usbdi_util:	TCPIPLibs:sys.h.time
o.usbdi_util:	^.sys.h.device
o.usbdi_util:	TCPIPLibs:sys.h.queue
o.usbdi_util:	^.dev.usb.h.usb
o.usbdi_util:	TCPIPLibs:sys.h.types
o.usbdi_util:	TCPIPLibs:sys.h.time
o.usbdi_util:	^.dev.usb.h.usb_port
o.usbdi_util:	h.opt_usbverbose
o.usbdi_util:	^.sys.h.device
o.usbdi_util:	TCPIPLibs:h.errno
o.usbdi_util:	TCPIPLibs:sys.h.ioccom
o.usbdi_util:	^.dev.usb.h.usbhid
o.usbdi_util:	^.dev.usb.h.usbdi
o.usbdi_util:	^.dev.usb.h.usbdi_util
o.uhub:	^.dev.usb.c.uhub
o.uhub:	TCPIPLibs:sys.h.cdefs
o.uhub:	TCPIPLibs:sys.h.param
o.uhub:	TCPIPLibs:sys.h.types
o.uhub:	TCPIPLibs:sys.h.cdefs
o.uhub:	TCPIPLibs:machine.h.endian
o.uhub:	TCPIPLibs:machine.h.ansi
o.uhub:	TCPIPLibs:machine.h.types
o.uhub:	TCPIPLibs:sys.h.syslimits
o.uhub:	TCPIPLibs:sys.h.cdefs
o.uhub:	TCPIPLibs:sys.h.errno
o.uhub:	TCPIPLibs:sys.h.time
o.uhub:	TCPIPLibs:sys.h.resource
o.uhub:	TCPIPLibs:sys.h.types
o.uhub:	TCPIPLibs:sys.h.ucred
o.uhub:	TCPIPLibs:sys.h.uio
o.uhub:	TCPIPLibs:sys.h.rtprio
o.uhub:	TCPIPLibs:sys.h.signal
o.uhub:	TCPIPLibs:machine.h.signal
o.uhub:	TCPIPLibs:machine.h.param
o.uhub:	TCPIPLibs:machine.h.limits
o.uhub:	TCPIPLibs:sys.h.systm
o.uhub:	TCPIPLibs:machine.h.cpufunc
o.uhub:	TCPIPLibs:machine.h.stdarg
o.uhub:	TCPIPLibs:sys.h.callout
o.uhub:	TCPIPLibs:sys.h.queue
o.uhub:	TCPIPLibs:sys.h.kernel
o.uhub:	TCPIPLibs:sys.h.linker_set
o.uhub:	TCPIPLibs:sys.h.malloc
o.uhub:	^.machine.h.bus
o.uhub:	TCPIPLibs:sys.h.types
o.uhub:	^.dev.usb.h.usb
o.uhub:	TCPIPLibs:sys.h.types
o.uhub:	TCPIPLibs:sys.h.time
o.uhub:	^.dev.usb.h.usb_port
o.uhub:	h.opt_usbverbose
o.uhub:	^.sys.h.device
o.uhub:	TCPIPLibs:sys.h.queue
o.uhub:	TCPIPLibs:h.errno
o.uhub:	TCPIPLibs:sys.h.ioccom
o.uhub:	^.dev.usb.h.usbdi
o.uhub:	^.dev.usb.h.usbdi_util
o.uhub:	^.dev.usb.h.usbdivar
o.usbmodhead:	cmhg.usbmodhead
o.usbmodhead:	C:Global.h.Services
o.usbmodhead:	cmhg.^.Version
o.ohcimodhead:	cmhg.ohcimodhead
o.ohcimodhead:	C:Global.h.RISCOS
o.ohcimodhead:	C:Global.h.Services
o.ohcimodhead:	cmhg.^.Version
o.ohci:	^.dev.usb.c.ohci
o.ohci:	TCPIPLibs:sys.h.cdefs
o.ohci:	TCPIPLibs:sys.h.param
o.ohci:	TCPIPLibs:sys.h.types
o.ohci:	TCPIPLibs:sys.h.cdefs
o.ohci:	TCPIPLibs:machine.h.endian
o.ohci:	TCPIPLibs:machine.h.ansi
o.ohci:	TCPIPLibs:machine.h.types
o.ohci:	TCPIPLibs:sys.h.syslimits
o.ohci:	TCPIPLibs:sys.h.cdefs
o.ohci:	TCPIPLibs:sys.h.errno
o.ohci:	TCPIPLibs:sys.h.time
o.ohci:	TCPIPLibs:sys.h.resource
o.ohci:	TCPIPLibs:sys.h.types
o.ohci:	TCPIPLibs:sys.h.ucred
o.ohci:	TCPIPLibs:sys.h.uio
o.ohci:	TCPIPLibs:sys.h.rtprio
o.ohci:	TCPIPLibs:sys.h.signal
o.ohci:	TCPIPLibs:machine.h.signal
o.ohci:	TCPIPLibs:machine.h.param
o.ohci:	TCPIPLibs:machine.h.limits
o.ohci:	TCPIPLibs:sys.h.systm
o.ohci:	TCPIPLibs:machine.h.cpufunc
o.ohci:	TCPIPLibs:machine.h.stdarg
o.ohci:	TCPIPLibs:sys.h.callout
o.ohci:	TCPIPLibs:sys.h.queue
o.ohci:	TCPIPLibs:sys.h.malloc
o.ohci:	TCPIPLibs:sys.h.proc
o.ohci:	TCPIPLibs:machine.h.proc
o.ohci:	TCPIPLibs:sys.h.queue
o.ohci:	TCPIPLibs:sys.h.rtprio
o.ohci:	TCPIPLibs:sys.h.select
o.ohci:	TCPIPLibs:sys.h.time
o.ohci:	TCPIPLibs:sys.h.queue
o.ohci:	^.machine.h.bus
o.ohci:	TCPIPLibs:sys.h.types
o.ohci:	TCPIPLibs:machine.h.endian
o.ohci:	^.dev.usb.h.usb
o.ohci:	TCPIPLibs:sys.h.types
o.ohci:	TCPIPLibs:sys.h.time
o.ohci:	^.dev.usb.h.usb_port
o.ohci:	h.opt_usbverbose
o.ohci:	^.sys.h.device
o.ohci:	TCPIPLibs:sys.h.queue
o.ohci:	TCPIPLibs:h.errno
o.ohci:	TCPIPLibs:sys.h.ioccom
o.ohci:	^.dev.usb.h.usbdi
o.ohci:	^.dev.usb.h.usbdivar
o.ohci:	^.dev.usb.h.usb_mem
o.ohci:	^.dev.usb.h.usb_quirks
o.ohci:	^.dev.usb.h.ohcireg
o.ohci:	^.dev.usb.h.ohcivar
o.call_veneer: s.call_veneer
o.call_veneer: Hdr:ListOpts
o.call_veneer: Hdr:Macros
o.call_veneer: Hdr:System
o.call_veneer: Hdr:SWIs
o.call_veneer: Hdr:CPU.Generic26
o.call_veneer: Hdr:Machine.<Machine>
o.call_veneer: Hdr:Machine.Machine
o.call_veneer: Hdr:CPU.Generic32
o.call_veneer: Hdr:IO.GenericIO
o.call_veneer: Hdr:RISCOS
o.ehci:	^.dev.usb.c.ehci
o.ehci:	TCPIPLibs:sys.h.cdefs
o.ehci:	TCPIPLibs:sys.h.param
o.ehci:	TCPIPLibs:sys.h.types
o.ehci:	TCPIPLibs:sys.h.cdefs
o.ehci:	TCPIPLibs:machine.h.endian
o.ehci:	TCPIPLibs:machine.h.ansi
o.ehci:	TCPIPLibs:machine.h.types
o.ehci:	TCPIPLibs:sys.h.syslimits
o.ehci:	TCPIPLibs:sys.h.cdefs
o.ehci:	TCPIPLibs:sys.h.errno
o.ehci:	TCPIPLibs:sys.h.time
o.ehci:	TCPIPLibs:sys.h.resource
o.ehci:	TCPIPLibs:sys.h.types
o.ehci:	TCPIPLibs:sys.h.ucred
o.ehci:	TCPIPLibs:sys.h.uio
o.ehci:	TCPIPLibs:sys.h.rtprio
o.ehci:	TCPIPLibs:sys.h.signal
o.ehci:	TCPIPLibs:machine.h.signal
o.ehci:	TCPIPLibs:machine.h.param
o.ehci:	TCPIPLibs:machine.h.limits
o.ehci:	TCPIPLibs:sys.h.systm
o.ehci:	TCPIPLibs:machine.h.cpufunc
o.ehci:	TCPIPLibs:machine.h.stdarg
o.ehci:	TCPIPLibs:sys.h.callout
o.ehci:	TCPIPLibs:sys.h.queue
o.ehci:	TCPIPLibs:sys.h.kernel
o.ehci:	TCPIPLibs:sys.h.linker_set
o.ehci:	TCPIPLibs:sys.h.malloc
o.ehci:	^.sys.h.device
o.ehci:	TCPIPLibs:sys.h.queue
o.ehci:	TCPIPLibs:sys.h.select
o.ehci:	TCPIPLibs:sys.h.proc
o.ehci:	TCPIPLibs:machine.h.proc
o.ehci:	TCPIPLibs:sys.h.queue
o.ehci:	TCPIPLibs:sys.h.rtprio
o.ehci:	TCPIPLibs:sys.h.select
o.ehci:	TCPIPLibs:sys.h.time
o.ehci:	TCPIPLibs:sys.h.queue
o.ehci:	^.machine.h.bus
o.ehci:	TCPIPLibs:sys.h.types
o.ehci:	TCPIPLibs:machine.h.endian
o.ehci:	^.dev.usb.h.usb
o.ehci:	TCPIPLibs:sys.h.types
o.ehci:	TCPIPLibs:sys.h.time
o.ehci:	^.dev.usb.h.usb_port
o.ehci:	h.opt_usbverbose
o.ehci:	^.sys.h.device
o.ehci:	TCPIPLibs:h.errno
o.ehci:	TCPIPLibs:sys.h.ioccom
o.ehci:	^.dev.usb.h.usbdi
o.ehci:	^.dev.usb.h.usbdivar
o.ehci:	^.dev.usb.h.usb_mem
o.ehci:	^.dev.usb.h.usb_quirks
o.ehci:	^.dev.usb.h.ehcireg
o.ehci:	^.dev.usb.h.ehcivar
o.usbmodule:	c.usbmodule
o.usbmodule:	h.usbmodhead
o.usbmodule:	C:h.kernel
o.usbmodule:	h.bufman
o.usbmodule:	C:h.kernel
o.usbmodule:	C:Global.h.RISCOS
o.usbmodule:	C:Global.h.Services
o.usbmodule:	TCPIPLibs:sys.h.callout
o.usbmodule:	TCPIPLibs:sys.h.queue
o.usbmodule:	TCPIPLibs:sys.h.ioctl
o.usbmodule:	TCPIPLibs:sys.h.ttycom
o.usbmodule:	TCPIPLibs:sys.h.ioccom
o.usbmodule:	TCPIPLibs:sys.h.ioccom
o.usbmodule:	TCPIPLibs:sys.h.filio
o.usbmodule:	TCPIPLibs:sys.h.ioccom
o.usbmodule:	TCPIPLibs:sys.h.sockio
o.usbmodule:	TCPIPLibs:sys.h.ioccom
o.usbmodule:	TCPIPLibs:sys.h.time
o.usbmodule:	^.dev.usb.h.usb
o.usbmodule:	TCPIPLibs:sys.h.types
o.usbmodule:	TCPIPLibs:sys.h.cdefs
o.usbmodule:	TCPIPLibs:machine.h.endian
o.usbmodule:	TCPIPLibs:machine.h.ansi
o.usbmodule:	TCPIPLibs:machine.h.types
o.usbmodule:	TCPIPLibs:sys.h.time
o.usbmodule:	^.dev.usb.h.usb_port
o.usbmodule:	h.opt_usbverbose
o.usbmodule:	^.sys.h.device
o.usbmodule:	TCPIPLibs:sys.h.queue
o.usbmodule:	TCPIPLibs:h.errno
o.usbmodule:	TCPIPLibs:sys.h.errno
o.usbmodule:	TCPIPLibs:sys.h.ioccom
o.usbmodule:	^.dev.usb.h.usbdi
o.usbmodule:	^.dev.usb.h.usbdi_util
o.usbmodule:	^.dev.usb.h.usbdivar
o.usbmodule:	^.dev.usb.h.usbhid
o.usbmodule:	C:h.swis
o.usbmodule:	C:debuglib.h.debuglib
o.usbmodule:	C:callx.h.callx
o.usbmodule:	C:h.kernel
o.usbmodule:	OS:oslib.h.devicefs
o.usbmodule:	OS:oslib.h.types
o.usbmodule:	OS:oslib.h.os
o.usbmodule:	OS:oslib.h.buffer
o.usbmodule:	tbox:h.toolbox
o.usbmodule:	tbox:h.wimp
o.usbmodule:	h.usbmouse
o.usbmodule:	h.usbkboard
o.usbmodule:	h.service
o.usbmodule:	^.dev.usb.h.usb
o.usbkboard:	c.usbkboard
o.usbkboard:	C:Global.h.RISCOS
o.usbkboard:	C:Global.h.Keyboard
o.usbkboard:	C:Global.h.Pointer
o.usbkboard:	C:callx.h.callx
o.usbkboard:	C:h.kernel
o.usbkboard:	h.usbmodhead
o.usbkboard:	C:h.swis
o.usbkboard:	C:debuglib.h.debuglib
o.usbkboard:	TCPIPLibs:sys.h.callout
o.usbkboard:	TCPIPLibs:sys.h.queue
o.usbkboard:	TCPIPLibs:sys.h.ioctl
o.usbkboard:	TCPIPLibs:sys.h.ttycom
o.usbkboard:	TCPIPLibs:sys.h.ioccom
o.usbkboard:	TCPIPLibs:sys.h.ioccom
o.usbkboard:	TCPIPLibs:sys.h.filio
o.usbkboard:	TCPIPLibs:sys.h.ioccom
o.usbkboard:	TCPIPLibs:sys.h.sockio
o.usbkboard:	TCPIPLibs:sys.h.ioccom
o.usbkboard:	^.dev.usb.h.usb
o.usbkboard:	TCPIPLibs:sys.h.types
o.usbkboard:	TCPIPLibs:sys.h.cdefs
o.usbkboard:	TCPIPLibs:machine.h.endian
o.usbkboard:	TCPIPLibs:machine.h.ansi
o.usbkboard:	TCPIPLibs:machine.h.types
o.usbkboard:	TCPIPLibs:sys.h.time
o.usbkboard:	^.dev.usb.h.usb_port
o.usbkboard:	h.opt_usbverbose
o.usbkboard:	^.sys.h.device
o.usbkboard:	TCPIPLibs:sys.h.queue
o.usbkboard:	TCPIPLibs:h.errno
o.usbkboard:	TCPIPLibs:sys.h.errno
o.usbkboard:	TCPIPLibs:sys.h.ioccom
o.usbkboard:	^.dev.usb.h.usbdi
o.usbkboard:	^.dev.usb.h.usbdi_util
o.usbkboard:	^.dev.usb.h.usbdivar
o.usbkboard:	^.dev.usb.h.usbhid
o.usbkboard:	h.usbkboard
o.usbkboard:	tbox:h.wimplib
o.usbkboard:	tbox:h.wimp
o.ohcimodule:	c.ohcimodule
o.ohcimodule:	h.ohcimodhead
o.ohcimodule:	C:h.kernel
o.ohcimodule:	h.USBDriver
o.ohcimodule:	C:h.swis
o.ohcimodule:	^.machine.h.bus
o.ohcimodule:	TCPIPLibs:sys.h.types
o.ohcimodule:	TCPIPLibs:sys.h.cdefs
o.ohcimodule:	TCPIPLibs:machine.h.endian
o.ohcimodule:	TCPIPLibs:machine.h.ansi
o.ohcimodule:	TCPIPLibs:machine.h.types
o.ohcimodule:	TCPIPLibs:sys.h.queue
o.ohcimodule:	TCPIPLibs:sys.h.types
o.ohcimodule:	TCPIPLibs:sys.h.systm
o.ohcimodule:	TCPIPLibs:machine.h.cpufunc
o.ohcimodule:	TCPIPLibs:machine.h.stdarg
o.ohcimodule:	TCPIPLibs:sys.h.callout
o.ohcimodule:	TCPIPLibs:sys.h.queue
o.ohcimodule:	^.dev.usb.h.usb
o.ohcimodule:	TCPIPLibs:sys.h.types
o.ohcimodule:	TCPIPLibs:sys.h.time
o.ohcimodule:	^.dev.usb.h.usb_port
o.ohcimodule:	h.opt_usbverbose
o.ohcimodule:	^.sys.h.device
o.ohcimodule:	TCPIPLibs:sys.h.queue
o.ohcimodule:	TCPIPLibs:h.errno
o.ohcimodule:	TCPIPLibs:sys.h.errno
o.ohcimodule:	TCPIPLibs:sys.h.ioccom
o.ohcimodule:	^.dev.usb.h.usbdi
o.ohcimodule:	^.dev.usb.h.usbdivar
o.ohcimodule:	^.dev.usb.h.ohcireg
o.ohcimodule:	^.dev.usb.h.ohcivar
o.ohcimodule:	C:Global.h.RISCOS
o.ohcimodule:	C:Global.h.Services
o.ohcimodule:	C:Global.h.HALEntries
o.ohcimodule:	C:Interface.h.PCI
o.ohcimodule:	C:callx.h.callx
o.ohcimodule:	C:h.kernel
o.ohcimodule:	tbox:h.toolbox
o.ohcimodule:	tbox:h.wimp
o.ohcimodule:	C:DebugLib.h.DebugLib
o.ohcimodule:	h.service
o.ohcimodule:	^.dev.usb.h.usb
o.ehcimodule:	c.ehcimodule
o.ehcimodule:	h.ehcimodhead
o.ehcimodule:	C:h.kernel
o.ehcimodule:	h.USBDriver
o.ehcimodule:	C:h.swis
o.ehcimodule:	^.machine.h.bus
o.ehcimodule:	TCPIPLibs:sys.h.types
o.ehcimodule:	TCPIPLibs:sys.h.cdefs
o.ehcimodule:	TCPIPLibs:machine.h.endian
o.ehcimodule:	TCPIPLibs:machine.h.ansi
o.ehcimodule:	TCPIPLibs:machine.h.types
o.ehcimodule:	TCPIPLibs:sys.h.queue
o.ehcimodule:	TCPIPLibs:sys.h.types
o.ehcimodule:	TCPIPLibs:sys.h.systm
o.ehcimodule:	TCPIPLibs:machine.h.cpufunc
o.ehcimodule:	TCPIPLibs:machine.h.stdarg
o.ehcimodule:	TCPIPLibs:sys.h.callout
o.ehcimodule:	TCPIPLibs:sys.h.queue
o.ehcimodule:	^.dev.usb.h.usb
o.ehcimodule:	TCPIPLibs:sys.h.types
o.ehcimodule:	TCPIPLibs:sys.h.time
o.ehcimodule:	^.dev.usb.h.usb_port
o.ehcimodule:	h.opt_usbverbose
o.ehcimodule:	^.sys.h.device
o.ehcimodule:	TCPIPLibs:sys.h.queue
o.ehcimodule:	TCPIPLibs:h.errno
o.ehcimodule:	TCPIPLibs:sys.h.errno
o.ehcimodule:	TCPIPLibs:sys.h.ioccom
o.ehcimodule:	^.dev.usb.h.usbdi
o.ehcimodule:	^.dev.usb.h.usbdivar
o.ehcimodule:	^.dev.usb.h.ehcireg
o.ehcimodule:	^.dev.usb.h.ehcivar
o.ehcimodule:	C:Global.h.RISCOS
o.ehcimodule:	C:Global.h.HALEntries
o.ehcimodule:	C:Interface.h.PCI
o.ehcimodule:	C:callx.h.callx
o.ehcimodule:	C:h.kernel
o.ehcimodule:	C:DebugLib.h.DebugLib
o.ehcimodule:	h.service
o.ehcimodule:	^.dev.usb.h.usb
o.ehcimodule:	OS:oslib.h.devicefs
o.ehcimodule:	OS:oslib.h.types
o.ehcimodule:	OS:oslib.h.os
o.ehcimodule:	OS:oslib.h.buffer
