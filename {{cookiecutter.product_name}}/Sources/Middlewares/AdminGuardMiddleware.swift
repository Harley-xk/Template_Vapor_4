//
//  AdminGuradMiddleware.swift
//  
//
//  Created by Harley-xk on 2020/5/6.
//

import Foundation
import Vapor

class AdminGuradMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let user = try? request.auth.require(User.self), user.roles.contains(.admin) else {
            return request.eventLoop.future(Response(status: .forbidden))
        }
        return next.respond(to: request)
    }
}
