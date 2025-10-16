//
//  MerkashPoints.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 29/9/25.
//

import SwiftUI

struct MerkashPoints: View {
    @EnvironmentObject var appState: AppState
    var isSmall: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            MerkashPoint(
                title: "myMerkash",
                value: "$\(appState.user?.usuarioMerkash ?? "")",
                isSmall: isSmall
            )
            
            Rectangle()
                .fill(.white.opacity(0.8))
                .frame(width: 1, height: isSmall ? 20 : 50)
            
            MerkashPoint(
                title: "myPoints",
                value: "\(appState.user?.usuarioPuntos ?? "")",
                isSmall: isSmall
            )
        }
        .padding(isSmall ? 8 : 16)
        .padding(.vertical, isSmall ? 8 : 16)
        .frame(maxWidth: .infinity)
        .background(.merkas)
        .cornerRadius(10)
        .padding([.horizontal, .bottom], 30)
        .transition(.opacity)
        .zIndex(1)
    }
}

private struct MerkashPoint: View {
    var title: String
    var value: String
    var isSmall: Bool
    
    var body: some View {
        let translated = NSLocalizedString(title, comment: "")
        let text: String = "\(translated) \(isSmall ? "\(value)" : "")"
        
        VStack {
            Text(text)
                .font(isSmall ? .footnote.bold() : .headline.bold())
                .foregroundStyle(.white)
                .padding(.bottom, isSmall ? 0 : 5)
            
            if !isSmall {
                HStack {
                    Text("\(value)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                    
                    if Int(value.replacingOccurrences(of: "$", with: "")) ?? 0 > 0 {
                        Image(systemName: "face.smiling")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.white)
                    } else {
                        Image(.frowning)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MerkashPoints()
}
