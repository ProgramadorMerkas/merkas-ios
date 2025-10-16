//
//  merkasApp.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 27/9/25.
//

import SwiftUI

@main
struct merkasApp: App {
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(appState)
                
                if appState.isLoading {
                    Loading()
                        .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: appState.isLoading)
        }
    }
}
