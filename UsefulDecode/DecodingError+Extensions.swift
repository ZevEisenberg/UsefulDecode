//
//  DecodingError+Extensions.swift
//  UsefulDecode
//
//  Created by Zev Eisenberg on 2/5/21.
//

import Foundation

extension DecodingError {
    var context: DecodingError.Context? {
        switch self {
        case let .typeMismatch(_, context),
             let .valueNotFound(_, context),
             let .keyNotFound(_, context),
             let .dataCorrupted(context):
            return context
        @unknown default:
            return nil
        }
    }
}
