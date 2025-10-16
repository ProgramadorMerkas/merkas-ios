//
//  OffersScreen.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 29/9/25.
//

import SwiftUI

struct OffersScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var showPointsFixed = false
    @State private var navigateToEcommerce = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) {
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.frame(in: .global).minY) { _, value in
                                    // value = 100 aprox al inicio, disminuye al hacer scroll
                                    //withAnimation(.easeInOut) {
                                        showPointsFixed = value < 97
                                    //}
                                }
                        }
                        .frame(height: 0)
                        
                        OffersHeader()
                            .padding(.top, 15)
                            .opacity(showPointsFixed ? 0 : 1)
                            .disabled(showPointsFixed)
                        
                        OffersList()
                    }
                }
                
                OffersHeader()
                    .frame(maxHeight: 40)
                    .opacity(showPointsFixed ? 1 : 0)
                    .disabled(!showPointsFixed)
            }
            .navigationTitle(.tabOffers)
            .navigationSubtitle(.tabOffersSubtitle)
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $navigateToEcommerce) {
                EcommerceScreen(commerceId: appState.navigateEcommerceId)
            }
            .onAppear {
                if appState.navigateToEcommerce {
                    navigateToEcommerce = true
                    appState.navigateToEcommerce = false
                }
            }
        }
    }
}

struct OffersList: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            if appState.currentCategoryOffers == "all" || appState.currentOffers == nil {
                VStack(spacing: 20) {
                    ForEach(appState.offers, id: \.id) { category in
                        let color: Color = hexToColor(category.color) ?? .merkas2
                        
                        
                        Text(category.titulo)
                            .font(.headline.bold())
                            .foregroundStyle(color)
                            .padding(.top, 10)
                        
                        ForEach(category.data) { promo in
                            VStack(spacing: 10) {
                                OfferItem(
                                    offer: promo,
                                    categoryName: category.titulo,
                                    categoryColor: color
                                )
                            }
                        }
                    }
                }
                .padding(.top, 30)
            } else {
                VStack(spacing: 20) {
                    ForEach(appState.currentOffers!.data, id: \.id) { promo in
                        let color: Color = hexToColor(appState.currentOffers!.color) ?? .merkas2
                        
                        VStack(spacing: 10) {
                            OfferItem(
                                offer: promo,
                                categoryName: appState.currentOffers?.titulo,
                                categoryColor: color
                            )
                        }
                    }
                }
                .padding(.top, 30)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: appState.currentCategoryOffers)
        .navigationTitle(appState.currentCategoryOffers == "all" ? .tabOffers : "\(capitalizeFirstLetter(appState.currentOffers?.titulo ?? ""))")
    }
}

struct OfferItem: View {
    var offer: OfferData
    var categoryName: String?
    var categoryColor: Color
    
    var body: some View {
        NavigationLink (destination: EcommerceScreen(commerceId: offer.id, titleCategory: categoryName)) {
            ZStack {
                AsyncImage(url: URL(string: "\(baseURL)\(offer.miniBannerPromocion.imagen)")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } placeholder: {
                    ProgressView()
                        .tint(categoryColor)
                        .frame(height: 150)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(categoryColor.opacity(0.3))
                }
                .frame(maxWidth: .infinity, maxHeight: 150)
                
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .clear, .black.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    HStack {
                        Text(offer.miniBannerPromocion.nombreComercio)
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.white)
                    }
                }
                .padding(10)
            }
            .frame(maxWidth: .infinity, maxHeight: 150)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 20)
        }
        .onPressImpact(.soft)
    }
}

#Preview {
    OffersScreen()
}
