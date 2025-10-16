//
//  Referrals.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 29/9/25.
//

import SwiftUI

struct Referrals: View {
    @State var referrals: [ReferredUser]
    
    var body: some View {
        if referrals.isEmpty {
            //Text(.referralsEmpty)
            Working()
        } else {
            //ScrollView {
                VStack {
                    Working()
                }
                //.padding(.bottom, 15)
                //.frame(maxWidth: .infinity)
            //}
        }
    }
}

#Preview {
    @Previewable @State var referrals: [ReferredUser] = []
    Referrals(referrals: referrals)
}
