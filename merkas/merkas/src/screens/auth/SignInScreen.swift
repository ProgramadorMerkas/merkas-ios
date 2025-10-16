//
//  SignInScreen.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI

struct SignInScreen: View {
    @EnvironmentObject var appState: AppState
    @AppStorage(StorageKeys.TOKEN.rawValue) private var token: String = ""
    @AppStorage(StorageKeys.LOGGED_IN.rawValue) private var loggedIn: Bool = false
    @AppStorage(StorageKeys.CORREO.rawValue) private var correo: String = ""
    @AppStorage(StorageKeys.CONTRASENA.rawValue) private var contrasena: String = ""
    
    @State private var isLoadingSignIn: Bool = false
    // Email Field
    @State private var emailText: String = ""
    @State private var emailStatus: InputStatusType = .initial
    // Password Field
    @State private var passwordText: String = ""
    @State private var passwordStatus: InputStatusType = .initial
    @State private var passwordMsmWarning: String = ""
    @State private var passwordShow: Bool = false
    
    @State private var errorInSignIn: Bool = false
    @State private var showForgotPassword: Bool = false
    
    var body: some View {
        let signInBtnDisabled: Bool = emailStatus != .good || passwordStatus != .good || isLoadingSignIn
        let (emailRegex, _, _) = regexes()
        
        VStack {
            ScrollView {
                VStack {
                    Input(
                        label: "email",
                        required: true,
                        text: $emailText,
                        placeholder: "writeEmail",
                        inputStatus: $emailStatus,
                        msmError: "writeValidEmail",
                        keyboardType: .emailAddress,
                        replacementPattern: (pattern: emailRegex, with: ""),
                        onFocused: {
                            validateField(emailText, .email)
                        }
                    )
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    
                    Input(
                        label: "password",
                        required: true,
                        text: $passwordText,
                        placeholder: "writePassword",
                        inputStatus: $passwordStatus,
                        msmError: "fieldRequired",
                        msmWarning: "",
                        onFocused: {
                            validateField(passwordText, .password)
                        },
                        isPassword: true,
                        isShowPassword: passwordShow,
                        changeVisibilityPassword: {
                            passwordShow.toggle()
                        }
                    )
                    
                    HStack {
                        if errorInSignIn {
                            Label("signInError", systemImage: "exclamationmark.circle")
                                .font(.callout)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.leading)
                                .padding(.bottom, 10)
                            
                            Spacer()
                        }
                    }
                    //.animation(.easeInOut(duration: 0.3), value: errorInSignIn)
                    
                    Button(action: {
                        showForgotPassword = true
                    }) {
                        HStack {
                            Text("forgotPassord")
                                .font(.callout.bold())
                                .underline()
                                .foregroundStyle(.merkas.opacity(0.8))
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 0)
                        .padding(.vertical, 5)
                    }
                    .padding(.bottom, 10)
                    .sheet(isPresented: $showForgotPassword, content: {
                        //ForgotPasswordScreen()
                        SafariView(url: URL(string: "https://app.merkas.co/#/reset-password")!)
                            .interactiveDismissDisabled(true)
                    })
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 30)
                .padding(.horizontal, 30)
            }
            
            VStack {
                Button (action: {
                    Task {
                        await signIn()
                    }
                }) {
                    ZStack {
                        if isLoadingSignIn {
                            ProgressView()
                                .tint(.white)
                                .font(.footnote.bold())
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(.screenSignIn)
                                .font(.footnote.bold())
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isLoadingSignIn)
                }
                .disabled(signInBtnDisabled)
                .buttonStyle(.glassProminent)
                .onPressImpact(.soft)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 15)
        }
        .hideKeyboardOnTap()
        .navigationTitle(.screenSignIn)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private enum FieldTypeEnum {
        case email
        case password
    }
    
    private func validateField (_ text: String, _ type: FieldTypeEnum) {
        switch type {
        case .email:
            let isValid = isValidEmail(text)
            if !isValid {
                emailStatus = .error
            } else {
                emailStatus = .good
            }
        case .password:
            //let isValid = validatePassword(text).minLength
            //if !isValid {
            //    passwordStatus = .error
            //}
            print("")
            passwordStatus = .good
        }
    }
    
    private func signIn() async {
        Task {
            isLoadingSignIn = true
            errorInSignIn = false
            
            do {
                let loginData = LoginData(correo: emailText, contrasena: passwordText, token: token)
                let result = try await LoginService.shared.login(data: loginData)
                
                switch result {
                case .success(let user):
                    print("Usuario:", user.usuarioNombreCompleto)
                    correo = emailText
                    contrasena = passwordText
                    appState.user = user
                    appState.isLoggedIn = true
                    loggedIn = true
                case .failure(let mensaje):
                    print("Error del servidor:", mensaje)
                    if mensaje.contains("token_incorrecto") || mensaje.contains("token_vencido") {
                        await getToken()
                    } else {
                        errorInSignIn = true
                    }
                }
                isLoadingSignIn = false
            } catch {
                print("Error login:", error)
                isLoadingSignIn = false
            }
        }
    }
    private func getToken() async {
        isLoadingSignIn = true
        do {
            if let newToken = try await TokenService.obtenerToken(baseURL: baseURL) {
                token = newToken
                print("Token guardado en AppStorage:", token)
                await signIn()
            } else {
                print("No se recibió token válido")
                isLoadingSignIn = false
                errorInSignIn = true
            }
        } catch {
            print("Error obteniendo token:", error)
            isLoadingSignIn = false
            errorInSignIn = true
        }
    }
}

#Preview {
    SignInScreen()
}
