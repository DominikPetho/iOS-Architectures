//
//  ContentView.swift
//  Sample App 1
//
//  Created by Dominik Pethö on 10/07/2024.
//

import SwiftUI
import Combine

public extension Future where Failure == Never {

    convenience init(asyncFunc: @escaping () async -> Output) {
        self.init { promise in            
            Task {
                let result = await asyncFunc()
                await MainActor.run {
                    promise(.success(result))
                }
            }
        }
    }

}

