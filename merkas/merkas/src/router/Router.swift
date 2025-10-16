//
//  Router.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI

struct Router: View {
    @EnvironmentObject var appState: AppState
    @AppStorage(StorageKeys.TOKEN.rawValue) private var token: String = ""
    @AppStorage(StorageKeys.LOGGED_IN.rawValue) private var loggedIn: Bool = false
    @AppStorage(StorageKeys.CORREO.rawValue) private var correo: String = ""
    @AppStorage(StorageKeys.CONTRASENA.rawValue) private var contrasena: String = ""
    
    var body: some View {
        let isLoggedIn: Bool = appState.isLoggedIn
        
        ZStack {
            if !isLoggedIn {
                NavigationStack {
                    IntroScreen()
                }
            } else {
                MerkasNavigator()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoggedIn)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    Router()
}
