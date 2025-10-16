//
//  ToolbarIconLogo.swift
//  valkhior
//

import SwiftUI

struct ToolbarIconLogo: View {
    @Environment(\.colorScheme) private var colorScheme; private var isDarkMode: Bool { colorScheme == .dark }

    var body: some View {
    Image("PuntosMerkas")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 75, maxHeight: 30)
            .padding(.trailing, 10)
    }
}

#Preview {
    ToolbarIconLogo()
}
