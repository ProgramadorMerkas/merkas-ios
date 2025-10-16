//
//  EcommerceScreen.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 5/10/25.
//

import SwiftUI

struct EcommerceScreen: View {
    @EnvironmentObject var appState: AppState
    @AppStorage(StorageKeys.TOKEN.rawValue) private var token: String = ""
    
    @State var commerceId: String = ""
    var titleCategory: String?
    @State private var selection: EcommerceTabEnum = .info
    @State private var info: EcommerceInfoProps? = nil
    @State private var products: [EcommerceProductsProps]? = nil
    @State private var gallery: [EcommerceGalleryProps]? = nil
    @State private var videos: [EcommerceVideoProps]? = nil
    @State private var isLoading: Bool = true
    @State private var errorInEcommerce: Bool = false
    
    var body: some View {
        ZStack {
            if isLoading {
                Loading(message: "ecommerceLoading")
            } else {
                Working()
                if false {
                    TabView(selection: $selection) {
                        if info != nil {
                            EcommerceInfo(info: $info)
                                .tag(EcommerceTabEnum.info)
                        }
                        
                        if products != nil {
                            EcommerceProducts(products: $products)
                                .tag(EcommerceTabEnum.products)
                        }
                        
                        if gallery != nil {
                            EcommerceGallery(gallery: $gallery)
                                .tag(EcommerceTabEnum.galery)
                        }
                        
                        if videos != nil {
                            EcommerceVideos(videos: $videos)
                                .tag(EcommerceTabEnum.videos)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.2), value: selection)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .navigationTitle(.workingAppTitle)
        .navigationSubtitle(titleCategory ?? "")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                isLoading = false
                //await getEcommerceData()
                appState.navigateEcommerceId = ""
            }
        }
    }
    
    func getEcommerceData() async {
        Task {
            isLoading = true
            if appState.user != nil {
                let result = await EcommerceService.shared.getProducts(ecommerceId: commerceId, token: token)
                switch result {
                case .success(let ecommerce):
                    print("✅ ECOMMERCE - RESPONSE:", ecommerce)
                    // allReferrals = referrals
                    
                    isLoading = false
                case .failure(let mensaje):
                    print("❌ Error:", mensaje)
                    if mensaje.contains("token_incorrecto") || mensaje.contains("token_vencido") {
                        await getToken()
                    } else {
                        errorInEcommerce = true
                        isLoading = false
                    }
                }
            } else {
                isLoading = false
                await getEcommerceData()
            }
        }
    }
    private func getToken() async {
        isLoading = true
        do {
            if let newToken = try await TokenService.obtenerToken(baseURL: baseURL) {
                token = newToken
                print("Token guardado en AppStorage:", token)
                await getEcommerceData()
            } else {
                print("No se recibió token válido")
                isLoading = false
                errorInEcommerce = true
            }
        } catch {
            print("Error obteniendo token:", error)
            isLoading = false
            errorInEcommerce = true
        }
    }
}

struct EcommerceInfo: View {
    @Binding var info: EcommerceInfoProps?
    
    var body: some View {
        ScrollView {
        }
    }
}

struct EcommerceProducts: View {
    @Binding var products: [EcommerceProductsProps]?
    
    var body: some View {
        ScrollView {
        }
    }
}

struct EcommerceGallery: View {
    @Binding var gallery: [EcommerceGalleryProps]?
    
    var body: some View {
        ScrollView {
        }
    }
}

struct EcommerceVideos: View {
    @Binding var videos: [EcommerceVideoProps]?
    
    var body: some View {
        ScrollView {
        }
    }
}

enum EcommerceTabEnum: Hashable, CaseIterable {
    case info, products, galery, videos
    
    var title: LocalizedStringKey {
        switch self {
        case .info: return "ecommerceInfo"
        case .products: return "ecommerceProducts"
        case .galery: return "ecommerceGallery"
        case .videos: return "ecommerceVideos"
        }
    }
}
