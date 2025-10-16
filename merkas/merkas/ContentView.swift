//
//  ContentView.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 27/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage(StorageKeys.LOGGED_IN.rawValue) private var loggedIn: Bool = false
    @AppStorage(StorageKeys.TOKEN.rawValue) private var token: String = ""
    @AppStorage(StorageKeys.CORREO.rawValue) private var correo: String = ""
    @AppStorage(StorageKeys.CONTRASENA.rawValue) private var contrasena: String = ""
    
    @State var isLoading: Bool = true
    
    var body: some View {
        let withoutUser: Bool = token.isEmpty || correo.isEmpty || contrasena.isEmpty
        
        ZStack {
            Router()
            
            if isLoading {
                Loading()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .onAppear {
            appState.isLoggedIn = loggedIn
            
            Task {
                if !withoutUser {
                    await signIn(withoutUser)
                }
                
                if token.isEmpty {
                    await getToken()
                } else {
                    appState.isLoading = false
                    isLoading = false
                }
            }
        }
    }
    
    private func getToken() async {
        appState.isLoading = true
        isLoading = true
        do {
            if let newToken = try await TokenService.obtenerToken(baseURL: baseURL) {
                token = newToken
                print("Token guardado en AppStorage:", token)
                appState.isLoading = false
                isLoading = false
            } else {
                print("No se recibió token válido")
                appState.isLoading = false
                isLoading = false
            }
        } catch {
            print("Error obteniendo token:", error)
            appState.isLoading = false
            isLoading = false
        }
    }
    private func signIn(_ withoutUser: Bool) async {
        Task {
            appState.isLoading = true
            isLoading = true
            do {
                let loginData = LoginData(correo: correo, contrasena: contrasena, token: token)
                let result = try await LoginService.shared.login(data: loginData)
                
                switch result {
                case .success(let user):
                    print("Usuario:", user.usuarioNombreCompleto)
                    appState.user = user
                    appState.isLoggedIn = true
                    loggedIn = true
                    isLoading = false
                    appState.isLoading = false
                case .failure(let mensaje):
                    print("Error del servidor:", mensaje)
                    //errorInSignIn = true
                    if mensaje.contains("token_incorrecto") {
                        if !withoutUser {
                            await getToken()
                            await signIn(withoutUser)
                            appState.isLoading = false
                            isLoading = false
                        } else {
                            signOut()
                        }
                    } else {
                        signOut()
                    }
                }
            } catch {
                print("Error login:", error)
                isLoading = false
                appState.isLoading = false
                isLoading = false
            }
        }
    }
    private func signOut() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        appState.isLoggedIn = false
        loggedIn = false
        isLoading = false
    }
}

#Preview {
    ContentView()
}
