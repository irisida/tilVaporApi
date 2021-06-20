//
//  File.swift
//  
//
//  Created by ed on 20/06/2021.
//

import Foundation
import Fluent
import Vapor

final class User: Model, Content {
    
    static let schema = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "username")
    var username: String
    
    init() {}
    
    init(id: UUID? = nil, name: String, username: String) {
        self.name = name
        self.username = username
    }
}
