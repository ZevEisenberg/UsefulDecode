//
//  CodingKey+Extensions.swift
//  UsefulDecode
//
//  Created by Zev Eisenberg on 2/5/21.
//

import Foundation

extension CodingKey {
    var readable: String {
        intValue.map { "[\($0)]" } ?? stringValue
    }
}

extension Array where Element == CodingKey {
    var readable: String {
        map(\.readable).joined(separator: "/")
    }
}
