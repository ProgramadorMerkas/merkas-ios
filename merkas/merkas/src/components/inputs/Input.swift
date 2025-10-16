//
//  Input.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI

struct Input: View {
    @State var label: LocalizedStringKey
    @State var required: Bool = false
    @Binding var text: String
    var menuCodesDisabled: Bool = false
    var phoneCountryCodeVoid: ((String)-> Void?)? = nil
    var placeholder: LocalizedStringKey
    @Binding var inputStatus: InputStatusType
    var msmError: LocalizedStringKey? = nil
    var msmWarning: LocalizedStringKey? = nil
    var keyboardType: UIKeyboardType?
    var onEditing: (()-> Void?)? = nil
    var replacementPattern: (pattern: NSRegularExpression, with: String)?
    var maxLenght: Int = 999999999999999999
    var onFocused: (()-> Void?)? = nil
    var onSubmit: (()-> Void?)? = nil
    var inputTextColor: Color?
    var errorColor: Color?
    var warningColor: Color?
    var focusColor: Color?
    var unfocusColor: Color?
    var cornerRadius: CGFloat? = 12
    var isPhoneNumber: Bool = false
    var isPassword: Bool = false
    var isShowPassword: Bool?
    var changeVisibilityPassword: (()-> Void?)? = nil
    var showItemsForCreatePassword: Bool? = false
    var initialPhoneCountryCode: String? = ""
    
    @FocusState var focused: Bool
    @State private var passMin8: Bool = false
    @State private var passMinUppercase: Bool = false
    @State private var passMinLowercase: Bool = false
    @State private var passMinSpecial: Bool = false
    @State private var passMinANumber: Bool = false
    @State private var phoneCountryCodeSelected: PhoneCountryCodeProps? = nil
    @State var phoneIndicativeText: String? = nil
    
