//
//  IntroScreen.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI

struct IntroScreen: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Spacer()
            Image("MerkasLogoTransparent")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .padding(.bottom, 10)
            
            Text(.introMerkas)
                .multilineTextAlignment(.center)
                .font(.footnote)
                .opacity(0.6)
            Spacer()
            
            VStack {
                if !appState.isLoading {
                    NavigationLink {
                        SignInScreen()
                    } label: {
                        Text(.screenSignIn)
                            .font(.footnote.bold())
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    .backgroundStyle(.merkas)
                    .buttonStyle(.glassProminent)
                    .onPressImpact(.soft)
                    
                    NavigationLink {
                        SignUpScreen()
                    } label: {
                        Text(.screenSignUp)
                            .font(.footnote.bold())
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.merkas)
                    }
                    .buttonStyle(.glass)
                    .onPressImpact(.soft)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: appState.isLoading)
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 15)
    }
}

#Preview {
    IntroScreen()
}
