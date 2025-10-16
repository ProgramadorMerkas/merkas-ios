//
//  InputCalendar.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI

struct InputCalendar: View {
    var label: LocalizedStringKey
    var required: Bool = false
    var msmError: LocalizedStringKey = ""
    var msmWarning: LocalizedStringKey = ""
    @Binding var selectedDate: Date
    @Binding var inputStatus: InputStatusType
    var onEditing: (()-> Void?)? = nil
    
    var body: some View {
        VStack {
            HStack {
                Text(label)
                    .foregroundStyle(.gray)
                    .font(.callout)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 10)
                
                if required {
                    Text("*")
                        .foregroundStyle(.red)
                        .font(.callout)
                        .offset(x: -4)
                }
                
                Spacer()
            }
            
            DatePicker(
                selectedDate.formatted(date: .abbreviated, time: .shortened),
                selection: $selectedDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            
            HStack {
                if inputStatus == .error {
                    Image(systemName: "exclamationmark.circle")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.leading)
                        .offset(x: 4)
                    
                    Text(msmError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.leading)
                } else if inputStatus == .warning {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.footnote)
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.leading)
                        .offset(x: 4)
                    
                    Text(msmWarning)
                        .font(.footnote)
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(.leading, 5)
            .padding(.bottom, inputStatus == .error ? 5 : 15)
            .animation(.easeInOut(duration: 0.3), value: inputStatus)
        }
        .onChange(of: selectedDate) {
            onEditing?()
        }
    }
}
