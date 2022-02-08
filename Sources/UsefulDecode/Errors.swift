//
//  Errors.swift
//  UsefulDecode
//
//  Created by Zev Eisenberg on 2/5/21.
//

import Foundation

// MARK: - Intermediate Errors

public struct OtherError: Error {
    let underlying: Error
}

public struct JSONSerializationFailed: Error {
    let reason: String
}

public struct ArrayOutOfBounds: Error {
    let index: Int
    let array: [Any]
    let path: [CodingKey]
}

public struct MissingObjectInDictionary: Error {
    let key: String
    let dictionary: [String: Any]
    let path: [CodingKey]
}

public struct NoContextError: Error {
    let underlying: DecodingError
}

public struct NotArrayOrDictionary: Error {
    let path: [CodingKey]
}

// MARK: - Leaf Node Errors

public struct BetterTypeMismatch: Error {
    let expectedType: Any.Type
    let actualType: Any.Type
    let actualValue: Any
    let path: [CodingKey]
}

public struct BetterKeyNotFound: Error {
    let key: String
    let container: Any
    let path: [CodingKey]
}

public struct BetterValueNotFound: Error {
    let key: String
    let expectedType: Any.Type
    let container: Any
    let path: [CodingKey]
}

public struct BetterNoValueFound: Error {
    let debugDescription: String
    let container: Any
}

public struct DataCorrupted: Error {
    let path: [CodingKey]
}

public struct Unknown: Error {
    let underlying: DecodingError
}

private func objectToJSON(_ object: Any) -> String {
    do {
        return try String(
            data: JSONSerialization.data(
                withJSONObject: object,
                options: [
                    .prettyPrinted,
                    .sortedKeys,
                    .withoutEscapingSlashes
                ]),
            encoding: .utf8) ?? "Unable to convert data to string"
    }
    catch {
        return String(describing: object)
    }

}

extension BetterNoValueFound: CustomStringConvertible {
    public var description: String {
        "Value not found: \(debugDescription), got:\n\(objectToJSON(container))"
    }
}

extension BetterTypeMismatch: CustomStringConvertible {
    public var description: String {
        "Type mismatch: expected \(expectedType), got \(actualType) '\(actualValue)' at \(path.readable)"
    }
}

extension BetterKeyNotFound: CustomStringConvertible {
    public var description: String {
        "Key not found: expected '\(key)' at \(path.readable), got:\n\(objectToJSON(container))"
    }
}

extension BetterValueNotFound: CustomStringConvertible {
    public var description: String {
        "Value not found: expected '\(key)' (\(expectedType)) at \(path.readable), got:\n\(objectToJSON(container))"
    }
}
