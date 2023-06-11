//
//  UsefulDecodeTests.swift
//  UsefulDecodeTests
//
//  Created by Zev Eisenberg on 2/5/21.
//

import XCTest
@testable import UsefulDecode

class UsefulDecodeTests: XCTestCase {

    let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    func testKeyNotFound() throws {
        let data = makeData("""
            [
                {
                    "first_name": "Zev",
                    "last_name": "Eisenberg",
                    "address": {
                        "street": "123 Main St",
                        "city": {
                            "name": "Kalamazoo",
                            "population": 12345,
                            "motto": "First, do no harm.",
                            "birds": [
                                {
                                    "name": "The Big One",
                                    "feathers": "all"
                                },
                                {
                                    "feathers": "some"
                                },
                                {
                                    "name": "Purple???",
                                    "feathers": "nah"
                                }
                            ]
                        },
                        "state": "disarray",
                        "country": "music",
                        "planet": {
                            "name": "Planet 9 from Outer Space",
                            "atmosphere": "chill"
                        }
                    }
                }
            ]
            """)
        XCTAssertThrowsError(try decoder.decodeWithBetterErrors([Person].self, from: data)) { error in
            XCTAssertEqual(String(describing: error), """
                Key not found: expected 'name' at [0]/address/city/birds/[1], got:
                {
                  "feathers" : "some"
                }
                """)
        }
    }

    func testTypeMismatch() throws {
        let data = makeData("""
            [
                {
                    "first_name": "Zev",
                    "last_name": "Eisenberg",
                    "address": {
                        "street": "123 Main St",
                        "city": {
                            "name": "Kalamazoo",
                            "population": 12345,
                            "motto": "First, do no harm.",
                            "birds": [
                                {
                                    "name": "The Big One",
                                    "feathers": "all"
                                },
                                {
                                    "name": 123,
                                    "feathers": "some"
                                },
                                {
                                    "name": "Purple???",
                                    "feathers": "nah"
                                }
                            ]
                        },
                        "state": "disarray",
                        "country": "music",
                        "planet": {
                            "name": "Planet 9 from Outer Space",
                            "atmosphere": "chill"
                        }
                    }
                }
            ]
            """)
        XCTAssertThrowsError(try decoder.decodeWithBetterErrors([Person].self, from: data)) { error in
            XCTAssertEqual(String(describing: error), "Type mismatch: expected String, got __NSCFNumber '123' at [0]/address/city/birds/[1]/name")
        }
    }

    func testNameNotFound() throws {
        let data = makeData("""
            [
                {
                    "first_name": "Zev",
                    "last_name": "Eisenberg",
                    "address": {
                        "street": "123 Main St",
                        "city": {
                            "name": "Kalamazoo",
                            "population": 12345,
                            "motto": "First, do no harm.",
                            "birds": [
                                {
                                    "name": "The Big One",
                                    "feathers": "all"
                                },
                                {
                                    "name": null,
                                    "feathers": "some"
                                },
                                {
                                    "name": "Purple???",
                                    "feathers": "nah"
                                }
                            ]
                        },
                        "state": "disarray",
                        "country": "music",
                        "planet": {
                            "name": "Planet 9 from Outer Space",
                            "atmosphere": "chill"
                        }
                    }
                }
            ]
            """)
        XCTAssertThrowsError(try decoder.decodeWithBetterErrors([Person].self, from: data)) { error in
            XCTAssertEqual(String(describing: error), """
                Value not found: expected 'name' (String) at [0]/address/city/birds/[1]/name, got:
                {
                  "feathers" : "some",
                  "name" : null
                }
                """)
        }
    }

    func testAddressNotFound() throws {
        let data = makeData("""
            [
                {
                    "first_name": "Zev",
                    "last_name": "Eisenberg",
                    "address": null
                }
            ]
            """)
        // TODO: Support multiple key decoding strategies?
        XCTExpectFailure("NOTE: this test is known to fail because the type that we get from the error is KeyedDecodingContainer<CodingKeys> or something like that instead of Address, which is what we would expect. Probably a JSONDecoder bug? But may be intentional? Unclear.")
        XCTAssertThrowsError(try decoder.decodeWithBetterErrors([Person].self, from: data)) { error in
            XCTAssertEqual(String(describing: error), """
                Value not found: expected 'address' (Address) at [0]/address, got:
                {
                  "address" : null,
                  "first_name" : "Zev",
                  "last_name" : "Eisenberg"
                }
                """)
        }
    }

    func testDataCorrupted() throws {
        let data = makeData("""
            [
                {
                    "first_name": "Zev",
                    "last_name": "Eisenberg",
                    "address
                }
            ]
            """)
        // TODO: Support multiple key decoding strategies?
        XCTAssertThrowsError(try decoder.decodeWithBetterErrors([Person].self, from: data)) { error in
#if swift(<5.8)
            XCTAssertEqual(String(describing: error), """
                JSONSerializationFailed(reason: "Unescaped control character around character 87.")
                """)
#else
            XCTAssertEqual(String(describing: error), """
                JSONSerializationFailed(reason: "Unescaped control character around line 5, column 16.")
                """)
#endif
        }
    }

    func testFirstLevelCrash() throws {
        // Should crash because "name" is spelled "names"
        let data = makeData("""
            {
                  "names": "Big",
                  "feathers": "some"
            }

            """)

        XCTAssertThrowsError(try decoder.decodeWithBetterErrors(Bird.self, from: data)) { error in
            XCTAssertEqual(String(describing: error), """
                Value not found: No value associated with key CodingKeys(stringValue: "name", intValue: nil) ("name")., got:
                {
                  "feathers" : "some",
                  "names" : "Big"
                }
                """)
        }
    }
    
}

private extension UsefulDecodeTests {

    func makeData(_ string: String) -> Data {
        string.data(using: .utf8)!
    }

}
