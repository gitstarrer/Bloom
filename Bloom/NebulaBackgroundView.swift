//
//  NebulaBackgroundView.swift
//  Bloom
//
//  Created by Himanshu on 27/08/25.
//

import SwiftUI

struct NebulaBackgroundView: View {
    var body: some View {
        Group {
            NebulaGradient()
            StarfieldLayer(starCount: 300, speedRange: 0.5...1.0)
            StarfieldLayer(starCount: 200, speedRange: 1.0...2.0)
            StarfieldLayer(starCount: 100, speedRange: 2.0...3.0)
        }
        .ignoresSafeArea()
    }
}

private struct NebulaGradient: View {
    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: [ .indigo, .black]),
            center: .topTrailing,
            startRadius: 20,
            endRadius: 350
        )
        .overlay(
            AngularGradient(
                gradient: Gradient(colors: [.clear, .pink.opacity(0.3), .red.opacity(0.12), .clear]),
                center: .center
            )
            .blendMode(.screen)
            .opacity(0.8)
        )
        .overlay(
            LinearGradient(colors: [.clear, .blue.opacity(0.212)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
}

private struct StarfieldLayer: View {
    private let stars: [Star]
    
    init(starCount: Int = 600, speedRange: ClosedRange<Double> = 0.8...1.6) {
        self.stars = (0..<starCount).map { _ in
            Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                r: CGFloat.random(in: 0.5...2.5),
                speed: Double.random(in: speedRange),
                phase: Double.random(in: 0...(.pi * 2))
            )
        }
    }

    @State private var time: Double = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                for star in stars {
                    var path = Path()
                    path.addEllipse(in: CGRect(
                        x: star.x * size.width,
                        y: star.y * size.height,
                        width: star.r,
                        height: star.r
                    ))

                    // opacity oscillates smoothly using sine
                    let twinkle = 0.5 + 0.5 * sin(now * star.speed + star.phase)
                    let opacity = 0.2 + twinkle * 0.8

                    ctx.fill(path, with: .color(.white.opacity(opacity)))
                }
            }
        }
    }
    
    private struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let r: CGFloat
        let speed: Double
        let phase: Double
    }
}
