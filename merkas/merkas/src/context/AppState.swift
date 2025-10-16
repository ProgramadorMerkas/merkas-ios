//
//  AppState.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI
import Combine

final class AppState: ObservableObject {
    // APP
    @Published var isLoading: Bool = false
    @Published var isReconnected: Bool = false
    @Published var currentCategoryOffers: String = "all"
    @Published var offers: [OffersProps] = []
    @Published var currentOffers: OffersProps? = nil
    @Published var offersLoading: Bool = true
    @Published var allies: [AlliesProps] = []
    @Published var alliesFetched: Bool = false
    @Published var currentTab: TabsEnum = .home
    @Published var navigateToAddFriend: Bool = false
    @Published var navigateToEcommerce: Bool = false
    @Published var navigateEcommerceId: String = ""
    
    // USER
    @Published var isLoggedIn: Bool = false
    @Published var user: LoginResponse? = nil
}
