//
//  AlbumDetailViewModel.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 16/07/2024.
//

import Foundation
import Combine

@Observable
final class AlbumDetailViewModel {

    let album: Album
    var albums: [Album] = []
    var isLoading = false
    var albumIsDeleted = false

    init(album: Album) {
        self.album = album
    }

    func subscribe() async {
        await Cache.shared.subscribeOnAlbumChange { [weak self] in
            self?.albums = $0
        }
    }

    func deleteAlbum() async {        
        isLoading = true
        await Cache.shared.remove(album: album)
        try? await Task.sleep(for: .seconds(5))
        isLoading = false
        albumIsDeleted = true
    }

}
