//
//  token.service.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import Foundation

enum TokenError:LocalizedError{
    case urlInvalida
    case NotConnection
    case errorServer(statusCode: Int)
    case invalidReponse
    case rejectToken(message : String)
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .urlInvalida:
            return "URL Invalida"
        case .NotConnection:
            return "No hay conexion a internet"
        case .errorServer(statusCode: let statusCode):
            return "Error en el servidor con statusCode: \(statusCode)"
        case .invalidReponse:
            return "Respuesta invalida"
        case .rejectToken(message: let message):
            return "\(message)"
        case .timeout:
            return "Tiempo de espera agotado"
        }
    
    }
}

struct TokenService {
    static func obtenerToken(baseURL: String) async throws -> String {
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
        
        let data : Data
        let response : URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let urlError as URLError{
            switch urlError.code{
            case .notConnectedToInternet, .networkConnectionLost:
                throw TokenError.NotConnection
            case .timedOut:
                throw TokenError.timeout
            default:
                throw TokenError.NotConnection
            }
        }
        
        let rawResponse = String(data: data, encoding: .utf8) ?? "No se pudo leer"
            print("� URL llamada:", url.absoluteString)
            print("� Body enviado:", body)
            print("� Respuesta raw del servidor:", rawResponse)
        
        if let httpResponse = response as? HTTPURLResponse,
           !(200...209).contains(httpResponse.statusCode){
            throw TokenError.errorServer(statusCode: httpResponse.statusCode)
        }
        let cleanData = Data(rawResponse.trimmingCharacters(in: .whitespacesAndNewlines).utf8)
        guard let json = try JSONSerialization.jsonObject(with: cleanData) as? [String:Any] else {
            throw TokenError.invalidReponse
        }
        
        guard let mensaje = json["mensaje"] as? String, !mensaje.isEmpty else {
            let errorMsg = json["error"] as? String ?? "No se pudo obtener el token"
            throw TokenError.rejectToken(message: errorMsg)
            
        }
        
        return createToken
        //let (data, _) = try await URLSession.shared.data(for: request)
        ///let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        /*if let mensaje = json?["mensaje"] as? String, !mensaje.isEmpty {
            // El backend acepta → guardamos el createToken
            print(createToken)
            return createToken
        }
        
        return nil*/
    }
}
