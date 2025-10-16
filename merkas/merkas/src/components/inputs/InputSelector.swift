//
//  InputSelector.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI

struct InputSelector: View {
    var label: LocalizedStringKey
    var required: Bool = false
    var msmError: LocalizedStringKey = ""
    var msmWarning: LocalizedStringKey = ""
    let items: [InputSelectorItemsProps]
    @Binding var selectedItemKey: String
    @Binding var inputStatus: InputStatusType
    
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
                
                Picker(selectedItemKey.isEmpty ? "select" : selectedItemKey, selection: $selectedItemKey) {
                    Text("select")
                        .foregroundColor(UITheme(colorLight: .black, colorDark: .white))
                        .frame(maxWidth: 200)
                        .tag("")
                    
                    ForEach(items, id: \.key) { item in
                        Text(item.title)
                            .foregroundColor(UITheme(colorLight: .black, colorDark: .white))
                            .frame(maxWidth: 200)
                            .tag(item.key)
                    }
                }
                .pickerStyle(.menu)
            }
            
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
        .onChange(of: selectedItemKey) {
            if selectedItemKey == "" {
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

struct InputSelectorItemsProps {
    var key: String
    var icon: String? = nil
    var title: LocalizedStringKey
}
