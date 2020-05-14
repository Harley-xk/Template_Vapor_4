//
//  AccessLog.swift
//  App
//
//  Created by Harley-xk on 2020/3/10.
//

import Fluent
import Foundation
import Vapor

final class AccessLog: Model {
    static var schema = "AccessLog"
    
    @ID(custom: "id")
    var id: Int?
    
    // 访问者的 ip 地址
    @Field(key: "ip")
    var ip: String?

    // 访问时间
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    // 访问的路由
    @Field(key: "path")
    var path: String
    
    // http 请求的内容
    @Field(key: "request")
    var request: RequestLog
    
    // http 请求的内容
    @Field(key: "response")
    var response: ResponseLog
    
    init() {}
    
    init(request req: Request, response res: Result<Response, Error>) {
        self.ip = req.remoteAddress
        self.path = req.url.description
        self.request = RequestLog(req)
        /// 获取日志的接口不记录返回的日志信息，否则会造成无限嵌套
        do {
            let resp = try res.get()
            self.response = ResponseLog(resp, hidesBody: self.path.contains("api/admin/logs"))
        } catch {
            self.response = ResponseLog(error: error)
        }
    }
}

struct RequestLog: Codable {
    var method: String
    var url: String
    var query: String?
    var headers: String
    var body: String
    
    init(_ request: Request) {
        self.method = request.method.string
        self.url = request.url.path
        self.query = request.url.query
        self.headers = request.headers.debugDescription
        self.body = request.body.string ?? ""
    }
}

struct ResponseLog: Codable {
    var status: Int
    var headers: String
    var body: String?
    
    init(_ response: Response, hidesBody: Bool = false) {
        self.status = Int(response.status.code)
        self.headers = response.headers.debugDescription
        self.body = hidesBody ? "<Object>" : response.body.description
    }
    
    init(error: Error) {
        self.status = -1
        self.headers = ""
        self.body = error.localizedDescription
    }
}

extension Request {
    
    var remoteAddress: String? {
        if Application.shared.environment == .development {
            let random = { return Int.random(in: 1 ... 100) }
            return "\(random()).\(random()).\(random()).\(random())"
        } else {
            // 服务器通过 Caddy 转发，实际 IP 在这个字段（需要在 caddy 配置文件指定）
            return headers.first(name: "X-Real-Ip") ?? "Unknown"
        }
    }
}

extension Response {
    func description(withBody: Bool) -> String {
        var desc: [String] = []
        desc.append("HTTP/\(self.version.major).\(self.version.minor) \(self.status.code) \(self.status.reasonPhrase)")
        desc.append(self.headers.debugDescription)
        if withBody {
            desc.append(self.body.description)
        } else {
            desc.append("<Object>")
        }
        return desc.joined(separator: "\n")
    }
}
