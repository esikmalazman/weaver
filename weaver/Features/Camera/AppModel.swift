//
//  AppModel.swift
//  camera
//
//  Created by Event on 8/8/26.
//

import SwiftUI

/// Maintains app-wide state.
@MainActor
@Observable
final class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    let handSessionController = HandSessionController()

    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    var immersiveSpaceState = ImmersiveSpaceState.closed
}
