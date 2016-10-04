/*
        David @InfinitelyManic
        Based on question from http://stackoverflow.com/questions/39820523/arm-assembly-time-system-call-unexpected-values

        $ uname -a
        Linux raspberrypi 4.4.21-v7+ #911 SMP Thu Sep 15 14:22:38 BST 2016 armv7l GNU/Linux

        $ cat /etc/os-release
        PRETTY_NAME="Raspbian GNU/Linux 8 (jessie)"

        $ less /usr/share/gdb/syscalls/arm-linux.xml
        <syscall name="time" number="13"/>

        arm/EABI   swi 0x0              r7          r0

        gcc -g stuff.s -o stuff
*/

.bss
.data
        fmt:    .asciz  "%lu\n"
        t:      .zero 8
.text
        .global main
        .include "mymac.s"

main:
        nop
        ldr r9,=t

        bl _time0
        mov r1, r0
        ldr r1, [r9]
        bl write

        bl _time1
        ldr r1, [r9]
        bl write

exit:
        mov r7, #1
        svc 0

write:
        push {r1-r3,lr}
        ldr r0,=fmt
        bl printf
        pop {r1-r3,pc}
//      time
_time0:
        push {r1-r3,lr}
        mov r7, #13             // time
        ldr r0,=t
        eor r1, r1
        svc 0
        pop {r1-r3,pc}

//      gettimeofday
_time1:
        push {r1-r3,lr}
        mov r7, #78             // gettimeofday
        ldr r0,=t
        eor r1, r1
        svc 0
        pop {r1-r3,pc}
