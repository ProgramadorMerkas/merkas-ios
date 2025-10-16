//
//  AlliesScreen.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 29/9/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

struct AlliesScreen: View {
    var body: some View {
        NavigationStack {
            AlliesMap()
                .navigationTitle(.tabAllies)
                .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - SearchCompleter para sugerencias
private final class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [MKLocalSearchCompletion] = []
    private let completer: MKLocalSearchCompleter
    
    override init() {
        completer = MKLocalSearchCompleter()
        completer.resultTypes = .address
        super.init()
        completer.delegate = self
    }
    
    func updateQuery(_ query: String) {
        completer.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.results = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.results = []
        }
    }
}

struct AlliesMap: View {
    @EnvironmentObject var appState: AppState
    @AppStorage(StorageKeys.TOKEN.rawValue) private var token: String = ""
    
    @State private var keyboardHeight: CGFloat = 0
    @State private var searchText: String = ""
    @StateObject private var searchCompleter = SearchCompleter()
    @State var isLoadingAllies: Bool = false
    @State var errorInGetAllies: Bool = false
    @State var allies: [AlliesProps] = []
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        ZStack {
            if isLoadingAllies {
                Loading(message: "loadingAllies")
            } else if errorInGetAllies && !isLoadingAllies {
                Label(.errorAllies, systemImage: "exclamationmark.circle")
                    .font(.headline.bold())
                    .foregroundColor(.merkas2)
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
            } else if !allies.isEmpty && !isLoadingAllies {
                Map(position: $position) {
                    UserAnnotation()
                    
                    ForEach(allies, id: \.id) { ally in
                        Annotation(
                            ally.nombreCompleto,
                            coordinate: CLLocationCoordinate2D(
                                latitude: Double(ally.latitud) ?? 0,
                                longitude: Double(ally.longitud) ?? 0)
                        ) {
                            AlliesMarker(ally: ally)
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                // 🔍 Buscador nativo con sugerencias
                .searchable(text: $searchText, prompt: "searchCity")
                .onChange(of: searchText) { _, newValue in
                    searchCompleter.updateQuery(newValue)
                }
                .searchSuggestions {
                    ForEach(searchCompleter.results, id: \.self) { suggestion in
                        Text(suggestion.title + " " + suggestion.subtitle)
                            .searchCompletion(suggestion.title + " " + suggestion.subtitle)
                    }
                }
                .onSubmit(of: .search) {
                    searchCity(named: searchText)
                }
                .scrollDismissesKeyboard(.interactively)
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if keyboardHeight > 0 {
                                Button(action: {
                                    UIApplication.shared.sendAction(
                                        #selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil
                                    )
                                }) {
                                    Image(systemName: "chevron.down")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.merkas)
                                        .padding()
                                }
                                .background(.ultraThinMaterial, in: Circle())
                                .padding(.trailing, 16)
                                .padding(.bottom, 8) // separacion sobre el teclado
                                .buttonStyle(.plain)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .animation(.easeInOut, value: keyboardHeight)
                            }
                        }
                    }
                )
                .onReceive(Publishers.keyboardHeight) { height in
                    keyboardHeight = height
                }
            } else {
                Label(.alliesEmpty, systemImage: "mappin.slash")
                    .font(.headline.bold())
                    .foregroundColor(.merkas2)
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoadingAllies)
        .onAppear {
            Task {
                allies = appState.allies
                if !appState.alliesFetched {
                    await getAllies()
                }
            }
        }
        .onChange(of: appState.allies.count) { _, _ in
            allies = appState.allies
        }
    }
    
    // MARK: - Buscar ciudad
    private func searchCity(named name: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = name
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let item = response?.mapItems.first,
                  let coord = item.placemark.location?.coordinate else { return }
            
            withAnimation {
                position = .region(MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                ))
            }
        }
    }
    
    // MARK: - Allies y token
    private func getAllies() async {
        Task {
            isLoadingAllies = true
            errorInGetAllies = false
            
            if appState.user != nil {
                let result = await AlliesService.shared.getAllies(token: token)
                switch result {
                case .success(let allies):
                    appState.allies = allies
                    appState.alliesFetched = true
                    isLoadingAllies = false
                case .failure(let mensaje):
                    if mensaje.contains("token_incorrecto") || mensaje.contains("token_vencido") {
                        await getToken()
                    } else {
                        isLoadingAllies = false
                        errorInGetAllies = true
                    }
                }
            } else {
                isLoadingAllies = false
                await getToken()
            }
        }
    }
    
    private func getToken() async {
        isLoadingAllies = true
        do {
            if let newToken = try await TokenService.obtenerToken(baseURL: baseURL) {
                token = newToken
                await getAllies()
            } else {
                isLoadingAllies = false
                errorInGetAllies = true
            }
        } catch {
            isLoadingAllies = false
            errorInGetAllies = true
        }
    }
}

// MARK: - Publisher para detectar teclado
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0 }
        
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

private struct AlliesMarker: View {
    var ally: AlliesProps
    @State private var showSheet: Bool = false
    
    var body: some View {
        Image(systemName: "mappin.and.ellipse.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 25, height: 25)
            .foregroundStyle(hexToColor(ally.color) ?? .merkas)
            .onTapGesture {
                showSheet = true
            }
            .onPressImpact(.soft)
            .sheet(isPresented: $showSheet) {
                NavigationStack {
                    AllyDetailScreen(ally: ally)
                        .presentationDetents([.medium])
                }
                .presentationDetents([.medium])
            }
    }
}

// MARK: - Allies Mini
struct AlliesMini: View {
    var action: () -> Void
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    private let locationManager = CLLocationManager()
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                UserAnnotation()
            }
            
            Button(action: {
                action()
            }) {
                ZStack {
                    Rectangle()
                        .fill(.merkas.opacity(0))
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .cornerRadius(10)
                    
                    VStack {
                        Text(.showMore)
                            .font(.footnote)
                            .foregroundStyle(.white)
                            .foregroundStyle(.black)
                            .padding(5)
                            .padding(.horizontal, 5)
                            .background(.merkas)
                            .background(.white)
                            .cornerRadius(8)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            }
            .onPressImpact(.soft)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .cornerRadius(10)
        .clipped()
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

#Preview {
    AlliesScreen()
}
