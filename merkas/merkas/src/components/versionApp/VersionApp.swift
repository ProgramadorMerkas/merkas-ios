//
//  VersionApp.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 2/10/25.
//

import SwiftUI

struct VersionApp: View {
    var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }
    
    var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
    }
    
    var body: some View {
        Text("v. \(version)(\(build))")
            .font(.footnote.bold())
            .foregroundStyle(.gray.opacity(0.5))
            .padding()
    }
}

#Preview {
    VersionApp()
}
