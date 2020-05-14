//
//  UserController.swift
//  App
//
//  Created by Harley-xk on 2020/3/4.
//

import Fluent
import Foundation
import Vapor

struct LoginResponse: Content {
    var user: User.Public
    var token: Token.Public
}

final class AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.grouped(User.authenticator())
            .post("login", use: passwordLogin)
        routes.post("autoLogin", use: autoLogin)
        routes.post("logout", use: logout)
    }

    func passwordLogin(_ request: Request) throws -> EventLoopFuture<LoginResponse> {
        let user = try request.auth.require(User.self)
        let token = try user.generateToken()
        return token.save(on: request.db).map {
            return LoginResponse(user: user.makePublic(), token: token.makePublic())
        }
    }

    func autoLogin(_ request: Request) throws -> EventLoopFuture<LoginResponse> {
        guard let bearer = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        return Token.query(on: request.db).filter(\.$value == bearer.token).first().tryFlatMap { (token) -> EventLoopFuture<LoginResponse> in
            guard let t = token, t.isValid else {
                throw Abort(.unauthorized)
            }
            return t.$user.get(on: request.db).flatMap { user in
                return t.refresh().update(on: request.db).transform(to:
                    LoginResponse(user: user.makePublic(), token: t.makePublic())
                )
            }
        }
    }

    func logout(_ request: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let bearer = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        return Token.query(on: request.db).filter(\.$value == bearer.token).first().tryFlatMap { (token) -> EventLoopFuture<HTTPStatus> in
            guard let t = token, t.isValid else {
                throw Abort(.unauthorized)
            }
            return t.delete(on: request.db).transform(to: .noContent)
        }
    }
}
