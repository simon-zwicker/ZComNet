//
//  Endpoint.swift
//
//
//  Created by Simon Zwicker on 27.03.24.
//

import Foundation

public protocol Endpoint {
    var path: String { get }
    var method: RequestMethod { get }
    var headers: [RequestHeader] { get }
    var parameters: [String: Any] { get }
    var object: Codable? { get }
    var encoding: Encoding { get }
}
