//
//  LogController.swift
//
//
//  Created by Harley-xk on 2020/5/6.
//

import Foundation
import Vapor
import Fluent

class LogController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("standard", ":year", ":date", use: getStandardLogs)
        routes.get("access", use: getAccessLogs)
    }

    func getStandardLogs(_ request: Request) throws -> String {
        guard let year = request.parameters.get("year"),
            let date = request.parameters.get("date") else {
            throw Abort(.badRequest)
        }

        let path = Application.shared.directory.logsDirectory + "Standard/\(year)/\(date).log"
        guard FileManager.default.fileExists(atPath: path) else {
            return ""
        }
        let content = try String(contentsOfFile: path)
        return content
    }
    
    func getAccessLogs(_ request: Request) throws -> EventLoopFuture<Page<AccessLog>> {
        let type = try request.query.get(String.self, at: "type")
        let query = AccessLog.query(on: request.db)
        if type == "normal" {
            query.filter(\.$path, .contains(inverse: true, .prefix), "/logs/")
        }
        return query.sort(\.$createdAt, .descending).paginate(for: request)
    }
}
