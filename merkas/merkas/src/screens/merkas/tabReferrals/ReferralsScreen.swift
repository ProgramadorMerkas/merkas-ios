//
//  ReferralsScreen.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 29/9/25.
//

import SwiftUI

struct ReferralsScreen: View {
    @EnvironmentObject var appState: AppState
    @AppStorage(StorageKeys.TOKEN.rawValue) private var token: String = ""
    @State private var navigateToAddFriends = false
    @State var selectedTab: ReferralsTabsEnum = .all
    @State var loadingData: Bool = true
    @State var allReferrals: [ReferredUser] = []
    @State var directReferrals: [ReferredUser] = []
    @State var indirectReferrals: [ReferredUser] = []
    @State var messageError: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if loadingData {
                    Loading(message: "referralsLoading")
                } else if !messageError.isEmpty {
                    ScrollView {
                        VStack {
                            Label(.referralsError, systemImage: "exclamationmark.circle")
                                .padding(.bottom, 20)
                            
                            Button(action: {
                                Task {
                                    await getReferrals()
                                }
                            }) {
                                Text(.retryLoadReferrals)
                                    .font(.footnote.bold())
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.glassProminent)
                        }
                        .padding(.top, 30)
                        .padding([.horizontal, .bottom], 20)
                    }
                    .refreshable {
                        Task {
                            await getReferrals()
                        }
                    }
                } else {
                    HStack {
                        ForEach(ReferralsTabsEnum.allCases, id: \.self) { tab in
                            let isSelected: Bool = selectedTab == tab
                            
                            Button(action: { selectedTab = tab }) {
                                Text(tab.title)
                                    .font(.footnote.bold())
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                            }
                            .disabled(isSelected)
                            .tint(isSelected ? .merkas : .black)
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                            .buttonStyle(.glass)
                            .overlay {
                                RoundedRectangle(cornerRadius: 25)
                                    .foregroundStyle(.merkas.opacity(0.1))
                                    .frame(maxWidth: isSelected ? .infinity : 0, maxHeight: isSelected ? .infinity : 0)
                                    .allowsHitTesting(false)
                                    .clipped()
                                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                    
                    TabView(selection: $selectedTab) {
                        Referrals(referrals: allReferrals)
                            .tag(ReferralsTabsEnum.all)
                            .refreshable {
                                Task {
                                    await getReferrals()
                                }
                            }
                        
                        Referrals(referrals: directReferrals)
                            .tag(ReferralsTabsEnum.direct)
                        
                        Referrals(referrals: indirectReferrals)
                            .tag(ReferralsTabsEnum.indirect)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: loadingData)
            .animation(.easeInOut(duration: 0.2), value: allReferrals.count)
            .navigationTitle(.tabReferrals)
            .navigationBarTitleDisplayMode(messageError.isEmpty ? .inline : .large)
            .toolbar {
                NavigationLink(destination: AddFriends()) {
                    Image(systemName: "person.fill.badge.plus")
                }
            }
            .navigationDestination(isPresented: $navigateToAddFriends) {
                AddFriends()
            }
        }
        .onAppear {
            if appState.navigateToAddFriend {
                navigateToAddFriends = true
                appState.navigateToAddFriend = false
            }
            
            Task {
                if allReferrals.isEmpty {
                    await getReferrals()
                }
            }
        }
    }
    
    private func getReferrals() async {
        Task {
            loadingData = true
            if appState.user != nil {
                let result = await ReferralsService.shared.fetchReferrals(userId: appState.user?.usuarioId ?? "", token: token)
                switch result {
                case .success(let referrals):
                    print("✅ Llamada exitosa, revisa la consola para ver el JSON", referrals)
                    allReferrals = referrals
                    
                    loadingData = false
                case .failure(let mensaje):
                    print("❌ Error:", mensaje)
                    if mensaje.contains("token_incorrecto") || mensaje.contains("token_vencido") {
                        await getToken()
                    } else {
                        messageError = mensaje
                        loadingData = false
                    }
                }
            } else {
                loadingData = false
                await getReferrals()
            }
        }
    }
    private func getToken() async {
        loadingData = true
        do {
            if let newToken = try await TokenService.obtenerToken(baseURL: baseURL) {
                token = newToken
                print("Token guardado en AppStorage:", token)
                await getReferrals()
            } else {
                print("No se recibió token válido")
                loadingData = false
            }
        } catch {
            print("Error obteniendo token:", error)
            loadingData = false
        }
    }
}

enum ReferralsTabsEnum: Hashable, CaseIterable {
    case all, direct, indirect
    
    var title: LocalizedStringKey {
        switch self {
        case .all: return "referralsAll"
        case .direct: return "referralsDirect"
        case .indirect: return "referralsIndirect"
        }
    }
}

struct ReferralsButtons: View {
    @Binding var selectedTab: ReferralsTabsEnum
    
    var body: some View {
        HStack {
            ForEach(ReferralsTabsEnum.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    Text(tab.title)
                        .font(.footnote.bold())
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
            }
        }
    }
}


#Preview {
    ReferralsScreen()
}
