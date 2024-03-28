//
//  File.swift
//  
//
//  Created by Simon Zwicker on 27.03.24.
//

import Foundation

public class RequestImage {
    public let fileName: String
    public let type: ImageType
    public let data: Data
    public let parameter: String
    public let boundary: String

    public init(fileName: String, type: ImageType, data: Data, parameter: String, boundary: String) {
        self.fileName = fileName
        self.type = type
        self.data = data
        self.parameter = parameter
        self.boundary = boundary
    }
}