    var body: some View {
        let borderColor:Color = inputStatus == InputStatusType.error
        ? errorColor ?? Color.red
        : inputStatus == InputStatusType.warning
        ? warningColor ?? Color.yellow
        : focused
        ? focusColor ?? .merkas
        : Color.gray
        let showPassword: Bool = (isShowPassword == nil ? false : isShowPassword) ?? false
        
        VStack {
            HStack {
                Text(label)
                    .foregroundStyle(.gray)
                    .font(.callout)
                    .padding(.leading, 10)
                
                if required {
                    Text("*")
                        .foregroundStyle(.red)
                        .font(.callout)
                        .offset(x: -4)
                }
                
                Spacer()
            }
            .onTapGesture {
                focused = true
            }
            
            if isPhoneNumber {
                HStack {
                    if menuCodesDisabled {
                        Text("+\(phoneIndicativeText ?? "")")
                            .foregroundStyle(.gray.opacity(0.7))
                            .padding(10)
                            .overlay {
                                RoundedRectangle(cornerRadius: cornerRadius ?? 0)
                                    .stroke(.gray.opacity(0.7), lineWidth: focused ? 2 : 1) // Color y grosor del borde
                                    .animation(.easeInOut, value: focused)
                            }
                    } else {
                        Menu {
                            Section(header: Text(.codeSelectCountry).font(.headline)) {
                                ForEach(PhoneCountryCodeOptions, id: \.code) { phoneCountryCode in
                                    var country: String { NSLocalizedString(phoneCountryCode.country, comment: "")}
                                    let isSelected = phoneCountryCodeSelected?.code.replacingOccurrences(of: "+", with: "") == phoneCountryCode.code.replacingOccurrences(of: "+", with: "")
                                    
                                    Button(action: {
                                        phoneCountryCodeSelected = phoneCountryCode
                                    }) {
                                        Text("+\(phoneCountryCode.code) \(country)")
                                    }
                                    .opacity(isSelected ? 0.4 : 1)
                                    .disabled(isSelected)
                                }
                            }
                        } label: {
                            Text("+\(phoneCountryCodeSelected?.code ?? "")")
                                .padding(10)
                                .overlay {
                                    RoundedRectangle(cornerRadius: cornerRadius ?? 0)
                                        .stroke(.gray, lineWidth: focused ? 2 : 1) // Color y grosor del borde
                                        .animation(.easeInOut, value: focused)
                                }
                        }
                        .onAppear {
                            phoneCountryCodeSelected = PhoneCountryCodeProps(
                                code: initialPhoneCountryCode?.replacingOccurrences(of: "+", with: "") ?? "57",
                                country: initialPhoneCountryCode ?? ""
                            )
                        }
                        .onChange(of: phoneCountryCodeSelected?.code) {
                            phoneCountryCodeVoid?("+\(phoneCountryCodeSelected?.code ?? "")")
                        }
                    }
                    
                    InputTextField(
                        required: required,
                        text: $text,
                        placeholder: placeholder,
                        inputStatus: $inputStatus,
                        keyboardType: keyboardType ?? .phonePad,
                        onEditing: {
                            onEditing?()
                        },
                        replacementPattern: replacementPattern,
                        maxLenght: maxLenght,
                        onFocused: {
                            onFocused?()
                        },
                        onSubmit: {
                            onSubmit?()
                        },
                        inputTextColor: inputTextColor ?? .black,
                        cornerRadius: cornerRadius ?? 2,
                        borderColor: borderColor,
                        focused: _focused
                    )
                }
            }
            else if isPassword {
                ZStack {
                    if showPassword {
                        InputTextField(
                            required: required,
                            text: $text,
                            placeholder: placeholder,
                            inputStatus: $inputStatus,
                            keyboardType: .default,
                            onEditing: {
                                onEditing?()
                            },
                            replacementPattern: replacementPattern,
                            maxLenght: maxLenght,
                            onFocused: {
                                if onFocused != nil {
                                    onFocused!()
                                }
                            },
                            onSubmit: {
                                if onSubmit != nil {
                                    onSubmit!()
                                }
                            },
                            inputTextColor: inputTextColor ?? .black,
                            cornerRadius: cornerRadius ?? 2,
                            borderColor: borderColor,
                            isPassword: true,
                            focused: _focused
                        )
                    } else {
                        SecureField(placeholder, text: $text)
                            .padding(.trailing, inputStatus == .good ? 60 : 30)
                            .padding(10)
                            .padding(.vertical, 1)
                            .keyboardType(.default)
                            .focused($focused)
                            .onChange(of: focused, {
                                if !focused {
                                    if required && text.isEmpty {
                                        inputStatus = .error
                                    } else {
                                        inputStatus = .good
                                    }
                                    
                                    onFocused?()
                                }
                            })
                            .onChange(of: text) { old, newText in
                                if let pattern = replacementPattern {
                                    let range = NSRange(location: 0, length: text.utf16.count)
                                    text = pattern.pattern.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: pattern.with)
                                }
                                
                                // Limitar el texto a una longitud máxima
                                if text.count > maxLenght {
                                    text = String(text.prefix(maxLenght))  // Limita la cantidad de caracteres
                                }
                                
                                onEditing?()
                            }
                            .onSubmit {
                                onSubmit?()
                            }
                            .overlay {
                                InputBorderOK(
                                    inputStatus: $inputStatus,
                                    cornerRadius: cornerRadius,
                                    borderColor: borderColor,
                                    focused: focused
                                )
                            }
                    }
                    
                    HStack{
                        Spacer()
                        
                        Button(action: {
                            changeVisibilityPassword?()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.gray.opacity(0.8))
                                .animation(.bouncy, value: showPassword)
                        }
                        .padding(6)
                        .padding(.horizontal, 4)
                        .onPressImpact(.soft)
                        .padding(.trailing, inputStatus == .good ? 30 : 0)
                        .animation(.easeInOut(duration: 0.3), value: inputStatus)
                    }
                }
                .onChange(of: text) {
                    let (
                        minLength,
                        minAUppercase,
                        minALowercase,
                        minASpecial,
                        minANumber,
                        isValidPassword
                    ) = validatePassword(text)
                    
                    passMin8 = minLength
                    passMinUppercase = minAUppercase
                    passMinLowercase = minALowercase
                    passMinSpecial = minASpecial
                    passMinANumber = minANumber
                    
                    if isValidPassword {
                        inputStatus = .good
                    }
                }
            }
            else {
                InputTextField(
                    required: required,
                    text: $text,
                    placeholder: placeholder,
                    inputStatus: $inputStatus,
                    keyboardType: keyboardType ?? .default,
                    onEditing: {
                        onEditing?()
                    },
                    replacementPattern: replacementPattern,
                    maxLenght: maxLenght,
                    onFocused: {
                        if onFocused != nil {
                            onFocused!()
                        }
                    },
                    onSubmit: {
                        if onSubmit != nil {
                            onSubmit!()
                        }
                    },
                    inputTextColor: inputTextColor ?? .black,
                    cornerRadius: cornerRadius ?? 2,
                    borderColor: borderColor,
                    focused: _focused
                )
            }
            
            if isPassword && (showItemsForCreatePassword != nil && showItemsForCreatePassword!) {
                HStack (alignment: .top) {
                    VStack {
                        InputItemPassword(text: "passMin8", isOk: $passMin8)
                        InputItemPassword(text: "passMinAUppercase", isOk: $passMinUppercase)
                        InputItemPassword(text: "passMinALowercase", isOk: $passMinLowercase)
                    }
                    .padding(.horizontal, 5)
                    VStack {
                        InputItemPassword(text: "passMinASpecial", isOk: $passMinSpecial)
                        InputItemPassword(text: "passMinANumber", isOk: $passMinANumber)
                    }
                    .padding(.horizontal, 5)
                    Spacer()
                }
                .padding(.vertical, 5)
            }
            
            HStack {
                if inputStatus == .error {
                    Image(systemName: "exclamationmark.circle")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.leading)
                        .offset(x: 4)
                    
                    Text(msmError ?? "")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.leading)
                } else if inputStatus == .warning {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.footnote)
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.leading)
                        .offset(x: 4)
                    
                    Text(msmWarning ?? "")
                        .font(.footnote)
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(.leading, 5)
            .padding(.bottom, inputStatus == .error ? 5 : 15)
            .animation(.easeInOut(duration: 0.3), value: inputStatus)
            .onTapGesture {
                focused = true
            }
        }
    }
}

