//
//  AlbumDetailViewReactor.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 16/07/2024.
//

import Combine
import Foundation

final class FakeCoordinator: GoodCoordinator<AppStep> {}

final class AlbumDetailReactor: GoodReactor {

    var initialState: State
    var customCancellables: Set<AnyCancellable> = .init()

    struct State {
        var isLoading: Bool
        var album: Album
        var albumIsDeleted: Bool = false
        var isFinished = false
    }

    enum Action {
        case delete
        case finished
        case albumIsDeleted
    }

    var coordinator: GoodCoordinator<AppStep> = FakeCoordinator()

    init(album: Album) {
        self.initialState = .init(isLoading: false, album: album)
        self.start()
    }

    deinit {
        debugPrint("VM deinitialized \(currentState.album.id)")
    }

    func navigate(action: Action) -> AppStep? {
        switch action {
        case .delete:
            return .pop

        default:
            return nil
        }
    }

    func mutate(action: Action) -> AnyPublisher<Action, Never> {
        switch action {
        case .delete:
            return Future(
                asyncFunc: { [unowned self] in
                    await Cache.shared.remove(album: currentState.album)
                }
            )
            .flatMap { _ in [Action.albumIsDeleted, Action.finished].publisher }
            .prepend(Action.delete)
            .eraseToAnyPublisher()

        case .albumIsDeleted, .finished:
            return Just(action).eraseToAnyPublisher()
        }
    }

    func reduce(state: State, mutation: Action) -> State {
        var state = state
        switch mutation {
        case .delete:
            state.isLoading = true

        case .albumIsDeleted:
            state.isLoading = false
            state.albumIsDeleted = true

        case .finished:
            state.isFinished = true
        }
        return state
    }

}
