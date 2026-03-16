//
//  TimeDate.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//

import SwiftUI

struct TimeDate: View {
    let date: Date
    var body: some View {
            HStack {
                Text(date, format: .dateTime.weekday(.wide).month().day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Spacer()
                Text(date, format: .dateTime.hour().minute())
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
        }
}

#Preview {
    TimeDate(
        date: Date(),
    )
    .padding()
}
