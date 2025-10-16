//
//  app.service.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 5/10/25.
//

import Foundation

struct AppVersionProps: Codable {
}

enum AppVersionResult {
    case success(EcommerceIdProps)
    case failure(String)
}
