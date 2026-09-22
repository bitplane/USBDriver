#ifndef USBDRIVER_GNU_COMPAT_H
#define USBDRIVER_GNU_COMPAT_H

/* UnixLib's sys/types.h lacks the fixed-point type used by sys/proc.h. */
typedef unsigned long fixpt_t;

#ifndef __dead
#define __dead __attribute__((noreturn))
#endif
#ifndef __dead2
#define __dead2 __attribute__((noreturn))
#endif

#endif
