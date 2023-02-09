//
//  PluginException.swift
//  flutter_label_printer
//
//  Created by Peter Wong (Engineering) on 20/1/2023.
//

import Foundation

struct PluginError: Error {
    let code: Int
    let message: String
}
