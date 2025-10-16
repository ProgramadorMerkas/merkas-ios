//
//  token.service.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import Foundation

struct TokenService {
    static func obtenerToken(baseURL: String) async throws -> String? {
        // Generar UUID como en TS
        let createToken = UUID().uuidString
        let body: [String: Any] = [
            "create_token": createToken,
            "token": "7242b219185a6ecd76e2f0de1a178928" // el fijo del proyecto TS
        ]
        
        guard let url = URL(string: "\(baseURL)/function-api-token.php?title=token") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let mensaje = json?["mensaje"] as? String, !mensaje.isEmpty {
            // El backend acepta → guardamos el createToken
            return createToken
        }
        
        return nil
    }
}
