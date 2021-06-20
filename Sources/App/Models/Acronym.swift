//
//  File.swift
//  
//
//  Created by ed on 20/06/2021.
//

import Foundation
import Vapor
import Fluent

final class Acronym: Model {
    
    static let schema = "acronyms"
    
    @ID
    var id: UUID?
    
    @Field(key: "short")
    var short: String
    
    @Field(key: "long")
    var long: String
    
    @Parent(key: "userID") // Parent relation stores a ref to another Models ID property
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, short: String, long: String, userID: User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userID
    }
}

// add the codable wrapper to allow conversions
extension Acronym: Content {}
