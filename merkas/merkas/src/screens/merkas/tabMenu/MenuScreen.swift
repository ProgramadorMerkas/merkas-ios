//
//  MenuScreen.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 29/9/25.
//

import SwiftUI

struct MenuScreen: View {
    @EnvironmentObject var appState: AppState
    @AppStorage(StorageKeys.LOGGED_IN.rawValue) private var loggedIn: Bool = false
    @AppStorage(StorageKeys.TOKEN.rawValue) private var token: String = ""
    @AppStorage(StorageKeys.CORREO.rawValue) private var correo: String = ""
    @AppStorage(StorageKeys.CONTRASENA.rawValue) private var contrasena: String = ""
    
    @State private var showAlertSignOut: Bool = false
    @State private var isLoadingSignOut: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Working()
                }
                
                Button (action: {
                    isLoadingSignOut = true
                    showAlertSignOut = true
                }) {
                    ZStack {
                        if isLoadingSignOut {
                            ProgressView()
                                .tint(.white)
                                .font(.footnote.bold())
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        } else {
                            Label(.signOut, systemImage: "iphone.and.arrow.right.outward")
                                .font(.footnote.bold())
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isLoadingSignOut)
                }
                .disabled(isLoadingSignOut)
                .buttonStyle(.glassProminent)
                .onPressImpact(.soft)
                .alert(.signOut, isPresented: $showAlertSignOut) {
                    Button(.signOutAlertNo, role: .cancel) {
                        isLoadingSignOut = false
                    }
                    Button(.signOutAlertYes, role: .destructive) {
                        signOut()
                    }
                } message: {
                    Text(.signOutAlertConfirm)
                }
                .padding(.horizontal, 20)
                
                VersionApp()
            }
            .navigationTitle(.tabMenu)
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func signOut() {
        appState.isLoading = true
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        appState.currentCategoryOffers = "all"
        appState.user = nil
        appState.offers = []
        appState.currentOffers = nil
        appState.isLoggedIn = false
        loggedIn = false
        appState.isLoading = false
        isLoadingSignOut = false
    }
}

#Preview {
    MenuScreen()
}
