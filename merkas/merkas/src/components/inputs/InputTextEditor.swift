//
//  InputTextEditor.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI

struct InputTextEditor: View {
    var label: LocalizedStringKey
    var required: Bool = false
    @Binding var text: String
    @Binding var inputStatus: InputStatusType
    var msmError: LocalizedStringKey = ""
    var msmWarning: LocalizedStringKey = ""
    var onEditing: (()-> Void?)? = nil
    
    @FocusState var focused: Bool
    
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
            
            TextEditor(text: $text)
                .frame(minHeight: 25)
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focused ? .merkas : .gray, lineWidth: focused ? 2 : 1)
                        .animation(.easeInOut(duration: 0.3), value: focused)
                }
                .focused($focused)
            
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
        .onChange(of: text) {
            onEditing?()
        }
        .onChange(of: focused) { oldValue, newValue in
            if oldValue && !newValue {
                if !text.isEmpty {
                    if required {
                        inputStatus = .warning
                    } else {
                        inputStatus = .initial
                    }
                } else {
                    inputStatus = .good
                }
            }
        }
    }
}
