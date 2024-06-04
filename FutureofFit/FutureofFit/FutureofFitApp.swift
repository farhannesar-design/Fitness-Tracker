//
//  FutureofFitApp.swift
//  FutureofFit
//
//  Created by Pranay Lunavat on 3/3/24.
//

import SwiftUI

@main
struct FutureofFitApp: App {
    @StateObject private var sharedAccel = SharedAccel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sharedAccel)
        }
    }
}
