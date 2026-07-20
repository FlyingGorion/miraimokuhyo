//
//  DesiredSelfCard.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI

struct DesiredSelfCard: View {
    let desiredSelf: String
    
    var body: some View {
        ZStack {
            // 背景画像
            GeometryReader { geometry in
                Image("MyIdealSelf_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            
            // コンテンツ
            VStack(alignment: .leading, spacing: 12) {
                Text("なりたい自分")
                    .font(.headline)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                
                Text(desiredSelf)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                
                Text("今日の行動は、理想の自分につながっている")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.95))
                    .italic()
                    .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .cornerRadius(16)
        .clipped()
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    DesiredSelfCard(desiredSelf: "常に自由であり続け、誠実さと好奇心のある人間になる")
        .padding()
}
