#!/usr/bin/env swift
// Turns off the Caps Lock state. Karabiner remaps the Caps Lock key, so if
// Caps Lock gets enabled before Karabiner starts (e.g. at the login screen),
// the key can no longer turn it off.

import IOKit
import IOKit.hidsystem

var connect: io_connect_t = 0
let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(kIOHIDSystemClass))
defer { IOObjectRelease(service) }

guard IOServiceOpen(service, mach_task_self_, UInt32(kIOHIDParamConnectType), &connect) == KERN_SUCCESS else {
    print("Error: could not open IOHIDSystem")
    exit(1)
}
defer { IOServiceClose(connect) }

guard IOHIDSetModifierLockState(connect, Int32(kIOHIDCapsLockState), false) == KERN_SUCCESS else {
    print("Error: could not turn off Caps Lock")
    exit(1)
}
print("Caps Lock off")
