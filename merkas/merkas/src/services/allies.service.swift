//
//  allies.service.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 3/10/25.
//

import Foundation

struct AlliesResponse: Codable {
    let aliadosMapas: [AlliesProps]

    enum CodingKeys: String, CodingKey {
        case aliadosMapas = "aliados_mapas"
    }
}

struct AlliesProps: Codable, Identifiable {
    var latitud: String
    var longitud: String
    let usuarioRutaImg: String
    let icono: String
    let iconoNegro: String
    let nombreCompleto: String
    let categoria: String
    let profesional: Bool
    let ubicacion: Int
    let color: String
    let id: String
    let whatsapp: String
    let direccion: String
    let usuarioId: String
    let pines: String

    enum CodingKeys: String, CodingKey {
        case latitud = "aliado_merkas_sucursal_latitud"
        case longitud = "aliado_merkas_sucursal_longitud"
        case usuarioRutaImg = "usuario_ruta_img"
        case icono
        case iconoNegro = "icono_negro"
        case nombreCompleto = "usuario_nombre_completo"
        case categoria
        case profesional
        case ubicacion
        case color
        case id
        case whatsapp
        case direccion
        case usuarioId = "usuario_id"
        case pines
    }
}

struct AlliesErrorResponse: Codable {
    let mensaje: String
}

enum AlliesResult {
    case success([AlliesProps])
    case failure(String)
}

@MainActor
final class AlliesService {
    static let shared = AlliesService()
    private init() {}
    
    func getAllies(token: String) async -> AlliesResult {
        guard let url = URL(string: "\(baseURL)/function-api.php?title=aliados_ubicacion&token=\(token)") else {
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

            if let response = try? JSONDecoder().decode(AlliesResponse.self, from: data) {
                return .success(response.aliadosMapas)
            }
            
            // Intentamos decodificar mensaje de error
            if let errorResponse = try? JSONDecoder().decode(AlliesErrorResponse.self, from: data) {
                return .failure(errorResponse.mensaje)
            }
            
            return .failure("unknown_response")
        } catch {
            return .failure("Error de red: \(error.localizedDescription)")
        }
    }
}
