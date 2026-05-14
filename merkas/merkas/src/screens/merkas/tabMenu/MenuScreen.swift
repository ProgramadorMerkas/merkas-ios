//
//  MenuScreen.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 29/9/25.
//

import SwiftUI

struct MenuScreen: View {
    @EnvironmentObject var appState: AppState
    @AppStorage(StorageKeys.LOGGED_IN.rawValue) private var loggedIn: Bool = false
    @AppStorage(StorageKeys.TOKEN.rawValue) private var token: String = ""
    @AppStorage(StorageKeys.CORREO.rawValue) private var correo: String = ""
    @AppStorage(StorageKeys.CONTRASENA.rawValue) private var contrasena: String = ""
    @State private var showAlertSignOut: Bool = false
    @State private var isLoadingSignOut: Bool = false
    @State private var navigateToEditProfile: Bool = false
    
    var body: some View {
        let name :String = "\(appState.user != nil ? "\(appState.user!.usuarioNombreCompleto)" : "")"
        let rol : String = "\(appState.user != nil ? "\(appState.user!.usuarioRolPrincipal)" : "")"
        let puntos: String = "\(appState.user != nil ? "\(appState.user!.usuarioPuntos)" : "")"
        let merkash: String = "\(appState.user != nil ? "\(appState.user!.usuarioMerkash)" : "")"
        NavigationStack {
            VStack(spacing: 0) {
                
                ZStack(alignment: .bottom){
                    Color.merkas
                        .frame(height: 150)
                        .ignoresSafeArea(edges: .top)
                    
                    VStack(spacing: 8){
                        ZStack{
                            Circle()
                                .fill(Color.white)
                                .frame(width: 100, height: 100)
                                .shadow(color: .black.opacity(0.1), radius: 10, x:0, y:5)
                            Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .frame(width: 95, height: 95)
                                                    .foregroundColor(.gray.opacity(0.3))
                            
                        }
                        Text(name).font(.title2.bold())
                            .foregroundColor(.primary)
                        
                    }
                    .offset(y:20)
                }
                
                
                HStack{
                    Text(rol).font(.title3)
                        .foregroundStyle(.secondary)
                }.offset(y:50)
                Spacer()
                           .frame(height: 70)
                
                 
                        HStack(spacing: 16) {
                           
                            VStack(spacing: 8) {
                                Image(systemName: "star.circle")
                                    .font(.title2)
                                    .foregroundColor(Color.white)
                                
                                Text("Mis puntos")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Text(puntos)
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color(.merkas))
                            .cornerRadius(12)
                            
                            
                            VStack(spacing: 8) {
                                Image(systemName: "wallet.pass")
                                    .font(.title2)
                                    .foregroundColor(Color.white)
                                
                                Text("Mi Merkash")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Text(merkash)
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color(Color.merkas))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 12) {
                        // Botón Editar Perfil
                        NavigationLink(destination: Profile()){
                            HStack {
                                Image(systemName: "person.circle")
                                    .font(.title3)
                                    .foregroundColor(.merkas)
                                
                                Text("Editar Perfil")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Botón Mis Compras
                        Button(action: {
                            // Acción para mis compras
                        }) {
                            HStack {
                                Image(systemName: "bag")
                                    .font(.title3)
                                    .foregroundColor(.merkas)
                                
                                Text("Mis Compras")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Botón Mis Puntos
                        Button(action: {
                            // Acción para mis puntos
                        }) {
                            HStack {
                                Image(systemName: "star.circle")
                                    .font(.title3)
                                    .foregroundColor(.merkas)
                                
                                Text("Mis Puntos")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Botón Invitar Amigos
                        NavigationLink(destination: AddFriends()) {
                            HStack {
                                Image(systemName: "person.2")
                                    .font(.title3)
                                    .foregroundColor(.merkas)
                                
                                Text("Invitar Amigos")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Botón Mi Merkash
                        Button(action: {
                            // Acción para mi merkash
                        }) {
                            HStack {
                                Image(systemName: "wallet.pass")
                                    .font(.title3)
                                    .foregroundColor(.merkas)
                                
                                Text("Mi Merkash")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                
                Button (action: {
                    isLoadingSignOut = true
                    showAlertSignOut = true
                }) {
                    ZStack {
                        if isLoadingSignOut {
                            ProgressView()
                                .tint(.white)
                                .font(.footnote.bold())
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        } else {
                            Label(.signOut, systemImage: "iphone.and.arrow.right.outward")
                                .font(.footnote.bold())
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isLoadingSignOut)
                }
                .disabled(isLoadingSignOut)
                .buttonStyle(.glassProminent)
                .onPressImpact(.soft)
                .alert(.signOut, isPresented: $showAlertSignOut) {
                    Button(.signOutAlertNo, role: .cancel) {
                        isLoadingSignOut = false
                    }
                    Button(.signOutAlertYes, role: .destructive) {
                        signOut()
                    }
                } message: {
                    Text(.signOutAlertConfirm)
                }
                .padding(.horizontal, 20)
                
                VersionApp()
            } 
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func signOut() {
        appState.isLoading = true
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        appState.currentCategoryOffers = "all"
        appState.user = nil
        appState.offers = []
        appState.currentOffers = nil
        appState.isLoggedIn = false
        loggedIn = false
        appState.isLoading = false
        isLoadingSignOut = false
    }
}

#Preview {
    MenuScreen()
}
