//
//  application.swift
//  App
//
//  Created by Harley-xk on 2020/1/29.
//

import Fluent
import FluentPostgresDriver
import Vapor

private var runningApplication: Application!

extension Application {
    static var shared: Application {
        return runningApplication
    }
    
    static func make(environment: Environment) -> Application {
        runningApplication = Application(environment)
        return runningApplication
    }
    
    func configure() throws {
        // uncomment to serve files from /Public folder
        middleware.use(FileMiddleware(publicDirectory: directory.publicDirectory))
        
        // 设置时间 JSON 格式
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        decoder.dateDecodingStrategy = .secondsSince1970
        ContentConfiguration.global.use(decoder: decoder, for: .json)
        ContentConfiguration.global.use(encoder: encoder, for: .json)
        
        // Configure
        let config = Config.global
        
        // 服务器配置
        http.server.configuration.hostname = config.server.host
        http.server.configuration.port = config.server.port
        
        // 数据库配置
        databases.use(.postgres(config), as: .psql)
        
        // 注册路由
        try registerRoutes()
        
        // 处理数据库迁移
        try prepareMigrations()
    }
    
    public func prepareMigrations() throws {
        migrations.add(CreateUser())
        migrations.add(CreateToken())
        migrations.add(CreateAccessLog())

        try autoMigrate().wait()
    }
}
