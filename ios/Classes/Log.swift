//
//  Log.swift
//  flutter_label_printer
//
//  Created by Peter Wong (Engineering) on 8/2/2023.
//

import Foundation
import os.log

public class Log: NSObject {
    enum LogLevel: Int, CaseIterable {
        case verbose, debug, info, warn, error, assert
    }
    
    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "FlutterLabelPrinter")

    var logLevel = LogLevel.info
    
    public func setLogLevel(level: Int) {
        let maxLevel = LogLevel.allCases.count
        let aLevel = max(0, min(level, maxLevel))
        logLevel = LogLevel(rawValue: aLevel)!
    }
    
    public func v(msg: StaticString) {
        if (logLevel.rawValue <= LogLevel.verbose.rawValue) {
            os_log(msg, type: .debug)
        }
    }
    
    public func d(msg: StaticString) {
        if (logLevel.rawValue <= LogLevel.debug.rawValue) {
            os_log(msg, type: .debug)
        }
    }
    
    public func i(msg: StaticString) {
        if (logLevel.rawValue <= LogLevel.info.rawValue) {
            os_log(msg, type: .info)
        }
    }
    
    public func w(msg: StaticString) {
        if (logLevel.rawValue <= LogLevel.warn.rawValue) {
            os_log(msg, type: .default)
        }
    }
    
    public func e(msg: StaticString) {
        if (logLevel.rawValue <= LogLevel.error.rawValue) {
            os_log(msg, type: .error)
        }
    }
    
    public func wtf(msg: StaticString) {
        if (logLevel.rawValue <= LogLevel.assert.rawValue) {
            os_log(msg, type: .fault)
        }
    }
}
