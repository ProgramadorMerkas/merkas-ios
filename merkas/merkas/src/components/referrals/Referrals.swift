//
//  Referrals.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 29/9/25.
//  Modified by Edwin Egue on 12/12/2025

import SwiftUI

struct Referrals: View {
    let referrals: [ReferredUser]
    let type:String
    var body: some View {
        if referrals.isEmpty {
            //Text(.referralsEmpty)
            //Working()
             debugInfo
        } else {
            //ScrollView {
                VStack {
                    //Working()
                    debugInfo
                    ScrollView{
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .foregroundStyle(.merkas)
                                Spacer()
                                Text("\(type)").font(.headline)
                                Spacer()
                                Text("\(referrals.count)")
                                    .font(.headline)
                                    .foregroundStyle(.merkas)
                                    
                                
                                 
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            ForEach(referrals, id:\.usuario_id){referral in
                                ReferralCard(referral: referral)
                                
                            }
                            
                        }
                        .padding(.bottom, 15)
                    }
                }
                //.padding(.bottom, 15)
                //.frame(maxWidth: .infinity)
            //}
        }
    }
    
    private var debugInfo:some View {
        let _ = print("contenido" , referrals.count)
        return EmptyView()
    }
}

#Preview {
    @Previewable @State var referrals: [ReferredUser] = []
    Referrals(referrals: referrals , type: "Referrals")
}
