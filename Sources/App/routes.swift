import Fluent
import Vapor

func routes(_ app: Application) throws {
        
    // Declared controllers
    let acronymsController = AcronymsController()
    let usersController = UsersController()
    
    // Register controllers
    try app.register(collection: acronymsController)
    try app.register(collection: usersController)
}
