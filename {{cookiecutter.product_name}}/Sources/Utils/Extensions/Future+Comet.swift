//
//  Fluent+Comet.swift
//  
//
//  Created by Harley-xk on 2020/5/6.
//

import Foundation
import Vapor

extension EventLoopFuture {
    public func tryFlatMap<NewValue>(
        file: StaticString = #file,
        line: UInt = #line,
        _ callback: @escaping (Value) throws -> EventLoopFuture<NewValue>
    ) -> EventLoopFuture<NewValue> {
        return flatMap { (value) -> EventLoopFuture<NewValue> in
            do {
                return try callback(value)
            } catch {
                return self.eventLoop.future(error: error)
            }
        }
    }
    
    public func tryMap<NewValue>(
        file: StaticString = #file,
        line: UInt = #line,
        _ callback: @escaping (Value) throws -> NewValue
    ) -> EventLoopFuture<NewValue> {
        return flatMapResult { (value) -> Result<NewValue, Error> in
            do {
                let newValue = try callback(value)
                return .success(newValue)
            } catch {
                return .failure(error)
            }
        }
    }
}
