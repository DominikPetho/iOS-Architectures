//
//  File.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 16/07/2024.
//

import SwiftUI

struct AlbumsGridView: View {

    @State var viewModel: AlbumsGridViewModel

    private var isLoadingFullScreen: Bool {
        viewModel.isLoadingAlbums && viewModel.albums.isEmpty
    }

    @ViewBuilder var body: some View {
        ZStack {
            if isLoadingFullScreen {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                ScrollView {
                    if viewModel.albums.isEmpty {
                        emptyView
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible(minimum: 100, maximum: 200), spacing: 8),
                            GridItem(.flexible(minimum: 100, maximum: 200), spacing: 8)
                        ]) {
                            ForEach(viewModel.albums) {
                                gridItem(album: $0)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollContentBackground(.hidden)
        .background(.gray.opacity(0.1))
        .animation(.default, value: viewModel.albums)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Load & Trim") {
                    viewModel.loadAndTrim()
                }
            }
        }
        .refreshable {
            await viewModel.load()
        }
        .task {
            await viewModel.subscribe()
            if viewModel.albums.isEmpty {
                await viewModel.load()
            }
        }
    }

    // MARK: - Components

    private var emptyView: some View {
        ZStack {
            Text("List is empty")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func gridItem(album: Album) -> some View {
        Button {
            viewModel.coordinator.perform(step: .openDetail(album))
        } label: {
            VStack {
                AsyncImage(url: URL(string: album.url)) { phase in
                    switch phase {
                    case .failure: 
                        Image(systemName: "photo") .font(.largeTitle)
                    case .success(let image):
                        image.resizable()
                    default:
                        ProgressView()
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .center) {
                    Text("\(album.id)").bold()
                    Text(album.title).bold().font(.caption)
                }
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

}
