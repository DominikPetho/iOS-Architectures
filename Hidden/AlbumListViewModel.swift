//
//  AlbumsListViewModel.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 16/07/2024.
//

import Foundation
import GoodStructs

@Observable
class AlbumsListViewModel {

    enum Action {
        case load
        case loadAndTrim
    }

    private let albumsFetcher: AlbumFetcher = .init()

    var albumsResult:  GRResult<[Album], Nothing>
    private var isSubscribed: Bool = false

    let coordinator: Coordinator

    init(albums: [Album] = [], coordinator: Coordinator) {
        self.albumsResult = albums.isEmpty ? .loading : .success(albums)
        self.coordinator = coordinator
    }

    // MARK: - Logic

    func subscribe() async {
        isSubscribed = true
        await Cache.shared.subscribeOnAlbumChange {
            Task { @MainActor in
                self.albumsResult = .success(Cache.shared.albums)
            }
        }
    }

    func call(_ action: Action) async {
        switch action {
        case .load:
            await load()

        case .loadAndTrim:
            await loadAndTrimTitle()
        }
    }

    // MARK: - Privates

    private func load() async {
        if let albums = try? albumsResult.unwrapSuccess(), albums.isEmpty {
            albumsResult = .loading
        }
        let albums = await albumsFetcher.fetchAlbums()
        await Cache.shared.cache(albums: albums)
        albumsResult = .success(albums)
    }

    private func loadAndTrimTitle() async {
        if let albums = try? albumsResult.unwrapSuccess(), albums.isEmpty {
            albumsResult = .loading
        }
        let albums = await albumsFetcher.fetchAlbums()
        var newAlbums = [Album]()
        for album in albums {
            newAlbums.append(await albumsFetcher.trimTitle(album: album))
        }

        self.albumsResult = .success(newAlbums)
        await Cache.shared.cache(albums: newAlbums)
    }

}
