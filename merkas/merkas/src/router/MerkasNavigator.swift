//
//  MerkasNavigator.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI

struct MerkasNavigator: View {
    @EnvironmentObject var appState: AppState
    @State private var selection: TabsEnum = .home
    
    var body: some View {
        TabView(selection: $selection) {
            Group {
                HomeScreen()
                    .tabItem {
                        Label(.tabHome, systemImage: "house.fill")
                    }
                    .tag(TabsEnum.home)
                
                AlliesScreen()
                    .tabItem {
                        Label(.tabAllies, systemImage: "mappin.and.ellipse")
                    }
                    .tag(TabsEnum.allies)
                
                OffersScreen()
                    .tabItem {
                        Label(.tabOffers, systemImage: "tag.fill")
                    }
                    .tag(TabsEnum.offers)
                
                ReferralsScreen()
                    .tabItem {
                        Label(.tabReferrals, systemImage: "person.3.fill")
                    }
                    .tag(TabsEnum.referrals)
                
                MenuScreen()
                    .tabItem {
                        Label(.tabMenu, systemImage: "line.3.horizontal")
                    }
                    .tag(TabsEnum.menu)
            }
        }
        .onChange(of: appState.currentTab) { _, newValue in
            selection = newValue
        }
        .onChange(of: selection) { _, newValue in
            appState.currentTab = newValue
        }
    }
}

enum TabsEnum: Hashable {
    case home, allies, offers, referrals, menu
}

#Preview {
    MerkasNavigator()
}
