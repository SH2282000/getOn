//
//  SearchField.swift
//  getOn
//
//  Created by Shannah on 30/11/2025.
//

import SwiftUI

struct SearchField: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .submitLabel(.search)
                .onSubmit {
                    action?()
                }

            Button(action: {
                action?()
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
            }
        }
        
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.clear)

    }
}


#Preview {
    @Previewable @State var searchText = ""
    SearchField(text: $searchText, placeholder: "Find places...") {
        print("Search triggered for: \(searchText)")
    }
}
