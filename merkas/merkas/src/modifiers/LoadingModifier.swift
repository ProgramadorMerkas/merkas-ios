//
//  LoadingModifier.swift
//  valkhior
//

import SwiftUI

struct LoadingModifier: ViewModifier {
    @Binding var loading: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    if loading {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                        ProgressView()
                            .tint(.black)
                            .opacity(loading ? 1 : 0)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: loading)
            }
    }
}

extension View {
    func isLoading(loading: Binding<Bool>) -> some View {
        self.modifier(LoadingModifier(loading: loading))
    }
}
