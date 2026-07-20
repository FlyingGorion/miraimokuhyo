//
//  ProgressBar.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(Int(progress))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * (progress / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBar(progress: 0)
        ProgressBar(progress: 25)
        ProgressBar(progress: 50)
        ProgressBar(progress: 75)
        ProgressBar(progress: 100)
    }
    .padding()
}
