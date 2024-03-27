//
//  File.swift
//  
//
//  Created by Simon Zwicker on 27.03.24.
//

import Foundation

struct RequestImage {
    let fileName: String
    let type: ImageType
    let data: Data
    let parameter: String
    let boundary: String
}
