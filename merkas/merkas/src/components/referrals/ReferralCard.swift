//
//  ReferralCard.swift
//  merkas
//
//  Created by Edwin Egue on 13/12/25.
//
import SwiftUI

struct ReferralCard: View {
    let referral: ReferredUser
    var body: some View {
        
        HStack(spacing : 12){
            ZStack {
                        Circle()
                            .fill(Color.merkas.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                if !referral.usuario_ruta_img.isEmpty {
                            // Imagen del usuario
                    AsyncImage(url: URL(string: referral.usuario_ruta_img)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                case .failure:
                                    // Si falla, mostrar ícono
                                    Image(systemName: "person.fill")
                                        .font(.title2)
                                        .foregroundStyle(.merkas)
                                @unknown default:
                                    Image(systemName: "person.fill")
                                        .font(.title2)
                                        .foregroundStyle(.merkas)
                                }
                            }
                        } else {
                            // No tiene foto, mostrar ícono
                            Image(systemName: "person.fill")
                                .font(.title2)
                                .foregroundStyle(.merkas)
                        }
                    }
            VStack(alignment: .leading, spacing: 4){
                Text(referral.usuario_nombre_completo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 12,){
                    Image(systemName: "mail").foregroundStyle(.merkas)
                    Text(referral.usuario_correo)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 12){
                    Image(systemName: "phone").foregroundStyle(.merkas)
                    Text(referral.usuario_telefono)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 12){
                    Image(systemName: "mappin.and.ellipse").foregroundStyle(.merkas)
                    Text("\(referral.municipio_nombre) , \(referral.departamento_nombre)").font(.caption2).foregroundStyle(.secondary)
                }
                HStack(spacing:12){
                    Image(systemName: "calendar").foregroundStyle(.merkas)
                    Text(referral.usuario_fecha_registro).font(.caption2).foregroundStyle(.secondary)
                }
                
                 
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        
    }
}