private struct InputTextField: View {
    @State var required: Bool
    @Binding var text: String
    var placeholder: LocalizedStringKey
    @Binding var inputStatus: InputStatusType
    var keyboardType: UIKeyboardType
    var onEditing: (()-> Void?)
    var replacementPattern: (pattern: NSRegularExpression, with: String)?
    var maxLenght: Int = 999999999999999999
    var onFocused: (()-> Void?)
    var onSubmit: (()-> Void?)
    var inputTextColor: Color
    var cornerRadius: CGFloat = 2
    var borderColor: Color = .gray
    var isPassword: Bool = false
    
    @FocusState var focused: Bool
    
    var body: some View {
        TextField(placeholder, text: $text) { editing in
            if !editing {
                if required && text.isEmpty {
                    inputStatus = .error
                } else if !required && text.isEmpty {
                    inputStatus = .initial
                } else {
                    inputStatus = .good
                }
                
                onFocused()
            }
        }
        .padding(.trailing, isPassword ? 50 : 22)
        .padding(10)
        .keyboardType(keyboardType)
        .focused($focused)
        .onChange(of: text) {
            if let pattern = replacementPattern {
                let range = NSRange(location: 0, length: text.utf16.count)
                text = pattern.pattern.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: pattern.with)
            }
            
            // Limitar el texto a una longitud máxima
            if text.count > maxLenght {
                text = String(text.prefix(maxLenght))  // Limita a 6 caracteres
            }
            
            onEditing()
        }
        .onSubmit {
            onSubmit()
        }
        .overlay {
            InputBorderOK(
                inputStatus: $inputStatus,
                cornerRadius: cornerRadius,
                borderColor: borderColor,
                focused: focused
            )
        }
    }
}

private struct InputBorderOK: View {
    @Binding var inputStatus: InputStatusType
    var cornerRadius: CGFloat? = 12
    var borderColor: Color
    var focused: Bool
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: inputStatus == .good ? 20 : 0, height: inputStatus == .good ? 20 : 0)
                    .foregroundStyle(.green)
                    .padding(6)
                    .padding(.horizontal, 4)
                    .animation(.easeInOut(duration: 0.3), value: inputStatus)
                    .allowsHitTesting(false)
            }
            .allowsHitTesting(false)
            
            RoundedRectangle(cornerRadius: cornerRadius ?? 0)
                .stroke(borderColor, lineWidth: focused ? 2 : 1) // Color y grosor del borde
                .animation(.easeInOut, value: focused)
                .allowsHitTesting(false)
        }
        .allowsHitTesting(false)
    }
}

private struct InputItemPassword: View {
    @State var text: LocalizedStringKey
    @Binding var isOk: Bool
    
    var body: some View {
        HStack {
            Label(text, systemImage: !isOk ? "exclamationmark.triangle" : "checkmark")
                .foregroundStyle(!isOk ? .gray : .green)
                .font(.caption2)
                .padding(.vertical, 1)
                .multilineTextAlignment(.leading)
                .animation(.easeInOut(duration: 0.3), value: isOk)
            
            Spacer()
        }
        .frame(maxWidth: 200)
    }
}

enum InputStatusType: String {
    case initial
    case error
    case warning
    case good
}

