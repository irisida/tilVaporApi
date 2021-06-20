//
//  File.swift
//  
//
//  Created by ed on 20/06/2021.
//

import Foundation
import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        let acronymRoutes = routes.grouped("api", "acronyms")
        
        // MARK: - GETS
        acronymRoutes.get(use: getAllHandler)
        acronymRoutes.get("first", use: getFirstHandler)
        acronymRoutes.get(":acronymID", use: getHandler)
        acronymRoutes.get("search", use: searchHandler)
        acronymRoutes.get("sorted", use: sortedHandler)
        acronymRoutes.get(":acronymID", "user", use: getUserHandler)
                
        // MARK: - POSTS
        acronymRoutes.post(use: createHandler)
        
        // MARK: - PUTS
        acronymRoutes.put(":acronymID", use: updateHandler)
        
        // MARK: - DELETES
        acronymRoutes.delete(":acronymID", use: deleteHandler)
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<Acronym> {
        Acronym.find(req.parameters.get("acronymID", as: UUID.self), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let data = try req.content.decode(CreateAcronymData.self)
        
        let acronym = Acronym(short: data.short,
                              long: data.long,
                              userID: data.userID)
        
        return acronym.save(on: req.db).map {
            acronym
        }
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updatedRecord = try req.content.decode(CreateAcronymData.self)
        
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = updatedRecord.short
                acronym.long = updatedRecord.long
                acronym.$user.id = updatedRecord.userID
                
                return acronym.save(on: req.db).map {
                    acronym
                }
            }
    }
    
    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Acronym.find(req.parameters.get("acronymID", as: UUID.self), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return Acronym.query(on: req.db).group(.or) { or in
            or.filter(\.$short == searchTerm)
            or.filter(\.$long == searchTerm)
        }.all()
        // Single search field option (non grouped).
        //    return Acronym.query(on: req.db)
        //        .filter(\.$short == searchTerm)
        //        .all()
    }
    
    
    func getFirstHandler(_ req: Request) -> EventLoopFuture<Acronym> {
        return Acronym.query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    func sortedHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        return Acronym.query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }
    
    func getUserHandler(_ req: Request) -> EventLoopFuture<User> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user.get(on: req.db)
            }
    }
    
}

// MARK: - DTOs

struct CreateAcronymData: Content {
    // DTO to flatten the structure of what
    // gets passed in to a createHandler.
    let short: String
    let long: String
    let userID: UUID
}
