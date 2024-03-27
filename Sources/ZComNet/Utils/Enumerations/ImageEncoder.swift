//
//  ImageEncoder.swift
//
//
//  Created by Simon Zwicker on 27.03.24.
//

import Foundation

enum ImageEncoder {
    case boundary(String)
    case contentDisposition(params: String, filename: String)
    case contentType(String)
}

extension ImageEncoder {
    var data: Data? {
        switch self {
        case .boundary(let boundary):
            return "\r\n--\(boundary)\r\n".data(using: .utf8)

        case .contentDisposition(let params, let filename):
            return "Content-Disposition: form-data; name=\"\(params)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)

        case .contentType(let type):
            return "Content-Type: \(type)\r\n\r\n".data(using: .utf8)
        }
    }
}
