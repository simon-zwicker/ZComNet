//
//  URLRequest.swift
//
//
//  Created by Simon Zwicker on 27.03.24.
//

import Foundation

extension URLRequest {
    
    public func curl() -> String {
        guard let url else { return "noURL" }
        var command = ["curl \"\(url.absoluteString)\""]

        if let httpMethod, httpMethod != RequestMethod.get.rawValue, httpMethod != RequestMethod.head.rawValue {
            command.append(" -x \(httpMethod)")
        }

        allHTTPHeaderFields?
            .filter {
                $0.key != RequestHeader.cookie.key
            }
            .forEach {
                command.append(" -H '\($0.key): \($0.value)'")
            }

        if let httpBody, let body = String(data: httpBody, encoding: .utf8) {
            command.append(" -d \(body)")
        }

        return command.joined()
    }
}
