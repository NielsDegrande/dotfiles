// VerticalMonitorLayout.swift
//
// Centers the external monitor above the MacBook display (or vice versa).
//
// Copyright 2025 Alin Panaitiu — MIT License
// Source: https://github.com/alin23/mac-utils

import Cocoa
import Foundation

// MARK: - Helpers (from lib/Extensions.swift)

func configure(_ action: (CGDisplayConfigRef) -> Bool) {
    var configRef: CGDisplayConfigRef?
    var err = CGBeginDisplayConfiguration(&configRef)
    guard err == .success, let config = configRef else {
        print("Error with CGBeginDisplayConfiguration: \(err)")
        return
    }

    guard action(config) else {
        _ = CGCancelDisplayConfiguration(config)
        return
    }

    err = CGCompleteDisplayConfiguration(config, .permanently)
    guard err == .success else {
        print("Error with CGCompleteDisplayConfiguration")
        _ = CGCancelDisplayConfiguration(config)
        return
    }
}

extension NSScreen {
    static var onlineDisplayIDs: [CGDirectDisplayID] {
        let maxDisplays: UInt32 = 16
        var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
        var displayCount: UInt32 = 0

        let err = CGGetOnlineDisplayList(maxDisplays, &onlineDisplays, &displayCount)
        if err != .success {
            print("Error on getting online displays: \(err)")
        }

        return Array(onlineDisplays.prefix(Int(displayCount)))
    }
}

// MARK: - Main

configure { config in
    let mainDisplay = CGMainDisplayID()
    var macBookDisplay: CGDirectDisplayID
    var externalDisplay: CGDirectDisplayID
    if CGDisplayIsBuiltin(mainDisplay) != 0 {
        macBookDisplay = mainDisplay
        guard let otherDisplay = NSScreen.onlineDisplayIDs.first(where: { $0 != macBookDisplay }) else {
            print("No external display detected")
            return false
        }
        externalDisplay = otherDisplay
    } else {
        externalDisplay = mainDisplay
        guard let otherDisplay = NSScreen.onlineDisplayIDs.first(where: { CGDisplayIsBuiltin($0) != 0 }) else {
            print("No internal display detected")
            return false
        }
        macBookDisplay = otherDisplay
    }

    let macBookBounds = CGDisplayBounds(macBookDisplay)
    let monitorBounds = CGDisplayBounds(externalDisplay)
    print(
        "Main Display: x=\(macBookBounds.origin.x) y=\(macBookBounds.origin.y) width=\(macBookBounds.width) height=\(macBookBounds.height)"
    )
    print(
        "External Display: x=\(monitorBounds.origin.x) y=\(monitorBounds.origin.y) width=\(monitorBounds.width) height=\(monitorBounds.height)"
    )

    if macBookDisplay == mainDisplay {
        let monitorX = (macBookBounds.width - monitorBounds.width) / 2
        let monitorY = -monitorBounds.height

        print("\nNew external display coordinates: x=\(monitorX) y=\(monitorY)")
        CGConfigureDisplayOrigin(config, externalDisplay, Int32(monitorX.rounded()), Int32(monitorY.rounded()))
    } else {
        let monitorX = (monitorBounds.width - macBookBounds.width) / 2
        let monitorY = monitorBounds.height

        print("\nNew internal display coordinates: x=\(monitorX) y=\(monitorY)")
        CGConfigureDisplayOrigin(config, macBookDisplay, Int32(monitorX.rounded()), Int32(monitorY.rounded()))
    }

    return true
}
