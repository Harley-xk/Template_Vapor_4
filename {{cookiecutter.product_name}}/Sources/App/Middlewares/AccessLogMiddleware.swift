//
//  AccessLogMiddleware.swift
//  App
//
//  Created by Harley-xk on 2020/3/10.
//

import Foundation
import Vapor

final class AccessLogMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).always { (result) in
            let log = AccessLog(request: request, response: result)
            _ = log.save(on: request.db)
        }
    }
}
