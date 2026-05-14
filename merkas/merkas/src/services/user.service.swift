//
//  user.service.swift
//  merkas
//
//  Created by Edwin egue on 7/01/26.
//
import Foundation
import UIKit
import Combine
struct ActualizarPerfilResponse : Codable{
    let validation:String
    let message:String
    let data: PerfilData?
}

struct PerfilData: Codable{
    let usuario_nombre: String
    let usuario_apellido: String
    let usuario_nombre_completo: String
    let usuario_ruta_img: String?
}

struct Usuario: Codable{
    var usuario_id: String
    var usuario_nombre: String
    var usuario_apellido: String
    var usuario_nombre_complet: String
    var usuario_correo: String
    var usuario_celular: String
    var usuario_ruta_img: String?
}

enum ProfileServiceErrorResponse: Error {
    case invalidURL
    case noToken
    case noResponse
    case invalidResponse
    case serverError(String)
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noToken:
            return "No Token"
        case .noResponse:
            return "No Response"
        case .invalidResponse:
            return "Invalid Response"
        case .serverError(let message):
            return "Server Error: \(message)"
        case .networkError(let error):
            return "Network Error: \(error.localizedDescription)"
        }
    }
}

class ProfileService{
    static let shared = ProfileService()
    
    private let apiEndpoint:String = "/function-api-registro.php?title=actualizar_perfil"
    
    private init(){
        
    }
    
    func actualizarPerfil(usuarioId:String,
                          firstName:String,
                          lastName:String,
                          image:UIImage? = nil,
                          token:String)async throws -> ActualizarPerfilResponse{
        
        guard let url = URL(string: baseURL + apiEndpoint) else {
            throw ProfileServiceErrorResponse.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let httpBody = createMultipartBody(
            boundary: boundary,
            usuarioId: usuarioId,
            nombre: firstName.uppercased(),
            apellido: lastName.uppercased(),
            token: token,
            image: image)
        request.httpBody = httpBody
        
        do{
            let (data , response ) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ProfileServiceErrorResponse.noResponse
            }
            
            let decoder = JSONDecoder()
            let resultado = try decoder.decode(ActualizarPerfilResponse.self, from: data)
            
            if resultado.validation == "registro_exitoso" {
                print(resultado)
            }
            
            return resultado
        } catch let error as ProfileServiceErrorResponse{
            throw error
        }catch{
            throw ProfileServiceErrorResponse.networkError(error)
        }
        
    }
    
    
    
    
    
    
    private func createMultipartBody(boundary:String , usuarioId:String, nombre:String, apellido:String, token:String, image:UIImage?)-> Data{
        
        var body = Data()
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"usuario_id\"\r\n\r\n")
        body.append("\(usuarioId)\r\n")
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"usuario_nombre\"\r\n\r\n")
        body.append("\(nombre)\r\n")
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"usuario_apellido\"\r\n\r\n")
        body.append("\(apellido)\r\n")
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"token\"\r\n\r\n")
        body.append("\(token)\r\n")
        if let imagen = image,
        let imageData = imagen.jpegData(compressionQuality: 0.8) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"profile.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        }
        body.append("--\(boundary)--\r\n")
        return body
        
    }

    
}

extension Data{
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    func actualizarPerfil(usuarioId: String, nombre:String, apellido:String, imagen:UIImage? = nil , token:String) async{
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do{
            let response = try await ProfileService.shared.actualizarPerfil(
                usuarioId: usuarioId, firstName: nombre, lastName: apellido, token: token)
            if response.validation == "registro_exitoso"{
                successMessage = "Perfil actualizado correctamente"
            }else{
                errorMessage = "No se pudo actualizar el perfil"
            }
        }catch let error as ProfileServiceErrorResponse{
            errorMessage = error.localizedDescription
        }catch{
            errorMessage = "Error inesperado, intente más tarde"
        }
        
        isLoading = false
    }
}
