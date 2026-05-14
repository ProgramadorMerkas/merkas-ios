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
    
    private var withoutUser: Bool {
        token.isEmpty || correo.isEmpty || contrasena.isEmpty
    }
    
    var body: some View {
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
                // 1. Intentar login si hay credenciales guardadas
                if !withoutUser {
                    await signIn()
                }
                // 2. Si tras el signIn el token sigue vacío, pedirlo
                if token.isEmpty {
                    await getToken()
                } else {
                    stopLoading()
                }
            }
        }
    }
    
    // MARK: - Obtener Token
    private func getToken() async {
        startLoading()
        do {
            let newToken = try await TokenService.obtenerToken(baseURL: baseURL)
            token = newToken // ✅ Guardar en AppStorage
            print("Token guardado:", token)
        } catch let error as TokenError {
            print("Error obteniendo token:", error.localizedDescription)
            switch error {
            case .NotConnection:
                // TODO: Mostrar banner/alerta de sin red
                break
            case .timeout:
                // Reintento automático una vez
                print("Timeout, reintentando...")
                await getToken()
                return
            default:
                break
            }
        } catch {
            print("Error inesperado:", error.localizedDescription)
        }
        stopLoading()
    }
    
    // MARK: - Sign In
    private func signIn() async {
        startLoading()
        do {
            let loginData = LoginData(correo: correo, contrasena: contrasena, token: token)
            let result = try await LoginService.shared.login(data: loginData)
            
            switch result {
            case .success(let user):
                print("Usuario:", user.usuarioNombreCompleto)
                appState.user = user
                appState.isLoggedIn = true
                loggedIn = true
                stopLoading()
                
            case .failure(let mensaje):
                print("Error del servidor:", mensaje)
                if mensaje.contains("token_incorrecto") {
                    // Refrescar token y reintentar login UNA sola vez
                    await getToken()
                    if !token.isEmpty {
                        await signInOnce() // ✅ Evita recursión infinita
                    } else {
                        signOut()
                    }
                } else {
                    signOut()
                }
            }
        } catch {
            print("Error login:", error)
            stopLoading()
        }
    }
    
    /// Login sin reintentos (usado tras refrescar token)
    private func signInOnce() async {
        do {
            let loginData = LoginData(correo: correo, contrasena: contrasena, token: token)
            let result = try await LoginService.shared.login(data: loginData)
            switch result {
            case .success(let user):
                appState.user = user
                appState.isLoggedIn = true
                loggedIn = true
            case .failure(let mensaje):
                print("Login falló tras refrescar token:", mensaje)
                signOut()
            }
        } catch {
            print("Error en signInOnce:", error)
            signOut()
        }
        stopLoading()
    }
    
    // MARK: - Helpers
    private func startLoading() {
        appState.isLoading = true
        isLoading = true
    }
    
    private func stopLoading() {
        appState.isLoading = false
        isLoading = false
    }
    
    private func signOut() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        appState.isLoggedIn = false
        loggedIn = false
        stopLoading()
    }
}
/*struct ContentView: View {
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
            /*if let newToken = try await TokenService.obtenerToken(baseURL: baseURL) {
                token = newToken
                print("Token guardado en AppStorage:", token)
                appState.isLoading = false
                isLoading = false
            } else {
                print("No se recibió token válido")
                appState.isLoading = false
                isLoading = false
            }*/
            let newToken = try await TokenService.obtenerToken(baseURL: baseURL)
            appState.isLoading = false
            isLoading = false
            print("Token obtenido: \(token)")
        } catch let error as TokenError{
            
            print("Error obteniendo token:", error.localizedDescription)
            switch error {
            case .NotConnection:
                break
            case .timeout:
                //reintentar
                break
            default:
                break
            }
            appState.isLoading = false
            isLoading = false
        }catch {
            print("Erros inesperado: \(error.localizedDescription)")
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
}*/
