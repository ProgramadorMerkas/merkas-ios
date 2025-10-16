//
//  Working.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 2/10/25.
//

import SwiftUI

struct Working: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "hammer")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.merkas)
                    .frame(width: 40, height: 40)
                Spacer()
            }
            .padding()
            
            Text(.workingApp)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray.opacity(0.05))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}

#Preview {
    Working()
}
