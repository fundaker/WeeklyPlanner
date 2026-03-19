//
//  ConfettiView.swift
//  WeeklyPlanner
//
//  Created by Funda Aker on 10.03.2026.
//

import SwiftUI

struct ConfettiView: View {

    @State private var animate = false

    var body: some View {

        ZStack {

            ForEach(0..<25) { _ in

                Circle()
                    .fill(Color.random)
                    .frame(width: 10, height: 10)
                    .position(
                        x: CGFloat.random(in: 0...400),
                        y: animate ? 900 : -20
                    )
                    .animation(
                        .easeIn(duration: Double.random(in: 1...2)),
                        value: animate
                    )

            }

        }
        .ignoresSafeArea()
        .onAppear {
            animate = true
        }

    }
}

extension Color {

    static var random: Color {
        [ .red, .blue, .green, .yellow, .purple, .orange ].randomElement()!
    }

}
