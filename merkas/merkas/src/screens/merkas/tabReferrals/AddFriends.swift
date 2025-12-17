//
//  AddFriends.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 5/10/25.
//

import SwiftUI

struct AddFriends: View {
    @EnvironmentObject var appState: AppState
    @State private var alertMessasge = ""
    @State private var showAlert = false
    var body: some View {
        //let hello: String = "\(NSLocalizedString("homeHello", comment: ""))\(appState.user != nil ? ", \(appState.user!.usuarioNombre.capitalized)" : "")"
        let codigo :String = "\(appState.user != nil ? "\(appState.user!.usuarioCodigo)" : "")"
        VStack{
            HStack(spacing: 12){
                Image(systemName:  "link.circle.fill").foregroundStyle(.merkas).font(.title)
                Text("Comparte tu código de referido").font(.title).foregroundStyle(.merkas).bold(true).padding(10)
                
            }
            HStack{
                Spacer()
                Text("Invita a tus amigos a unirse a Merkas y gana beneficios por cada referido.").font(.caption).foregroundStyle(.secondary)
                Spacer()
            }
            
            Button(action: {
                sentToWhatsapp(codigo: codigo)
            }){
                HStack{
                    Image(systemName: "message.fill")
                    Text("Compartir por WhatsApp")
                }.font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .opacity(1)
            
        }
        .padding(.top, 40)
        .alert("Atenciòn", isPresented: $showAlert){
            Button("OK", role: .cancel){}
        }message: {
            Text(alertMessasge)
        }
    }
    
    
    func sentToWhatsapp(codigo:String){
         
        
        let encodedMessage = "¡Hola!, te comparto mi código de referido: \(urlRegister)\(codigo)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let whatsappUrl = "Whapsapp://send?text=\(encodedMessage)"
        print(whatsappUrl)
        guard let url = URL(string: whatsappUrl) else {
            alertMessasge = "Error al crear el enlace de WhatsApp"
            showAlert = true
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]){succes in
                if !succes {
                    
                    alertMessasge = "No se pudo abrir WhatsApp"
                    showAlert = true
                }
                
            }
        }else{
            alertMessasge = "WhatsApp no está instalado en este dispositivo"
            showAlert = true
        }
    }
         
}



#Preview {
    AddFriends()
}
