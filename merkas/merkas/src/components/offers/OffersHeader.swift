//
//  OffersHeader.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 30/9/25.
//

import SwiftUI

struct OffersHeader: View {
    @EnvironmentObject var appState: AppState
    @AppStorage(StorageKeys.TOKEN.rawValue) private var token: String = ""
    
    var showButtonAllCategories: Bool = true
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            if appState.offersLoading {
                ProgressView()
                    .tint(.merkas)
                
                Spacer()
            } else {
                if appState.offers.isEmpty {
                    Text(.offersEmpty)
                        .font(.subheadline.bold())
                        .foregroundStyle(.black.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 5)
                    
                } else {
                    if showButtonAllCategories {
                        let isAllCurrent = appState.currentCategoryOffers == "all"
                        Button(action: {
                            appState.currentCategoryOffers = "all"
                            action?()
                        }) {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(isAllCurrent ? .white : .merkas)
                                
                                if isAllCurrent {
                                    Text("currentCategoryAll")
                                        .font(.subheadline.bold())
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 40)
                            .background(isAllCurrent ? .merkas : .white)
                            .clipShape(Capsule())
                            .foregroundColor(.white)
                            .overlay(
                                Capsule()
                                    .stroke(.merkas, lineWidth: 2)
                            )
                            .shadow(color: .merkas.opacity(0.2), radius: 2, x: 0, y: 1)
                            .animation(.easeInOut(duration: 0.2), value: appState.currentCategoryOffers)
                        }
                        .onPressImpact(.soft)
                        .disabled(isAllCurrent)
                    }
                    
                    if !appState.offers.isEmpty && showButtonAllCategories {
                        Divider()
                            .tint(.gray.opacity(0.8))
                    }
                    
                    HorizontalScroll(offers: appState.offers) {
                        action?()
                    }
                }
            }
        }
        .padding(.horizontal, showButtonAllCategories ? 20 : 0)
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.2), value: appState.currentCategoryOffers)
        .animation(.easeInOut(duration: 0.2), value: appState.offers.count)
        .animation(.easeInOut(duration: 0.2), value: appState.offersLoading)
        .onAppear {
            Task {
                if appState.offers.isEmpty {
                    await getOffers()
                } else {
                    appState.offersLoading = false
                }
            }
        }
        .onChange(of: appState.currentCategoryOffers) { oldValue, newValue in
            if let selectedOffer = appState.offers.first(where: { $0.id == newValue }) {
                // selectedOffer es tu objeto completo
                appState.currentOffers = selectedOffer
                print(selectedOffer)
            } else {
                print("No se encontró el id")
                appState.currentOffers = nil
            }
        }
    }
    
    private func getOffers() async {
        Task {
            appState.offersLoading = true
            if appState.user != nil {
                let result = await OffersService.shared.getOffers(userId: appState.user?.usuarioId ?? "", token: token)
                switch result {
                case .success(let offers):
                    print("✅ Llamada exitosa, revisa la consola para ver el JSON", offers)
                    appState.offers = offers
                    
                    appState.offersLoading = false
                case .failure(let mensaje):
                    print("❌ Error:", mensaje)
                    appState.offersLoading = false
                }
            } else {
                appState.offersLoading = false
                await getOffers()
            }
        }
    }
}

struct HorizontalScroll: View {
    @EnvironmentObject var appState: AppState
    
    let offers: [OffersProps]
    var action: (() -> Void)? = nil
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(offers) { offer in
                        OffersHeaderButton (offer: offer) {
                            action?()
                        }
                    }
                }
                .padding(5)
            }
            .onChange(of: appState.currentCategoryOffers) { _, newValue in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
            .onAppear {
                proxy.scrollTo(appState.currentCategoryOffers, anchor: .center)
            }
        }
    }
}

struct OffersHeaderButton: View {
    @EnvironmentObject var appState: AppState
    
    var offer: OffersProps
    var action: (() -> Void)? = nil
    
    var body: some View {
        let isCurrent = offer.id == appState.currentCategoryOffers
        let color: Color = hexToColor(offer.color) ?? .merkas2
        
        Button(action: {
            appState.currentCategoryOffers = offer.id
            action?()
        }) {
            HStack {
                ZStack {
                    AsyncImage(url: URL(string: "\(baseURL)\(offer.icono)")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(isCurrent ? .white : color)
                    } placeholder: {
                        ProgressView()
                            .tint(.white)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40)
                    .background(color)
                    .clipShape(Capsule())
                }
                
                Text(offer.titulo)
                    .font(.subheadline.bold())
                    .foregroundStyle(isCurrent ? .white : color)
            }
            .padding(.trailing, 16)
            .background(isCurrent ? color : .white)
            .clipShape(Capsule())
            .foregroundColor(.white)
            .overlay(
                Capsule()
                    .stroke(color, lineWidth: 2)
            )
            .shadow(color: color.opacity(0.2), radius: 2, x: 0, y: 1)
            .animation(.easeInOut(duration: 0.2), value: isCurrent)
        }
        .onPressImpact(.soft)
    }
}

#Preview {
    OffersHeader()
}
