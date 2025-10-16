//
//  SignUpScreen.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI

struct SignUpScreen: View {
    @EnvironmentObject var appState: AppState
    @AppStorage(StorageKeys.TOKEN.rawValue) private var token: String = ""
    @AppStorage(StorageKeys.LOGGED_IN.rawValue) private var loggedIn: Bool = false
    @AppStorage(StorageKeys.CORREO.rawValue) private var correo: String = ""
    @AppStorage(StorageKeys.CONTRASENA.rawValue) private var contrasena: String = ""
    
    @State private var isLoadingSignUp: Bool = false
    
    // Email Field
    @State private var emailText: String = ""
    @State private var emailStatus: InputStatusType = .initial
    // Password Field
    @State private var passwordText: String = ""
    @State private var passwordStatus: InputStatusType = .initial
    @State private var passwordMsmWarning: String = ""
    @State private var passwordShow: Bool = false
    
    // USER
    // Name Field
    @State private var nameText: String = ""
    @State private var nameStatus: InputStatusType = .initial
    // Surnames Field
    @State private var surnamesText: String = ""
    @State private var surnamesStatus: InputStatusType = .initial
    // Phone Number Field
    @State private var phoneIndicativeText: String = "57"
    @State private var phoneIndicativeStatus: InputStatusType = .initial
    // Phone Number Field
    @State private var phoneNumberText: String = ""
    @State private var phoneNumberStatus: InputStatusType = .initial
    
    @State private var errorInSignIn: Bool = false
    @State private var errorInSignUp: Bool = false
    
