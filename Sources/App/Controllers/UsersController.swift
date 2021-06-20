//
//  File.swift
//  
//
//  Created by ed on 20/06/2021.
//

import Foundation
import Fluent
import Vapor

struct UsersController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("api", "users")
        
        // MARK: - GETS
        usersRoute.get(use: getAllHandler)
        usersRoute.get(":userID", use: getHandler)
        
        // MARK: - POSTS
        usersRoute.post(use: createHandler)
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<User> {
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map {
            user
        }
    }
}
