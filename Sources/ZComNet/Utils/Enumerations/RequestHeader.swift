//
//  File.swift
//  
//
//  Created by Simon Zwicker on 27.03.24.
//

public enum RequestHeader: Equatable {
    case cookie
    case contentJson
    case authBearer(String)
//    case formData(String)
//    case encoding
}

extension RequestHeader {
    var key: String {
        switch self {
        case .cookie: "Cookie"
        case .contentJson: "Content-Type"
        case .authBearer: "Authorization"
//        case .encoding: "Content-Transfer-Encoding"
        }
    }

    var value: String {
        switch self {
        case .contentJson: "application/json"
        case .authBearer(let authToken): "Bearer \(authToken)"
//        case .formData(let uuid): "multipart/form-data; boundary=\(uuid)"
//        case .encoding: "base64"
        default: ""
        }
    }
}
