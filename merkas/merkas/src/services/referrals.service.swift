//
//  referrals.services.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 29/9/25.
//

import Foundation

struct ReferredUser: Codable {
    let usuario_fecha_registro: String
    let usuario_nombre_completo: String
    let usuario_numero_documento: String
    let usuario_ruta_img: String
    let concepto: String
    let usuario_id: String
    let usuario_telefono: String
    let usuario_puntos: String
    let municipio_nombre: String
    let departamento_nombre: String
    let usuario_correo: String
    let usuario_estado: String
}

struct ReferralsErrorResponse: Codable {
    let mensaje: String
}

enum ReferralsResult {
    case success([ReferredUser])
    case failure(String)
}

@MainActor
final class ReferralsService {
    static let shared = ReferralsService()
    private init() {}
    
    func fetchReferrals(userId: String, token: String) async -> ReferralsResult {
        guard let url = URL(string: "\(baseURL)/function-api.php?title=usuariohijosnietos&id=\(userId)&token=\(token)") else {
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
            
            // Intentamos decodificar array de usuarios
            if let users = try? JSONDecoder().decode([ReferredUser].self, from: data) {
                return .success(users)
            }
            
            // Intentamos decodificar mensaje de error
            if let errorResponse = try? JSONDecoder().decode(ReferralsErrorResponse.self, from: data) {
                return .failure(errorResponse.mensaje)
            }
            
            return .failure("unknown_response")
        } catch {
            return .failure("Error de red: \(error.localizedDescription)")
        }
    }
}
