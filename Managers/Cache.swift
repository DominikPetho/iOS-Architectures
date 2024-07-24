//
//  Cache.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 16/07/2024.
//

import Foundation

actor Cache {

    static let shared = Cache()

//    var albums: [Album] = []
    var onAlbumsChange: [([Album]) -> ()] = []
    @Published var albums: [Album] = []

    func subscribeOnAlbumChange(_ action: @escaping ([Album]) -> ()) async {
        onAlbumsChange.append(action)
    }

    func cache(albums: [Album]) async {
        self.albums = albums
        onAlbumsChange.forEach { $0(albums) }
    }

    func remove(album: Album) async {
        try? await Task.sleep(for: .seconds(5))

        self.albums.removeAll(where: { $0.id == album.id })

        onAlbumsChange.forEach { $0(self.albums) }
    }

}