func isValidEmail(_ email: String) -> Bool {
    // Expresión regular para correos válidos
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    
    // Si es modo producción, prohibir correos de yopmail
    if !isDevelopment && email.lowercased().hasSuffix("@yopmail.com") {
        return false
    }
    
    return emailTest.evaluate(with: email)
}

func validatePassword(_ password: String) -> (
    minLength: Bool,
    minAUppercase: Bool,
    minALowercase: Bool,
    minASpecial: Bool,
    minANumber: Bool,
    isValidPassword: Bool
) {
    let minLength = password.count >= 8
    let minAUppercase = password.range(of: ".*[A-Z].*", options: .regularExpression) != nil
    let minALowercase = password.range(of: ".*[a-z].*", options: .regularExpression) != nil
    let minASpecial = password.range(of: ".*[!@#$%^&*()_+\\-.].*", options: .regularExpression) != nil
    let minANumber = password.range(of: ".*[0-9].*", options: .regularExpression) != nil
    
    let isValidPassword = minLength && minAUppercase && minALowercase && minASpecial && minANumber
    
    return (
        minLength,
        minAUppercase,
        minALowercase,
        minASpecial,
        minANumber,
        isValidPassword
    )
}

#Preview {
    @Previewable @State var text: String = ""
    @Previewable @State var status: InputStatusType = InputStatusType.initial
    
    Input(
        label: "password",
        required: true,
        text: $text,
        placeholder: "create-a-password",
        inputStatus: $status,
        msmError: "field-required",
        isPassword: true,
        showItemsForCreatePassword: true
    )
}

struct PhoneCountryCodeProps {
    var code: String
    var country: String
}

var PhoneCountryCodeOptions: [PhoneCountryCodeProps] = [
    PhoneCountryCodeProps(code: "43", country: "code-austria"),
    PhoneCountryCodeProps(code: "32", country: "code-belgium"),
    PhoneCountryCodeProps(code: "359", country: "code-bulgaria"),
    PhoneCountryCodeProps(code: "385", country: "code-croatia"),
    PhoneCountryCodeProps(code: "357", country: "code-cyprus"),
    PhoneCountryCodeProps(code: "420", country: "code-czech-republic"),
    PhoneCountryCodeProps(code: "45", country: "code-denmark"),
    PhoneCountryCodeProps(code: "372", country: "code-estonia"),
    PhoneCountryCodeProps(code: "358", country: "code-finland"),
    PhoneCountryCodeProps(code: "33", country: "code-france"),
    PhoneCountryCodeProps(code: "49", country: "code-germany"),
    PhoneCountryCodeProps(code: "30", country: "code-greece"),
    PhoneCountryCodeProps(code: "36", country: "code-hungary"),
    PhoneCountryCodeProps(code: "354", country: "code-iceland"),
    PhoneCountryCodeProps(code: "353", country: "code-ireland"),
    PhoneCountryCodeProps(code: "39", country: "code-italy"),
    PhoneCountryCodeProps(code: "371", country: "code-latvia"),
    PhoneCountryCodeProps(code: "370", country: "code-lithuania"),
    PhoneCountryCodeProps(code: "352", country: "code-luxembourg"),
    PhoneCountryCodeProps(code: "356", country: "code-malta"),
    PhoneCountryCodeProps(code: "373", country: "code-moldova"),
    PhoneCountryCodeProps(code: "377", country: "code-monaco"),
    PhoneCountryCodeProps(code: "382", country: "code-montenegro"),
    PhoneCountryCodeProps(code: "31", country: "code-netherlands"),
    PhoneCountryCodeProps(code: "47", country: "code-norway"),
    PhoneCountryCodeProps(code: "48", country: "code-poland"),
    PhoneCountryCodeProps(code: "351", country: "code-portugal"),
    PhoneCountryCodeProps(code: "40", country: "code-romania"),
    PhoneCountryCodeProps(code: "7", country: "code-russia"),
    PhoneCountryCodeProps(code: "381", country: "code-serbia"),
    PhoneCountryCodeProps(code: "421", country: "code-slovakia"),
    PhoneCountryCodeProps(code: "386", country: "code-slovenia"),
    PhoneCountryCodeProps(code: "34", country: "code-spain"),
    PhoneCountryCodeProps(code: "46", country: "code-sweden"),
    PhoneCountryCodeProps(code: "41", country: "code-switzerland"),
    PhoneCountryCodeProps(code: "90", country: "code-turkey"),
    PhoneCountryCodeProps(code: "380", country: "code-ukraine"),
    PhoneCountryCodeProps(code: "44", country: "code-united-kingdom")
]

