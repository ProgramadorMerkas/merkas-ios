//
//  Loading.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI

struct Loading: View {
    var message: LocalizedStringKey?
    
    var body: some View {
        VStack {
            ProgressView()
                .tint(.merkas)
                .font(.largeTitle)
            
            if let message {
                Text(message)
                    .font(.headline.bold())
                    .foregroundColor(.merkas2)
                    .padding(20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

#Preview {
    Loading()
}
