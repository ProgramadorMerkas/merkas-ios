//
//  session.service.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI
import Foundation

struct LoginData: Codable {
    let correo: String
    let contrasena: String
    let token: String
}

struct LoginErrorResponse: Codable {
    let mensaje: String
}

enum LoginResult {
    case success(LoginResponse)
    case failure(String)
}

struct LoginResponse: Codable {
    let usuarioId: String
    let usuarioCodigo: String
    let usuarioNombre: String
    let usuarioApellido: String
    let usuarioNombreCompleto: String
    let usuarioCorreo: String
    let usuarioTelefono: String
    let usuarioWhatssap: String
    let usuarioNumeroDocumento: String
    let usuarioTipoDocumento: String
    let usuarioGenero: String
    let usuarioDireccion: String
    let usuarioRolPrincipal: String
    let usuarioStatus: String
    let usuarioEstado: String
    let usuarioFechaRegistro: String
    let usuarioMerkash: String
    let usuarioPuntos: String
    let usuarioIdPadre: String?
    let municipioId: String?
    let usuarioRutaImg: String
    let imagen: String
    
    // Opcionales
    let usuarioLatitud: String?
    let usuarioLongitud: String?
    let usuarioBienvenida: String?
    let usuarioContrasena: String?
    let usuarioTokenContrasena: String?
    let usuarioTokenFecha: String?
    let usuarioTokenMerkash: String?
    let usuarioTokenMerkashFecha: String?
    let usuarioTerminos: String?
    let usuarioLastLogin: String?
    
    enum CodingKeys: String, CodingKey {
        case usuarioId = "usuario_id"
        case usuarioCodigo = "usuario_codigo"
        case usuarioNombre = "usuario_nombre"
        case usuarioApellido = "usuario_apellido"
        case usuarioNombreCompleto = "usuario_nombre_completo"
        case usuarioCorreo = "usuario_correo"
        case usuarioTelefono = "usuario_telefono"
        case usuarioWhatssap = "usuario_whatssap"
        case usuarioNumeroDocumento = "usuario_numero_documento"
        case usuarioTipoDocumento = "usuario_tipo_documento"
        case usuarioGenero = "usuario_genero"
        case usuarioDireccion = "usuario_direccion"
        case usuarioRolPrincipal = "usuario_rol_principal"
        case usuarioStatus = "usuario_status"
        case usuarioEstado = "usuario_estado"
        case usuarioFechaRegistro = "usuario_fecha_registro"
        case usuarioMerkash = "usuario_merkash"
        case usuarioPuntos = "usuario_puntos"
        case usuarioIdPadre = "usuario_id_padre"
        case municipioId = "municipio_id"
        case usuarioRutaImg = "usuario_ruta_img"
        case imagen
        case usuarioLatitud = "usuario_latitud"
        case usuarioLongitud = "usuario_longitud"
        case usuarioBienvenida = "usuario_bienvenida"
        case usuarioContrasena = "usuario_contrasena"
        case usuarioTokenContrasena = "usuario_token_contrasena"
        case usuarioTokenFecha = "usuario_token_fecha"
        case usuarioTokenMerkash = "usuario_token_merkash"
        case usuarioTokenMerkashFecha = "usuario_token_merkash_fecha"
        case usuarioTerminos = "usuario_terminos"
        case usuarioLastLogin = "usuario_last_login"
    }
}


@MainActor
final class LoginService {
    static let shared = LoginService()
    private init() {}
    
    func login(data: LoginData) async throws -> LoginResult {
        guard let url = URL(string: "\(baseURL)/function-api.php?title=usuarios") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(data)
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            throw NSError(domain: "HTTPError", code: httpResponse.statusCode)
        }
        
        // Intentar decodificar primero como error
        if let errorResponse = try? JSONDecoder().decode(LoginErrorResponse.self, from: responseData) {
            return .failure(errorResponse.mensaje)
        }
        
        // Si no es error, intentar decodificar como usuario
        let userResponse = try JSONDecoder().decode(LoginResponse.self, from: responseData)
        return .success(userResponse)
    }
}

struct RegisterData {
    let nombre: String
    let apellido: String
    let telefono: String
    let correo: String
    let contrasena: String
    let token: String
}

struct RegisterSuccessResponse: Codable {
    let validacion: String
}

struct RegisterErrorResponse: Codable {
    let mensaje: String
}

enum RegisterResult {
    case success(RegisterSuccessResponse)
    case failure(String)
}

@MainActor
final class RegisterService {
    static let shared = RegisterService()
    private init() {}

    func register(data: RegisterData, title: String) async throws -> RegisterResult {
        guard let url = URL(string: "\(baseURL)/function-api-registro.php?title=\(title)") else {
            throw URLError(.badURL)
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer access-token", forHTTPHeaderField: "Authorization")
        
        // Crear el body multipart
        var body = Data()
        func appendField(name: String, value: String) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        appendField(name: "tipo", value: "normal")
        appendField(name: "usuario_id", value: "")
        appendField(name: "fileimagen", value: "")
        appendField(name: "usuario_social", value: "")
        appendField(name: "usuario_social_imagen", value: "")
        appendField(name: "nombre", value: data.nombre)
        appendField(name: "apellido", value: data.apellido)
        appendField(name: "usuario_telefono", value: data.telefono)
        appendField(name: "usuario_correo", value: data.correo)
        appendField(name: "contrasena", value: data.contrasena)
        appendField(name: "token", value: data.token)
        appendField(name: "usuario_numero_documento", value: "")
        
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            throw NSError(domain: "HTTPError", code: httpResponse.statusCode)
        }
        
        // Intentar decodificar primero como error
        if let errorResponse = try? JSONDecoder().decode(RegisterErrorResponse.self, from: responseData) {
            return .failure(errorResponse.mensaje)
        }
        
        // Si no es error, intentar decodificar como éxito
        let successResponse = try JSONDecoder().decode(RegisterSuccessResponse.self, from: responseData)
        return .success(successResponse)
    }
}

// Helper para Data
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
