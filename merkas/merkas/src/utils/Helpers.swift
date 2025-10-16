//
//  Helpers.swift
//  valkhior
//

import SwiftUI

func UITheme(colorLight:UIColor, colorDark:UIColor) -> Color {
    return Color(UIColor { traitCollection in
        // Cambia el color según el modo de la interfaz de usuario
        traitCollection.userInterfaceStyle == .dark ? colorDark : colorLight
    })
}

func parseMarkdown(_ text: String) -> AttributedString {
    var attributedString = AttributedString(text)
    
    let pattern = "\\*\\*(.*?)\\*\\*" // Encuentra **texto en negrita**
    let regex = try! NSRegularExpression(pattern: pattern)
    
    let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
    let matches = regex.matches(in: text, range: nsRange)
    
    for match in matches.reversed() { // Recorre de atrás hacia adelante para modificar sin problemas
        if let range = Range(match.range, in: text) {
            let boldText = text[range].replacingOccurrences(of: "**", with: "") // Quita los **
            
            var attributedPart = AttributedString(boldText)
            
            // Aplicar negrita correctamente
            attributedPart[attributedPart.startIndex..<attributedPart.endIndex].font = .system(size: 14, weight: .bold)
            
            // Convertimos `Range<String.Index>` a `Range<AttributedString.Index>`
            if let attributedRange = Range(match.range, in: attributedString) {
                attributedString.replaceSubrange(attributedRange, with: attributedPart) // Reemplaza en el texto
            }
        }
    }
    
    return attributedString
}

func getTimeStamp() -> Int { return Int(Date().timeIntervalSince1970) }

func getAppVersionInfo() -> (version: String, build: String) {
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Desconocido"
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Desconocido"
    
    return (version, build)
}

let isDevelopment: Bool = {
#if DEBUG
    return true
#else
    return false
#endif
}()

func regexes () -> (emailRegex: NSRegularExpression, namesRegex: NSRegularExpression, phoneNumberRegex: NSRegularExpression) {
    let emailRegex = try! NSRegularExpression(pattern: "[^a-zA-Z0-9@._-]", options: [])
    let namesRegex = try! NSRegularExpression(pattern: "[^\\p{L}\\s'-]", options: [])
    let phoneNumberRegex = try! NSRegularExpression(pattern: "[^0-9]", options: [])
    
    return (emailRegex, namesRegex, phoneNumberRegex)
}
    
//func isUserDataPending(_ userInfo: UserInfoModel) -> Bool {
//    return userInfo.name.isEmpty || userInfo.surnames.isEmpty || userInfo.phoneNumber.isEmpty || userInfo.dniNIE.isEmpty || userInfo.country.isEmpty || userInfo.province.isEmpty || userInfo.city.isEmpty || userInfo.address.isEmpty || userInfo.postalCode.isEmpty
//}

func openAppSettings() {
    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }
}

let languagePreference = Bundle.main.preferredLocalizations.first ?? "es"

func localizedLanguageName(for identifier: String) -> String {
    let locale = Locale.current
    let languageName = locale.localizedString(forIdentifier: identifier) ?? identifier
    return languageName.capitalized // Esto convierte la primera letra en mayúscula
}

func formatEuropeanDecimal(_ number: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "es_ES")

    // Verifica si tiene decimales distintos de cero
    let isWholeNumber = number.truncatingRemainder(dividingBy: 1) == 0

    formatter.minimumFractionDigits = isWholeNumber ? 0 : 2
    formatter.maximumFractionDigits = isWholeNumber ? 0 : 2

    return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
}

// Función para convertir un color de SwiftUI a RGB
func colorToRGB(_ color: Color) -> String {
    let uiColor = UIColor(color)
    let components = uiColor.cgColor.components ?? [0, 0, 0, 0]

    let r = Int(components[0] * 255)
    let g = Int(components[1] * 255)
    let b = Int(components[2] * 255)

    return "rgb(\(r), \(g), \(b))"
}

// Función para convertir un valor RGB a un Color que SwiftUI entienda
func rgbToColor(_ rgb: String) -> Color {
    // Extraemos los valores de los componentes RGB del string
    let rgbValues = rgb
        .replacingOccurrences(of: "rgb(", with: "")
        .replacingOccurrences(of: ")", with: "")
        .split(separator: ",")
        .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }

    guard rgbValues.count == 3 else {
        return .white // Valor por defecto si no se puede parsear correctamente
    }

    let r = Double(rgbValues[0]) / 255.0
    let g = Double(rgbValues[1]) / 255.0
    let b = Double(rgbValues[2]) / 255.0

    return Color(red: r, green: g, blue: b)
}

func hexToColor(_ hex: String) -> Color? {
    // Limpiamos el string de posibles #
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    
    // Variable para el valor numérico
    var int = UInt64()
    
    // Convertimos a número
    Scanner(string: hex).scanHexInt64(&int)
    
    // Dependiendo de la longitud del string, sacamos los componentes
    let r, g, b: Double
    if hex.count == 6 {
        r = Double((int >> 16) & 0xFF) / 255.0
        g = Double((int >> 8) & 0xFF) / 255.0
        b = Double(int & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    } else {
        // fallback si no es un hex válido
        return nil
    }
}

func cleanSpaces(_ text: String) -> String {
    return text.trimmingCharacters(in: .whitespacesAndNewlines)
}

func capitalizeFirstLetter(_ text: String) -> String {
    guard let first = text.first else { return "" }
    return first.uppercased() + text.dropFirst().lowercased()
}
