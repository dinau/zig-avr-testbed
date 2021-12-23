## Changed from original source
This repo referenced from original source https://github.com/nmichaels/zig-avr-testbed
and modifed some code for my Zig learning.
Original repo is very impressive, thank you sharing informaiton about Zig and AVR.

# Zig on AVR

This repo gets a trivial Zig program (blink an LED) working on an
Arduino Uno (atmega328p). There is much hackery.

## Prerequisites
This was built using:
 * Zig-0.9.0 at this moment
 * avr-gcc : Any version is probably ok
 * avrdude : Using attatched in Arduino IDE

My environment is Windows10 32bit.

## blinker.c

It's actually possible to tell that this one's working, because the
LED blinks. The preprocessor symbol `GCC` is defined if we're building
with avr-gcc, which is a requirement to get this whole thing
working. If it's not defined, clang works. I didn't bother to find the
actual symbol the compiler provides; flip it manually.

This program is a bit more complicated, since it's got a version that
uses an ISR. The Zig version does not know about interrupts.
* Note: No change same as original

## atmega328p.zig

A place to put constants and functions that would otherwise live in
avr/io.h and avr/interrupt.h. Zig's translate-c got too confused on
the actual AVR headers, so here we are.
* Note: Added UART registers.

## blink.zig

A tiny Zig program to blink an LED using a delay loop.
* Note: No change same as original except just adapted zig-0.9.0

## intblink.zig

A Zig version of the ISR version of blinker.c. Same as blink.zig, but
with an interrupt. Weird fact: llvm emits an `sei` instruction at the
start of the ISR.
* Note: Changed from original,
    1. Added UART output code, putc(),puts()
    1. Using std.fmt.bufPrint() output code 
    1. Adapted zig-0.9.0

## Makefile

This contains the actual point of this repo. The `zig` command line
uses Zig's `-femit-asm` switch to spit out avr assembler code. That
gets fed to GCC's `ld`, which is actually what llvm does to "support"
AVR. The linker sets up all the interrupt vectors and puts `main` in
the right place. For the C programs, The linked elf gets passed to
`objcopy` to make an intel ihex file. This last step is entirely
optional, since avrdude actually knows how to upload elf files. The
Zig path doesn't do it.

It also includes the `%.dmp` target, which is essential for knowing
whether the other steps are working correctly, and debugging them when
they're not.
* Note: Changed from original,
    1. It's just simplyfied build step according to my purpose.
