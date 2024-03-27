//
//  File.swift
//  
//
//  Created by Simon Zwicker on 27.03.24.
//

public enum ErrorType: Error {
    case decode
    case invalidUrl
    case noResponse
    case noData(Codable)
    case unauthorized(Codable)
    case unexpectedStatusCode(Codable)
    case unknown
}
