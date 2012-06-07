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

UNAME           = "RISC_OS"
VPATH           = ^.build ^.dev.usb
DEVICELIST      = Resources.<Locale>.USBDevs
CUSTOMRES       = custom
CUSTOMEXP       = custom
COMPONENT      ?= NetBSD
CINCLUDES       = -Itbox:,TCPIPLibs:,^.,OS:,C:USB
CDEFINES       += ${CDEBUG} -DKERNEL -D_KERNEL -Dpaddr_t=int -D__P(A)=A -DKLD_MODULE -DDISABLE_PACKED
RES_OBJ         =
RES_AREA        = resource_files
LIBS            = ${CALLXLIB} ${ASMUTILS}

#
# Debug switch
#
DEBUG ?= FALSE
ifeq (${DEBUG},TRUE)
CFLAGS         += -DDEBUGLIB -DUSB_DEBUG -DOHCI_DEBUG -DEHCI_DEBUG
CMHGDEFINES    += -DUSB_DEBUG -DOHCI_DEBUG -DEHCI_DEBUG
LIBS           += ${DEBUGLIBS} ${NET5LIBS}
endif

#
# Generate USBDriver and the controller drivers by choosing the list of objects
#
ifeq ("${COMPONENT}","EHCIDriver")
CMHGFILE        = ehcimodhead
CMHGDEPENDS     = ehcimodule
MSGS_ORIGIN     = LocalRes:EHCIMessages
OBJS            = ehcimodule ehci port call_veneer \
                  triggercbs usbroothub_subr
OBJS_HAL        = o_hal.ehci o_hal.usbroothub_subr o_hal.ehcihal
endif

ifeq ("${COMPONENT}","OHCIDriver")
CMHGFILE        = ohcimodhead
CMHGDEPENDS     = ohcimodule
MSGS_ORIGIN     = LocalRes:OHCIMessages
OBJS            = ohcimodule ohci port call_veneer \
                  triggercbs
OBJS_HAL        = o_hal.ohci
endif

ifeq ("${COMPONENT}","USBDriver")
CMHGFILE        = usbmodhead
CMHGDEPENDS     = usbmouse usbmodule usbkboard
MSGS_ORIGIN     = LocalRes:USBMessages
OBJS            = usbmodule port usb usbdi usb_subr \
                  usbdi_util usb_quirks uhub usbmouse usbkboard \
                  hid bufman triggercbs call_veneer
OBJS_HAL        = o_hal.usb o_hal.usbdi o_hal.usb_subr o_hal.usbdi_util \
                  o_hal.usb_quirks o_hal.uhub o_hal.porthal o_hal.halheap \
                  o_hal.usbhal
endif

SA_OBJS         = ${OBJS} ${COMPONENT}Res
DBG_OBJS        = ${OBJS} ${COMPONENT}Res

include CModule

CFLAGS         += -wp -wc
LDFLAGS        += -LIST maps.${TARGET} -MAP -Xref -Symbols rm.sym${TARGET}
DBG_LIBS       += ${NET5LIBS}
EXPDIR          = <Lib$Dir>.USB

#
# HAL library rules
#
.SUFFIXES: .o_hal
.c.o_hal:; ${CC} -APCS 3/nofp/noswst -wp -ff -DUSBHAL -c -depend !Depend -DKERNEL -D_KERNEL -Dpaddr_t=int -D__P(A)=A -DKLD_MODULE -DDISABLE_PACKED ${CINCLUDES} ${THROWBACK} -o $@ $<
.s.o_hal:; ${AS} ${ASFLAGS} -APCS 3/nofp/noswst -o $@ $<

#
# Produce the devices list
#
bin.makedevs: c.makedevs ${DIRS}
        ${MAKE} -f makedevs/mk COMPONENT=makedevs THROWBACK=${THROWBACK}

${DEVICELIST}: bin.makedevs ^.dev.usb.h.usbdevs ^.dev.usb.h.usbdevs_data
        ${RUN}bin.makedevs > $@

#
# Supplemented or overridden targets
#
clean::
        ${XWIPE} o_hal ${WFLAGS}
        ${XWIPE} maps  ${WFLAGS}
        ${XWIPE} bin   ${WFLAGS}
        ${RM}    h.ehcimodhead
        ${RM}    h.ohcimodhead
        ${RM}    h.usbmodhead
        ${RM}    ${DEVICELIST}
        ${RM}    ^.dev.usb.h.usbdevs
        ${RM}    ^.dev.usb.h.usbdevs_data

