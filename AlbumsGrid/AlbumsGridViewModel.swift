//
//  File.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 16/07/2024.
//

import Foundation
import Combine

@Observable
class AlbumsGridViewModel {

    private let albumsFetcher: AlbumFetcher = .init()
    var albums: [Album] = []
    var isLoadingAlbums = false

    let coordinator: Coordinator
    private var cancellables: Set<AnyCancellable> = .init()

    init(albums: [Album] = [], coordinator: Coordinator) {
        self.albums = albums
        self.coordinator = coordinator       
    }

    func subscribe() async {
        await Cache.shared.$albums
            .receive(on: DispatchSerialQueue(label: "custom"))
            .handleEvents(
                receiveOutput: { _ in
                    print("handleEvents", Thread.isMainThread)
                }
            )
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
            print("sink", Thread.isMainThread)
            self.albums = $0
        }
        .store(in: &cancellables)
//        await Cache.shared.subscribeOnAlbumChange {
//            self.albums = $0
//        }
    }

    func load() async {
        Task.detached { [self]  in
            isLoadingAlbums = true
            self.albums = await albumsFetcher.fetchAlbums()
            await Cache.shared.cache(albums: albums)
            isLoadingAlbums = false
        }
    }

    func loadAndTrim() {
        Task {
            isLoadingAlbums = true
            let albums = await albumsFetcher.fetchAlbums()
            var newAlbums = [Album]()
            for album in albums {
                newAlbums.append(await albumsFetcher.trimTitle(album: album))
            }

            self.albums = newAlbums
            await Cache.shared.cache(albums: newAlbums)
            isLoadingAlbums = false
        }
    }

}
