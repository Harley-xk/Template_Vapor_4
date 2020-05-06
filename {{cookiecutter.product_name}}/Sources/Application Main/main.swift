import Vapor

/// 检测运行环境
fileprivate var env = try Environment.detect()
/// 启动日志系统
try LoggingSystem.bootstrapDailyLogger(from: &env)
/// 初始化 App
fileprivate let app = Application.make(environment: env)
/// 监测到异常时退出
defer { app.shutdown() }
/// 配置 App
try app.configure()
/// 启动服务器
try app.run()