${DIRS}::
        ${MKDIR} o_hal
        ${MKDIR} maps
        ${MKDIR} bin

export: export_${PHASE}
        @${NOP}

export_libs: ${EXPDIR}.o.${COMPONENT}
        @echo ${COMPONENT}: library export complete

export_hdrs:   ^.dev.usb.h.usbdevs
        ${MKDIR} ${EXPDIR}.dev.usb.h
        ${MKDIR} ${EXPDIR}.h
        ${MKDIR} ${EXPDIR}.sys.h
        ${MKDIR} ${EXPDIR}.Hdr
        ${CP} ^.dev.usb.h.usb      ${EXPDIR}.dev.usb.h.usb      ${CPFLAGS}
        ${CP} ^.dev.usb.h.usbdevs  ${EXPDIR}.dev.usb.h.usbdevs  ${CPFLAGS}
        ${CP} ^.dev.usb.h.usbdi    ${EXPDIR}.dev.usb.h.usbdi    ${CPFLAGS}
        ${CP} ^.dev.usb.h.usb_port ${EXPDIR}.dev.usb.h.usb_port ${CPFLAGS}
        ${CP} h.USBDevFS           ${EXPDIR}.h.USBDevFS         ${CPFLAGS}
        ${CP} ^.sys.h.device       ${EXPDIR}.sys.h.device       ${CPFLAGS}
        ${CP} ^.VersionNum         ${EXPDIR}.LibVersion         ${CPFLAGS}
        ${CP} Hdr.usbhal           ${EXPDIR}.Hdr.usbhal         ${CPFLAGS}
        @echo ${COMPONENT}: header export complete

resources: resources_${COMPONENT}

resources_OHCIDriver: LocalRes:OHCIMessages
        ${MKDIR} ${RESFSDIR}
        ${TOKENCHECK} LocalRes:OHCIMessages
        ${CP} LocalRes:OHCIMessages ${RESFSDIR}.Messages ${CPFLAGS}
        @echo ${COMPONENT}: resources copied to Messages module

resources_EHCIDriver: LocalRes:EHCIMessages
        ${MKDIR} ${RESFSDIR}
        ${TOKENCHECK} LocalRes:EHCIMessages
        ${CP} LocalRes:EHCIMessages ${RESFSDIR}.Messages ${CPFLAGS}
        @echo ${COMPONENT}: resources copied to Messages module

resources_USBDriver: LocalRes:USBDriver ${DEVICELIST}
        ${MKDIR} ${RESFSDIR}
        ${TOKENCHECK} LocalRes:USBMessages
        ${CP} LocalRes:USBMessages ${RESFSDIR}.Messages ${CPFLAGS}
        ${CP} ${DEVICELIST} ${RESFSDIR}.USBDevs ${CPFLAGS}
        @echo ${COMPONENT}: resources copied to Messages module

#
# Static dependencies
#
^.dev.usb.h.usbdevs ^.dev.usb.h.usbdevs_data: ^.dev.usb.usbdevs ^.dev.usb.devlist2h/awk
        ${GAWK} -v os="${UNAME} -s" -f ^.dev.usb.devlist2h/awk ^.dev.usb.usbdevs

${EXPDIR}.o.${COMPONENT}: ${OBJS_HAL} ${DIRS}
        ${MKDIR} ${EXPDIR}.o
        ${AR} ${ARFLAGS} $@ ${OBJS_HAL}

${MERGEDMDIR}.${COMPONENT}Msgs: ${MSGS_ORIGIN}
        ${MKDIR} ${MERGEDMDIR}
        ${TOKENCHECK} ${MSGS_ORIGIN}
        ${CP} ${MSGS_ORIGIN} $@ ${CPFLAGS}

o.${COMPONENT}Res od.${COMPONENT}Res: ${MERGEDMDIR}.${COMPONENT}Msgs ${DIRS}
        ${RESGEN} ${RES_AREA} $@ ${MERGEDMDIR}.${COMPONENT}Msgs ${RES_PATH}


# Dynamic dependencies:
