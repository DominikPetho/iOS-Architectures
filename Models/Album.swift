//
//  Album.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 16/07/2024.
//

import Foundation

struct Album: Codable, Identifiable, Equatable {
    let albumId: Int
    let id: Int
    var title: String
    let url: String
    let thumbnailUrl: String
}
