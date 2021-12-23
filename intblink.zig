const std = @import("std");
const avr = @import("atmega328p.zig");
const led_pin: u8 = 5;
//const loop_ms = 0x0a52;
const one_second = 53974;
//
var timeout:u1 = 0;
var ftimeout: *volatile u1 = &timeout;

fn bit(comptime b: u3)  u8 {
    return (1 << b);
}

fn flipLed() void {
    avr.portb.* ^= bit(led_pin);
}

// Timer interrupt
// When this uses callconv(.Interrupt) llvm emits an extra sei
// instruction. The callconv(.Signal) avoids that.
export fn __vector_13() callconv(.Signal) void {
    flipLed();
    avr.tcnt1.* = one_second;
    ftimeout.* = 1;
}

pub fn putc(ch: u8) void {
    while ((avr.ucsr0a.* & 0x20) != 0x20) {}
    avr.udr0.* = ch ;
}

pub fn puts(str: []const u8) void {
    for (str) |ch| { putc(ch); }
    while ((avr.ucsr0a.* & 0x40) != 0x40) {}
}

export fn main() void {
    avr.ddrb.* = bit(led_pin);
    avr.portb.* = bit(led_pin);
    avr.tcnt1.* = one_second;
    avr.tccr1a.* = 0;
    avr.tccr1b.* = bit(0) | bit(2); // clock select: clkio/1024
    avr.timsk1.* = bit(0); // Interrupt on overflow enable
    // uart init
    avr.ubrr0l.* = 16; // 115200bps Arduino Uno/Nano
    avr.ubrr0h.* = 0;
    avr.ucsr0a.* |= 0x02; // U2X0=1
    avr.ucsr0b.* |= 0x08; // TX enabled
    //
    avr.sei();
    //
    var buf:[100]u8 = undefined;
    var ix:i32 = 0;
    while (true) {
        if( ftimeout.* == 1 ){
            ftimeout.* = 0;
            var str  = std.fmt.bufPrint(&buf,"Hello world [{}]\n",.{ix}) catch return;
            puts(str);
            ix += 1;
        }
    }
}
