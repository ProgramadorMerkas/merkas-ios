//
//  HomeScreen.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 29/9/25.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var showPointsFixed = false
    
    var body: some View {
        let hello: String = "\(NSLocalizedString("homeHello", comment: ""))\(appState.user != nil ? ", \(appState.user!.usuarioNombre.capitalized)" : "")"
        
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) {
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.frame(in: .global).minY) { _, value in
                                    // value = 100 aprox al inicio, disminuye al hacer scroll
                                    withAnimation(.easeInOut) {
                                        showPointsFixed = value < -100
                                    }
                                }
                        }
                        .frame(height: 0)
                        
                        MerkashPoints()
                            .padding(.top, 15)
                        
                        VStack {
                            SectionTitle(title: "winMorePoints")
                            HStack {
                                Button (action: {
                                    appState.currentCategoryOffers = "all"
                                    appState.currentTab = .offers
                                }) {
                                    ActionMorePoints(
                                        title: "seeAllOffers",
                                        color: .orange,
                                        icon: "tag.fill"
                                    )
                                }
                                .onPressImpact(.soft)
                                
                                Button (action: {
                                    appState.navigateToAddFriend = true
                                    appState.currentTab = .referrals
                                }) {
                                    ActionMorePoints(
                                        title: "inviteFriends",
                                        color: .cyan,
                                        icon: "person.3.fill"
                                    )
                                }
                                .onPressImpact(.soft)
                            }
                            
                            SectionTitle(title: "seeOffersByCategory")
                            OffersHeader(showButtonAllCategories: false) {
                                appState.currentTab = .offers
                            }
                            
                            SectionTitle(title: "SeeNearbyAllies")
                            AlliesMini {
                                appState.currentTab = .allies
                            }
                        }
                        .padding([.horizontal, .bottom], 30)
                    }
                }
                
                if showPointsFixed {
                    MerkashPoints(isSmall: true)
                }
                
            }
            .navigationTitle(hello)
            .navigationBarTitleDisplayMode(.large)
            .navigationSubtitle(.tabHomeSubtitle)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        UIApplication.shared.open(URL(string: "whatsapp://send?text=¡Hola Merkas!&phone=573336012020")!)
                    }) {
                        Image(systemName: "questionmark.bubble")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.merkas2)
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                }
            }
        }
    }
}

private struct SectionTitle: View {
    var title: LocalizedStringKey
    
    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .font(.title3.bold())
            .padding(.top, 10)
    }
}

private struct ActionMorePoints: View {
    var title: LocalizedStringKey
    var color: Color
    var icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
            
            Text(title)
                .font(.footnote.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .frame(height: 100)
        .background(color)
        .cornerRadius(10)
        .padding(3)
    }
}