    var body: some View {
        let formUserDataInvalid: Bool = nameStatus != .good || surnamesStatus != .good || phoneNumberStatus != .good
        let signUpBtnDisabled: Bool = emailStatus != .good || passwordStatus != .good || formUserDataInvalid || isLoadingSignUp
        let (emailRegex, namesRegex, phoneNumberRegex) = regexes()
        
        VStack {
            ScrollView {
                Section(.signUpFormUser) {
                    Input(
                        label: "formName",
                        required: true,
                        text: $nameText,
                        placeholder: "formWriteName",
                        inputStatus: $nameStatus,
                        msmError: "fieldRequired",
                        msmWarning: "fieldInvalid",
                        replacementPattern: (pattern: namesRegex, with: ""),
                        onFocused: {
                            validateFieldForm(nameText, .name, $nameStatus)
                        }
                    )
                    .textContentType(.givenName)
                    .autocapitalization(.words)
                    
                    Input(
                        label: "formSurnames",
                        required: true,
                        text: $surnamesText,
                        placeholder: "formWriteSurnames",
                        inputStatus: $surnamesStatus,
                        msmError: "fieldRequired",
                        msmWarning: "fieldInvalid",
                        replacementPattern: (pattern: namesRegex, with: ""),
                        onFocused: {
                            validateFieldForm(surnamesText, .surnames, $surnamesStatus)
                        }
                    )
                    .textContentType(.familyName)
                    .autocapitalization(.words)
                    
                    Input(
                        label: "formPhoneNumber",
                        required: true,
                        text: $phoneNumberText,
                        menuCodesDisabled: true,
                        placeholder: "formPhoneNumberExample",
                        inputStatus: $phoneNumberStatus,
                        msmError: "fieldRequired",
                        msmWarning: "fieldInvalid",
                        replacementPattern: (pattern: phoneNumberRegex, with: ""),
                        maxLenght: 10,
                        onFocused: {
                            validateFieldForm(phoneNumberText, .phoneNumber, $phoneNumberStatus)
                        },
                        isPhoneNumber: true,
                        phoneIndicativeText: phoneIndicativeText
                    )
                    .textContentType(.telephoneNumber)
                }
                .padding(.top, 20)
                .padding(.horizontal, 30)
                
                Section(.signUpFormAuth) {
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
                            placeholder: "createAPassword",
                            inputStatus: $passwordStatus,
                            msmError: "fieldRequired",
                            msmWarning: "passwordInvalid",
                            onFocused: {
                                validateField(passwordText, .password)
                            },
                            isPassword: true,
                            isShowPassword: passwordShow,
                            changeVisibilityPassword: {
                                passwordShow.toggle()
                            },
                            showItemsForCreatePassword: true
                        )
                        .textContentType(.newPassword)
                        
                        HStack {
                            if errorInSignUp {
                                Label("signUpError", systemImage: "exclamationmark.circle")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, 10)
                                
                                Spacer()
                            }
                            if errorInSignIn {
                                Label("signInError", systemImage: "exclamationmark.circle")
                                    .font(.callout)
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, 10)
                                
                                Spacer()
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: errorInSignIn)
                        .animation(.easeInOut(duration: 0.3), value: errorInSignUp)
                    }
                }
                .padding(.horizontal, 30)
                
                
            }
            
            VStack {
                Button (action: {
                    Task {
                        await signUp()
                    }
                }) {
                    ZStack {
                        if isLoadingSignUp {
                            ProgressView()
                                .tint(.white)
                                .font(.footnote.bold())
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(.screenSignUp)
                                .font(.footnote.bold())
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isLoadingSignUp)
                }
                .disabled(signUpBtnDisabled)
                .buttonStyle(.glassProminent)
                .onPressImpact(.soft)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 15)
        }
        .navigationTitle(.screenSignUp)
        .navigationBarTitleDisplayMode(.large)
        .hideKeyboardOnTap()
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
            }
        case .password:
            let isValid = validatePassword(text).isValidPassword
            if !isValid {
                if text.isEmpty {
                    passwordStatus = .error
                } else {
                    passwordStatus = .warning
                }
            }
        }
    }
    
    private func signUp() async {
        Task {
            isLoadingSignUp = true
            
            do {
                let data = RegisterData(
                    nombre: nameText,
                    apellido: surnamesText,
                    telefono: phoneNumberText,
                    correo: emailText,
                    contrasena: passwordText,
                    token: token
                )
                
                let result = try await RegisterService.shared.register(data: data, title: "registro")
                
                switch result {
                case .success(let success):
                    print("Registro exitoso:", success.validacion)
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
                case .failure(let mensaje):
                    print("Error registro:", mensaje)
                    errorInSignUp = true
                }
                isLoadingSignUp = false
            } catch {
                print("Error registro:", error)
                isLoadingSignUp = false
            }
        }
    }
    private func getToken() async {
        isLoadingSignUp = true
        do {
            if let newToken = try await TokenService.obtenerToken(baseURL: baseURL) {
                token = newToken
                print("Token guardado en AppStorage:", token)
                await signUp()
            } else {
                print("No se recibió token válido")
                isLoadingSignUp = false
                errorInSignIn = true
            }
        } catch {
            print("Error obteniendo token:", error)
            isLoadingSignUp = false
            errorInSignIn = true
        }
    }
}

enum FormFieldType {
    case name
    case surnames
    case phoneIndicative
    case phoneNumber
}

func validateFieldForm(
    _ text: String,
    _ type: FormFieldType,
    _ status: Binding<InputStatusType>
) {
    let textEmpty = text.isEmpty
    let textInvalid = text.count < 2
    
    switch type {
    case .name:
        if textEmpty {
            status.wrappedValue = .error
        } else if textInvalid {
            status.wrappedValue = .warning
        } else {
            status.wrappedValue = .good
        }
    case .surnames:
        if textEmpty {
            status.wrappedValue = .error
        } else if textInvalid {
            status.wrappedValue = .warning
        } else {
            status.wrappedValue = .good
        }
    case .phoneNumber:
        if textEmpty {
            status.wrappedValue = .error
        } else if text.count < 9 {
            status.wrappedValue = .warning
        } else {
            status.wrappedValue = .good
        }
    case .phoneIndicative:
        if textEmpty {
            status.wrappedValue = .error
        } else {
            status.wrappedValue = .good
        }
    }
}


#Preview {
    SignUpScreen()
}
