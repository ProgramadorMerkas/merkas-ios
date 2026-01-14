//
//  referrals.services.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 29/9/25.
//. Modified by Edwin Egue 12/12/2025

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
    
    init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let idString = try? container.decode(String.self, forKey: .usuario_id) {
            usuario_id = idString
        }else if let idInt = try? container.decode(Int.self, forKey: .usuario_id) {
            usuario_id = "\(idInt)"
        }else{
            usuario_id = ""
        }
        usuario_correo = try container.decode(String.self, forKey: .usuario_correo)
        usuario_fecha_registro = try container.decode(String.self, forKey: .usuario_fecha_registro)
        usuario_nombre_completo = try container.decode(String.self, forKey: .usuario_nombre_completo)
        usuario_numero_documento = try container.decode(String.self, forKey: .usuario_numero_documento)
        usuario_ruta_img = try container.decode(String.self, forKey: .usuario_ruta_img)
        concepto = try container.decode(String.self, forKey: .concepto)
        usuario_telefono = try container.decode(String.self, forKey: .usuario_telefono)
        usuario_puntos = try container.decode(String.self, forKey: .usuario_puntos)
        municipio_nombre = try container.decode(String.self, forKey: .municipio_nombre)
        departamento_nombre = try container.decode(String.self, forKey: .departamento_nombre)
        
        if let estadoInt = try? container.decode(Int.self, forKey: .usuario_estado) {
            usuario_estado = "\(estadoInt)"
        }else if let estadoString = try? container.decode(String.self, forKey: .usuario_estado) {
            usuario_estado = estadoString
        }else{
            usuario_estado = ""
        }
    }
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
        //print("url endpoint: " ,  request)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            //print("Response solicitud" , data)
            if let httpResponse = response as? HTTPURLResponse,
               !(200..<300).contains(httpResponse.statusCode) {
                return .failure("HTTP Error: \(httpResponse.statusCode)")
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Respuesta JSON cruda:")
                print(jsonString)
            }
            
            // Intentamos decodificar array de usuarios
             
            if let users = try? JSONDecoder().decode([ReferredUser].self, from: data){
                //print("users:" , users)
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
