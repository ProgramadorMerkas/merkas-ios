//
//  HapticModifier.swift
//  merkas
//

import SwiftUI
import UIKit

// MARK: - HapticModel
class HapticModel {
    static let shared: HapticModel = HapticModel()
    
    private init() { }
    
    func vibrate(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(type)
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: style)
        feedbackGenerator.impactOccurred()
    }
}

// MARK: - ViewModifier para Vibración
struct HapticFeedbackModifier: ViewModifier {
    let type: UINotificationFeedbackGenerator.FeedbackType

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture().onEnded {
                    HapticModel.shared.vibrate(type)
                }
            )
    }
}

// MARK: - ViewModifier para Impacto
struct HapticImpactModifier: ViewModifier {
    let style: UIImpactFeedbackGenerator.FeedbackStyle

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture().onEnded {
                    HapticModel.shared.impact(style)
                }
            )
    }
}

// MARK: - Extensiones para Uso en SwiftUI
extension View {
    /// Agrega vibración de notificación al presionar
    func onPressVibration(_ type: UINotificationFeedbackGenerator.FeedbackType) -> some View {
        self.modifier(HapticFeedbackModifier(type: type))
    }

    /// Agrega impacto háptico al presionar
    func onPressImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) -> some View {
        self.modifier(HapticImpactModifier(style: style))
    }
}
