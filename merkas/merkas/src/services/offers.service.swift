//
//  offers.service.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 30/9/25.
//

import Foundation

struct OffersProps: Codable, Identifiable {
    let id: String
    let titulo: String
    let icono: String
    let color: String
    let data: [OfferData]

    // Siempre generamos un id único
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titulo = try container.decode(String.self, forKey: .titulo)
        icono = try container.decode(String.self, forKey: .icono)
        color = try container.decode(String.self, forKey: .color)
        data = try container.decode([OfferData].self, forKey: .data)
        id = try container.decode(String.self, forKey: .id)
    }

    enum CodingKeys: String, CodingKey {
        case id, titulo, icono, color, data
    }
}

struct OfferData: Codable, Identifiable {
    let id: String
    let miniBannerPromocion: MiniBannerPromocion
    let comercio: Comercio

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        miniBannerPromocion = try container.decode(MiniBannerPromocion.self, forKey: .miniBannerPromocion)
        comercio = try container.decode(Comercio.self, forKey: .comercio)
        id = miniBannerPromocion.id
    }

    enum CodingKeys: String, CodingKey {
        case miniBannerPromocion, comercio
    }
}

struct MiniBannerPromocion: Codable {
    let imagen: String
    let nombreComercio: String
    let id: String
}

struct Comercio: Codable {
    let aliado_merkas_ruta_imagen_portada: String
    let facebook: String
    let youtube: String
    let website: String
}


struct OffersErrorResponse: Codable {
    let mensaje: String
}

enum OffersResult {
    case success([OffersProps])
    case failure(String)
}

@MainActor
final class OffersService {
    static let shared = OffersService()
    private init() {}
    
    func getOffers(userId: String, token: String) async -> OffersResult {
        guard let url = URL(string: "\(baseURL)/function-api.php?title=todas_ofertas&token=\(token)") else {
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
            if let users = try? JSONDecoder().decode([OffersProps].self, from: data) {
                return .success(users)
            }
            
            // Intentamos decodificar mensaje de error
            if let errorResponse = try? JSONDecoder().decode(OffersErrorResponse.self, from: data) {
                return .failure(errorResponse.mensaje)
            }
            
            return .failure("unknown_response")
        } catch {
            return .failure("Error de red: \(error.localizedDescription)")
        }
    }
}
