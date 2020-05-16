//
//  SearchResponse.swift
//  VirtualTourist
//
//  Created by Adrià Sala Roget on 12/05/2020.
//  Copyright © 2020 Adrià Sala Roget. All rights reserved.
//

import Foundation

struct SearchResponse: Codable {
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [PhotoInfo]
}

struct PhotoInfo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
