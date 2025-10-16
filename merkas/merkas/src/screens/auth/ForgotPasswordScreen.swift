//
//  ForgotPasswordScreen.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI

struct ForgotPasswordScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack {
                    }
                    .frame(maxWidth: .infinity)
                }
                
                VStack {}
            }
            .navigationTitle(.screenForgotPassword)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarCloseView()
            }
        }
    }
}

#Preview {
    ForgotPasswordScreen()
}
