//
//  AlbumDetailView.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 16/07/2024.
//

import SwiftUI

struct AlbumDetailView: View {

    @ObservedObject var viewModel: AlbumDetailReactor
    let coordinator: Coordinator

    @State private var deletedAlbumAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: viewModel.currentState.album.url)) { phase in
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
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(viewModel.currentState.album.title)
                    .bold()
                    .font(.title)
            }
        }
        .refreshable {
            await viewModel.send(action: .delete, while: { $0.albumIsDeleted == false })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if viewModel.currentState.isLoading {
                    ProgressView().progressViewStyle(.circular)

                } else {
                    Button("Delete") {
                        viewModel.send(action: .delete)
                        viewModel.send(action: .finished)
                    }
                }
            }
        }
        .navigationTitle("Album \(viewModel.currentState.album.id)")
        .onChange(of: viewModel.currentState.albumIsDeleted) { (old, new) in
            deletedAlbumAlert = new
        }
        .alert(isPresented: $deletedAlbumAlert) {
            Alert(
                title: Text("Info"),
                message: Text("Album was succesfully deleted"),
                dismissButton: .cancel(Text("OK")) {
                    coordinator.perform(step: .pop)
                }
            )
        }

    }
}
