//
//  InputColor.swift
//  merkas
//
//  Created by Andrés Palacio Molina on 28/9/25.
//

import SwiftUI


struct InputColor: View {
    @Binding var selectedColor: Color
    
    var body: some View {
        ColorPicker(.selectColor, selection: $selectedColor)
    }
}
