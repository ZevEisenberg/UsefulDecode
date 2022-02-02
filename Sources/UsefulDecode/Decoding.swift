//
//  Decoding.swift
//  UsefulDecode
//
//  Created by Zev Eisenberg on 2/5/21.
//

import Foundation

func processDecodingError(_ error: DecodingError, inJSONObject jsonObject: Any) -> Error {
  guard let context = error.context else {
        return NoContextError(underlying: error)
    }
  guard let key = context.codingPath.first else {
    return BetterNoValueFound(debugDescription: context.debugDescription, container: jsonObject)
  }
    return processDecodingErrorRecursive(
        error,
        context: context,
        inJSONObject: jsonObject,
        key: key,
        remainingCodingPath: context.codingPath.dropFirst()
    )
}

func processDecodingErrorRecursive(_ error: DecodingError, context: DecodingError.Context, inJSONObject jsonContainer: Any, key: CodingKey, remainingCodingPath: ArraySlice<CodingKey>) -> Error {

    #warning("don't assume string is the only key. Dictionaries can be keyed by ints.")

    /// The coding path up to and including the current key
    let currentCodingPath = Array(context.codingPath.dropLast(remainingCodingPath.count))
    guard remainingCodingPath.isEmpty else {
        // Recursion! Error was not at this level, so keep going deeper
        if let jsonArrayIndex = key.intValue, let jsonArray = jsonContainer as? [Any] {
            guard jsonArrayIndex < jsonArray.endIndex else {
                return ArrayOutOfBounds(index: jsonArrayIndex, array: jsonArray, path: currentCodingPath)
            }
            let nestedObject = jsonArray[jsonArrayIndex]
            return processDecodingErrorRecursive(error, context: context, inJSONObject: nestedObject, key: remainingCodingPath.first!, remainingCodingPath: remainingCodingPath.dropFirst())
        }
        else if let jsonDictionary = jsonContainer as? [String: Any] {
            guard let nestedObject = jsonDictionary[key.stringValue] else {
                return MissingObjectInDictionary(key: key.stringValue, dictionary: jsonDictionary, path: currentCodingPath)
            }
            return processDecodingErrorRecursive(error, context: context, inJSONObject: nestedObject, key: remainingCodingPath.first!, remainingCodingPath: remainingCodingPath.dropFirst())
        }
        else {
            return NotArrayOrDictionary(path: currentCodingPath)
        }
    }

    // Retrieve the intended object from its container

    let intendedObject: Any
    if let jsonArrayIndex = key.intValue, let jsonArray = jsonContainer as? [Any] {
        guard jsonArrayIndex < jsonArray.endIndex else {
            return ArrayOutOfBounds(index: jsonArrayIndex, array: jsonArray, path: currentCodingPath)
        }
        intendedObject = jsonArray[jsonArrayIndex]
    }
    else if let jsonDictionary = jsonContainer as? [String: Any] {
        guard let nested = jsonDictionary[key.stringValue] else {
            return MissingObjectInDictionary(key: key.stringValue, dictionary: jsonDictionary, path: currentCodingPath)
        }
        intendedObject = nested
    }
    else {
        return NotArrayOrDictionary(path: currentCodingPath)
    }

    // Base cases
    switch error {
    case .typeMismatch(let expectedType, _):
        return BetterTypeMismatch(
            expectedType: expectedType,
            actualType: type(of: intendedObject),
            actualValue: intendedObject,
            path: currentCodingPath
        )
    case .valueNotFound(let expectedType, _):
        return BetterValueNotFound(
            key: key.readable,
            expectedType: expectedType,
            container: jsonContainer,
            path: currentCodingPath
        )
    case .keyNotFound(let expectedKey, _):
        return BetterKeyNotFound(
            key: expectedKey.readable,
            container: intendedObject,
            path: currentCodingPath
        )
    case .dataCorrupted(_):
        return DataCorrupted(
            path: currentCodingPath
        )
    @unknown default:
        return Unknown(
            underlying: error
        )
    }
}
