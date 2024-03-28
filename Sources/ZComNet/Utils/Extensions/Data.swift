//
//  Data.swift
//
//
//  Created by Simon Zwicker on 27.03.24.
//

import Foundation

public extension Data {
    func decode<T: Codable>(_ type: T.Type) throws -> T {
        let data = try JSONDecoder().decode(T.self, from: self)
        return data
    }
}
