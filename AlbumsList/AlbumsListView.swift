//
//  File.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 16/07/2024.
//

import SwiftUI

struct AlbumsListView: View {

    @State var viewModel: AlbumsListViewModel

    @ViewBuilder var body: some View {
        ZStack(alignment: .top) {
            switch viewModel.albumsResult {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
            case let .success(albums):
                List(albums) {
                    listCellItem(album: $0)
                }
            case .failure:
                emptyView
            }
        }
        .scrollContentBackground(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.1))
        .animation(.default, value: viewModel.albumsResult)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Load & Trim") {
                    Task {
                        await viewModel.call(.loadAndTrim)
                    }
                }
            }
        }
        .refreshable {
            await viewModel.call(.load)
        }
        .task {
            await viewModel.subscribe()
            if viewModel.albumsResult.isSuccess == false {
                await viewModel.call(.load)
            }
        }
    }

    /// https://dmrz39codqjlj.cloudfront.net/assets/ac532123-eef7-4fd6-8559-9ad14819e68d_Letní%20Partnerská%20sleva.pdf
    // MARK: - Components

    private var emptyView: some View {
        ScrollView {
            ZStack {
                Text("List is empty")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func listCellItem(album: Album) -> some View {
        Button {
            viewModel.coordinator.perform(step: .openDetail(album))
        } label: {
            HStack {
                AsyncImage(url: URL(string: album.url)) { phase in
                    switch phase {
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)

                    case .success(let image):
                        image.resizable()

                    default:
                        ProgressView()
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading) {
                    Text("\(album.id)").bold()
                    Text(album.title).bold().font(.caption)
                }
            }
        }
    }
}
