//
//  Models.swift
//  UsefulDecodeTests
//
//  Created by Zev Eisenberg on 2/5/21.
//

struct Person: Codable {
    var firstName, lastName: String
    var address: Address
}

struct Address: Codable {
    var street: String
    var city: City
    var state, country: String
    var planet: Planet
}

struct City: Codable {
    var name: String
    var population: Int
    var motto: String
    var birds: [Bird]
}

struct Bird: Codable {
    var name, feathers: String
}

struct Planet: Codable {
    var name, atmosphere: String
}
