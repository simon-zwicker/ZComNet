//
//  File.swift
//  
//
//  Created by Simon Zwicker on 27.03.24.
//

import Foundation

public struct RequestImage {
    public let fileName: String
    public let type: ImageType
    public let data: Data
    public let parameter: String
    public let boundary: String
}
