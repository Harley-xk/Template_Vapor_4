//
//  CreateAccessLog.swift
//  App
//
//  Created by Harley-xk on 2020/3/10.
//

import Foundation
import Fluent

final class CreateAccessLog: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AccessLog.schema)
            .field("id", .int, .identifier(auto: true))
            .field("ip", .string)
            .field("createdAt", .datetime)
            .field("path", .string)
            .field("request",.string)
            .field("response", .string)
        .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AccessLog.schema).delete()
    }
}
