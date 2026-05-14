import SwiftUI
import PhotosUI

struct Profile: View {
    @EnvironmentObject var appState: AppState
    @State private var profileImage: Image? = Image(systemName: "person.circle.fill")
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    
    @State private var showSupportAlert: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var isEditing = false
    
    @StateObject private var viewModel = ProfileViewModel()
    @AppStorage(StorageKeys.TOKEN.rawValue) private var token: String = ""
    
    // Computed properties movidas fuera de body
    private var nombreBinding: Binding<String> {
        Binding(
            get: { self.appState.user?.usuarioNombre ?? "" },
            set: { self.appState.user?.usuarioNombre = $0 }
        )
    }
    
    private var apellidoBinding: Binding<String> {
        Binding(
            get: { self.appState.user?.usuarioApellido ?? "" },
            set: { self.appState.user?.usuarioApellido = $0 }
        )
    }
    
    private var documentoBinding: Binding<String> {
        Binding(
            get: { self.appState.user?.usuarioNumeroDocumento ?? "" },
            set: { self.appState.user?.usuarioNumeroDocumento = $0 }
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                scrollContent
                
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .navigationTitle("Mi Perfil")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveEditButton
                }
            }
            .alert("Contactar Soporte", isPresented: $showSupportAlert) {
                Button("Cerrar", role: .cancel) {}
            } message: {
                Text("Para cambios en correo o celular, comuníquese con soporte técnico al icono de soporte")
            }
            .alert("Perfil Actualizado", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.successMessage ?? "Tu perfil ha sido actualizado exitosamente")
            }
            .onAppear {
                cargarDatosUsuario()
            }
            .onChange(of: viewModel.successMessage) { message in
                if message != nil {
                    showSuccessAlert = true
                    isEditing = false
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 25) {
                profileImageSection
                informationSection
                supportSection
                errorMessageSection
                Spacer()
            }
        }
        .disabled(viewModel.isLoading)
    }
    
    private var profileImageSection: some View {
        VStack {
            if let profileImage = profileImage {
                profileImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 3))
            }
            
            if isEditing {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Cambiar foto")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.top, 8)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedUIImage = uiImage
                            profileImage = Image(uiImage: uiImage)
                        }
                    }
                }
            }
        }
        .padding(.top, 20)
    }
    
    private var informationSection: some View {
        VStack(spacing: 20) {
            ProfileField(
                icon: "person.fill",
                label: "Nombre",
                text: nombreBinding,
                isEditable: isEditing
            )
            
            ProfileField(
                icon: "person.fill",
                label: "Apellido",
                text: apellidoBinding,
                isEditable: isEditing
            )
            
            ProfileField(
                icon: "creditcard.and.123",
                label: "Documento de identidad",
                text: documentoBinding,
                isEditable: isEditing
            )
        }
        .padding(.horizontal)
    }
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.merkas)
                Text("Debe comunicarse con soporte técnico para el cambio de correo electronico o número de teléfono.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Button(action: {
                showSupportAlert = true
            }) {
                HStack {
                    Image(systemName: "headphones")
                    Text("Contactar Soporte")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.merkas)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var errorMessageSection: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.caption)
                .foregroundColor(.red)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text("Actualizando Perfil")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(30)
            .background(Color.black.opacity(0.7))
            .cornerRadius(15)
        }
    }
    
    private var saveEditButton: some View {
        Button(isEditing ? "Guardar" : "Editar") {
            if isEditing {
                Task {
                    await guardarCambios(
                        usuarioId: String(appState.user?.usuarioId ?? ""),
                        nombre: appState.user?.usuarioNombre ?? "",
                        apellido: appState.user?.usuarioApellido ?? "",
                        imagen: selectedUIImage,
                        token: token
                    )
                }
            } else {
                withAnimation {
                    isEditing = true
                }
            }
        }
        .disabled(viewModel.isLoading)
    }
    
    // MARK: - Functions
    
    private func cargarDatosUsuario() {
        // Implementar carga de datos
    }
    
    private func cargarImagenPerfil(url: String) {
        // Implementar carga de imagen
    }
    
    private func guardarCambios(
        usuarioId: String,
        nombre: String,
        apellido: String,
        imagen: UIImage?,
        token: String
    ) async {
        await viewModel.actualizarPerfil(
            usuarioId: usuarioId,
            nombre: nombre,
            apellido: apellido,
            imagen: imagen,
            token: token
        )
    }
}

// MARK: - ProfileField

struct ProfileField: View {
    let icon: String
    let label: String
    @Binding var text: String
    let isEditable: Bool
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if isEditable {
                TextField("", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
            } else {
                Text(text)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
}
