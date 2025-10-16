//
//  HideKeyboardModifier.swift
//  valkhior
//

import SwiftUI

// Modificador para cerrar teclado tocando en el área
struct HideKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

// Extensión para usar el modificador fácilmente
extension View {
    func hideKeyboardOnTap() -> some View {
        self.modifier(HideKeyboardModifier())
    }
}
