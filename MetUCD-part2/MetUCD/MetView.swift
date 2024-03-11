//
//  MetView.swift
//  MetUCD
//
//  Created by Judith Smolenski on 17/11/2023.
//

import SwiftUI

struct MetView: View {
    @EnvironmentObject private var model: MetModel
    
    @State private var locationInput: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("search").foregroundStyle(Color.blue)) {
                    TextField("Enter location e.g. Dublin, IE", text: $locationInput)
                        .keyboardType(.default)
                }
            }
        }
    }
}

#Preview {
    MetView()
}
