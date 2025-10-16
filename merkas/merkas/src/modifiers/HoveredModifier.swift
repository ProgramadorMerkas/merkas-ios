//
//  HoveredModifier.swift
//  valkhior
//

import SwiftUI

struct HoveredModifier: ViewModifier {
    let id: BtnHoveredId
    @Binding var hoveredId: BtnHoveredId

    func body(content: Content) -> some View {
        content
            .animation(.easeInOut(duration: 0.3), value: hoveredId)
            .onHover { isHovering in
                if isHovering {
                    hoveredId = id
                } else {
                    hoveredId = .empty
                }
            }
    }
}

extension View {
    func isHovered(id: BtnHoveredId, type: Binding<BtnHoveredId>) -> some View {
        self.modifier(HoveredModifier(id: id, hoveredId: type))
    }
}

enum BtnHoveredId: String {
    case empty = ""
    case signIn = "BTN_SIGN_IN"
    case signUp = "BTN_SIGN_UP"
    case signWithGoogle = "BTN_SIGN_WITH_GOOGLE"
    case signWithApple = "BTN_SIGN_WITH_APPLE"
    case saveDataUserForm = "SAVE_DATA_USER_FORM"
    case resetPassword = "RESET_PASSWORD"
    case editProfile = "EDIT_PROFILE"
}
