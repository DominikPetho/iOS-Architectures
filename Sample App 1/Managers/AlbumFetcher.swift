//
//  AlbumFetcher.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 16/07/2024.
//

import Foundation

actor AlbumFetcher {

    func fetchAlbums() async -> [Album] {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/photos") else {
            print("Invalid URL")
            return []
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            try await Task.sleep(for: .seconds(2))
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response from server")
                return []
            }

            let decodedData = try JSONDecoder().decode([Album].self, from: data)
            return decodedData
        } catch {
            print("Error while fetching data: \(error.localizedDescription)")
        }

        return []
    }

    func trimTitle(album: Album) -> Album {
        var album = album
        album.title = String(album.title.prefix(10))
        return album
    }
}
