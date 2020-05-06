import Vapor

extension Application {
    /// 注册路由
    func registerRoutes() throws {
        get { _ in
            "Service Powered by Vapor"
        }

        // 接口路由
        let api = grouped("api").grouped(AccessLogMiddleware())

        // 日志接口
        try api.grouped("logs")
            .grouped(Token.authenticator(), AdminGuradMiddleware())
            .register(collection: LogController())

        // 用户认证接口
        try api.grouped("auth").register(collection: AuthController())
    }
}
