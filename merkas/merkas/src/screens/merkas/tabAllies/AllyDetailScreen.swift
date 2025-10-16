//
//  AllyDetailScreen.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 3/10/25.
//

import SwiftUI

struct AllyDetailScreen: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    var ally: AlliesProps

    var body: some View {
        VStack {
            Spacer()
            
            AsyncImage(url: URL(string: "\(ally.usuarioRutaImg)")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } placeholder: {
                ProgressView()
                    .tint(hexToColor(ally.color) ?? .merkas)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, maxHeight: 250)
            .cornerRadius(16)
            .clipped()
            .padding(.horizontal, 15)
            
            HStack {
                if !ally.whatsapp.isEmpty {
                    Button(action: {
                        func cleanNumber(_ num: String) -> String {
                            var clean = num.replacingOccurrences(of: " ", with: "")
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            if clean.hasPrefix("+57") {
                                clean = String(clean.dropFirst(3))
                            } else if clean.count == 12 && clean.hasPrefix("57") {
                                clean = String(clean.dropFirst(2))
                            }
                            
                            return clean
                        }
                        UIApplication.shared.open(URL(string: "whatsapp://send?text=¡Hola!&phone=57\(cleanNumber(ally.whatsapp))")!)
                    }) {
                        HStack {
                            Image("whatsapp.logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .tint(.green)
                                .foregroundStyle(.green)
                            
                            Text(.whatsapp)
                                .foregroundStyle(.green)
                                .font(.footnote.bold())
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.glass)
                    .onPressImpact(.soft)
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                    appState.navigateEcommerceId = ally.id
                    appState.navigateToEcommerce = true
                    appState.currentTab = .offers
                }) {
                    HStack {
                        Image(systemName: "storefront")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .tint(.green)
                            .foregroundStyle(.white)
                        
                        Text(.ecommerce)
                            .foregroundStyle(.white)
                            .font(.footnote.bold())
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.glassProminent)
                .onPressImpact(.soft)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .frame(maxWidth: .infinity)
        .navigationTitle(ally.nombreCompleto)
        .navigationSubtitle(ally.categoria)
        .navigationBarTitleDisplayMode(.inline)
    }
}
