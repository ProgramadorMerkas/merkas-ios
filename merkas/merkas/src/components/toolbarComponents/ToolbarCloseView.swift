//
//  ToolbarCloseView.swift
//  valkhior
//

import SwiftUI

struct ToolbarCloseView: View {
    @Environment(\.dismiss) var dismiss
    var systemImage: String = "xmark"
    
    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: systemImage)
                    .foregroundColor(.merkas)
                    .font(.caption)
                    .padding(10)
            }
        }
    }
}

#Preview {
    ToolbarCloseView()
}
