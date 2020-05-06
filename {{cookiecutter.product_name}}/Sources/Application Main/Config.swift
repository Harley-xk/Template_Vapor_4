//
//  Config.swift
//
//
//  Created by Harley-xk on 2020/5/5.
//

import Foundation
import Vapor
import Fluent

struct Config {
    struct Server {
        var host: String
        var port: Int
        
        static func detect() -> Server {
            return Server(
                host: .env(.server_host, default: "0.0.0.0"),
                port: .env(.server_port, default: 8080)
            )
        }
    }
    
    struct MySQL {
        var host: String
        var port: Int
        var username: String
        var password: String
        var name: String
        
        static func detect() -> MySQL {
            return MySQL(
                host: .env(.mysql_host, default: "localhost"),
                port: .env(.mysql_port, default: 3306),
                username: .env(.mysql_username, default: "root"),
                password: .env(.mysql_password, default: "root"),
                name: .env(.mysql_name, default: "")
            )
        }
    }
    
    struct PostgreSQL {
        var host: String
        var port: Int
        var username: String
        var password: String
        var name: String
        
        static func detect() -> PostgreSQL {
            return PostgreSQL(
                host: .env(.postgres_host, default: "localhost"),
                port: .env(.postgres_port, default: 5432),
                username: .env(.postgres_username, default: "root"),
                password: .env(.postgres_password, default: "123456"),
                name: .env(.postgres_name, default: "")
            )
        }
    }
    
    struct Webhook {
        var token: String
        static func detect() -> Webhook {
            return Webhook(
                token: .env(.webhook_token, default: "abcdefg")
            )
        }
    }
    
    var server: Server
    var database: PostgreSQL
    
    var webhook: Webhook

    static let global = Config()
    
    private init() {
        server = .detect()
        database = .detect()
        webhook = .detect()

    }
}

// MARK: - Environment Values

extension Environment {
    enum Key: String {
        case server_host = "SERVER_HOST"
        case server_port = "SERVER_PORT"
        
        case mysql_host = "MYSQL_HOST"
        case mysql_port = "MYSQL_PORT"
        case mysql_username = "MYSQL_USERNAME"
        case mysql_password = "MYSQL_PASSWORD"
        case mysql_name = "MYSQL_NAME"
        
        case postgres_host = "POSTGRES_HOST"
        case postgres_port = "POSTGRES_PORT"
        case postgres_username = "POSTGRES_USERNAME"
        case postgres_password = "POSTGRES_PASSWORD"
        case postgres_name = "POSTGRES_NAME"
        
        case webhook_token = "WEBHOOK_TOKEN"
    }
}

extension String {
    static func env(_ key: Environment.Key) -> Self? {
        return Environment.get(key.rawValue)
    }
    
    static func env(_ key: Environment.Key, default def: String) -> String {
        return Environment.get(key.rawValue) ?? def
    }
}

extension LosslessStringConvertible {
    static func env(_ key: Environment.Key) -> Self? {
        if let value = Environment.get(key.rawValue) {
            return Self(value)
        }
        return nil
    }
    
    static func env(_ key: Environment.Key, default def: Self) -> Self {
        return Self.env(key) ?? def
    }
}

// MARK: - Config Factories

extension DatabaseConfigurationFactory {
    
    static func postgres(_ config: Config) -> DatabaseConfigurationFactory {
        return .postgres(
            hostname: config.database.host,
            port: config.database.port,
            username: config.database.username,
            password: config.database.password,
            database: config.database.name
        )
    }
}
