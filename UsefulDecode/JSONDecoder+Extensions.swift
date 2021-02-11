//
//  UsefulDecode.swift
//  UsefulDecode
//
//  Created by Zev Eisenberg on 2/5/21.
//

import Foundation

public extension JSONDecoder {
    func decodeWithBetterErrors<T: Decodable>(_ type: T.Type = T.self, from data: Data) throws -> T {
        do {
            return try decode(T.self, from: data)
        }
        catch let topLevelError as DecodingError {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
                throw processDecodingError(topLevelError, inJSONObject: jsonObject)
            }
            catch {
                if (error as NSError).domain == NSCocoaErrorDomain, (error as NSError).code == NSPropertyListReadCorruptError {
                    throw JSONSerializationFailed(reason: (error as NSError).userInfo[NSDebugDescriptionErrorKey] as? String ?? "")
                }
                throw error
            }
        }
        catch {
            throw OtherError(underlying: error)
        }
    }
}
