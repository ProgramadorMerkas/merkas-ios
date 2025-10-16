//
//  OrientationModifier.swift
//  valkhior
//

import SwiftUI

// Modificador que detecta la orientación y actualiza el binding
struct OrientationModifier: ViewModifier {
    @Binding var isHorizontal: Bool

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            // Establece la orientación cuando aparece la vista
                            isHorizontal = geometry.size.width > geometry.size.height
                        }
                        .onChange(of: geometry.size) { oldSize, newSize in
                            // Actualiza la orientación cuando cambia el tamaño
                            isHorizontal = newSize.width > newSize.height
                        }
                }
            )
    }
}

// Extensión para aplicar el modificador fácilmente
extension View {
    func detectOrientation(isHorizontal: Binding<Bool>) -> some View {
        self.modifier(OrientationModifier(isHorizontal: isHorizontal))
    }
}
