//
//  Config.swift
//
//
//  Created by Harley-xk on 2020/5/5.
//

import Fluent
import Foundation
import Vapor

struct Config: Codable {
    struct Server: Codable {
        var host: String
        var port: Int
    }

    struct Database: Codable {
        var host: String
        var port: Int
        var username: String
        var password: String
        var name: String
    }

    struct Webhook: Codable {
        var token: String
    }

    var server: Server
    var postgres: Database
//    var musql: Database

    var webhook: Webhook

    static var global: Config {
        return _global!
    }

    private static var _global: Config?

    static func detect(environment: Environment) throws -> Config {
        let env = environment.shortName
        let data = try Data(contentsOf: URL(fileURLWithPath: "./config-\(env).json"))
        let config = try JSONDecoder().decode(Config.self, from: data)
        _global = config

        return config
    }
}

// MARK: - Environment Values

extension Environment {
    var shortName: String {
        switch self {
        case .development: return "dev"
        case .production: return "prod"
        case .testing: return "test"
        default: return name
        }
    }
}

// MARK: - Config Factories

extension DatabaseConfigurationFactory {
    static func postgres(_ config: Config) -> DatabaseConfigurationFactory {
        return .postgres(
            hostname: config.postgres.host,
            port: config.postgres.port,
            username: config.postgres.username,
            password: config.postgres.password,
            database: config.postgres.name
        )
    }
}
