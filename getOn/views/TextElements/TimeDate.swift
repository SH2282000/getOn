//
//  TimeDate.swift
//  getOn
//
//  Created by Shannah on 29/11/2025.
//

import SwiftUI

struct TimeDate: View {
    @Binding var date: Date
    var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(date, format: .dateTime.hour().minute())
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(date, format: .dateTime.weekday(.wide).month().day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
        }
}

#Preview {
    TimeDate(
        date: .constant(Date()),
    )
    .padding()
}
