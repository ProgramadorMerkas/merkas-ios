//
//  ecommerce.service.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 5/10/25.
//

import Foundation

struct EcommerceIdProps: Codable {
    let usuario_id: String
}

enum EcommerceIdResult {
    case success(EcommerceIdProps)
    case failure(String)
}

struct EcommerceInfoProps: Codable {
}

enum EcommerceInfoResult {
    case success(EcommerceInfoProps)
    case failure(String)
}

struct EcommerceProductsProps: Codable, Identifiable {
    let id: String
    let usuario_id: String
    let producto_categoria_id: String
    let producto_fecha_registro: String
    let producto_estado: String
    let producto_destacado: String
    let producto_nombre: String
    let producto_descripcion: String
    let producto_precio_final: String
    let producto_ruta_img: String
    let uri: String

    enum CodingKeys: String, CodingKey {
        case id = "producto_id"
        case usuario_id
        case producto_categoria_id
        case producto_fecha_registro
        case producto_estado
        case producto_destacado
        case producto_nombre
        case producto_descripcion
        case producto_precio_final
        case producto_ruta_img
        case uri
    }
}

enum EcommerceProductsResult {
    case success([EcommerceProductsProps])
    case failure(String)
}

struct EcommerceGalleryProps: Codable {
}

enum EcommerceGalleryResult {
    case success([EcommerceGalleryProps])
    case failure(String)
}

struct EcommerceVideoProps: Codable {
}

enum EcommerceVideoResult {
    case success([EcommerceVideoProps])
    case failure(String)
}

struct EcommerceErrorResponse: Codable {
    let mensaje: String
}

@MainActor
final class EcommerceService {
    static let shared = EcommerceService()
    private init() {}
    private(set) var usuarioId: String?
    
    func getId(ecommerceId: String, token: String) async -> EcommerceIdResult {
        guard let url = URL(string: "\(baseURL)/function-api.php?title=aliados&id=\(ecommerceId)&token=\(token)") else {
            return .failure("URL inválida")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               !(200..<300).contains(httpResponse.statusCode) {
                return .failure("HTTP Error: \(httpResponse.statusCode)")
            }
            
            // Intentamos decodificar array de aliados
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Respuesta JSON cruda:")
                print(jsonString)
            }
            
            if let response = try? JSONDecoder().decode(EcommerceIdProps.self, from: data) {
                self.usuarioId = response.usuario_id
                return .success(response)
            }
            
            // Intentamos decodificar mensaje de error
            if let errorResponse = try? JSONDecoder().decode(EcommerceErrorResponse.self, from: data) {
                return .failure(errorResponse.mensaje)
            }
            
            return .failure("unknown_response")
        } catch {
            return .failure("Error de red: \(error.localizedDescription)")
        }
    }
    
    func getProducts(ecommerceId: String, token: String) async -> EcommerceProductsResult {
        if usuarioId == nil {
            let result = await getId(ecommerceId: ecommerceId, token: token)
            switch result {
            case .failure(let error):
                return .failure("Error al obtener ID: \(error)")
            case .success(let data):
                self.usuarioId = data.usuario_id
            }
        }
        
        guard let usuarioId = usuarioId else {
            return .failure("No se pudo obtener el usuario_id.")
        }
        
        guard let url = URL(string: "\(baseURL)/function-api.php?title=productos&usuario=\(usuarioId)&token=\(token)") else {
            return .failure("URL inválida")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               !(200..<300).contains(httpResponse.statusCode) {
                return .failure("HTTP Error: \(httpResponse.statusCode)")
            }
            
            // Intentamos decodificar array de aliados
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Respuesta JSON cruda:")
                print(jsonString)
            }
            
            if let response = try? JSONDecoder().decode([EcommerceProductsProps].self, from: data) {
                return .success(response)
            }
            
            // Intentamos decodificar mensaje de error
            if let errorResponse = try? JSONDecoder().decode(EcommerceErrorResponse.self, from: data) {
                return .failure(errorResponse.mensaje)
            }
            
            return .failure("unknown_response")
        } catch {
            return .failure("Error de red: \(error.localizedDescription)")
        }
    }
}
