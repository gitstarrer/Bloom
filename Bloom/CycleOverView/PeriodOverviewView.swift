//
//  PeriodOverviewView.swift
//  Bloom
//
//  Created by Himanshu on 22/08/25.
//


import SwiftUI
import BloomCore
import BloomApplication

struct CycleOverviewView: View {
    @StateObject var vm: CycleOverviewViewModel
    @State private var ringRotation: Angle = .degrees(0)
    @State private var scrubAmount: Double = 0
    @State private var isScrubbing = false
    
    var body: some View {
        ZStack {
            NebulaBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header + planets
                    UniverseHeader(lastText: vm.lastPeriodText)
                        .padding(.horizontal, 22)
                        .padding(.top, 12)

                    // Circular predictor
                    PeriodRing(
                        title: vm.cycleDayText,
                        subtitle: vm.nextPeriodText,
                        ringRotation: $ringRotation
                    )
                    .padding(.horizontal, 22)
                    .onAppear {
                        withAnimation(.linear(duration: 36).repeatForever(autoreverses: false)) {
                            if !isScrubbing { ringRotation = .degrees(360) }
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isScrubbing = true
                                scrubAmount = min(max(0, scrubAmount + value.translation.width/4), 360)
                                ringRotation = .degrees(scrubAmount)
                            }
                            .onEnded { _ in
                                isScrubbing = false
                                // Restart auto rotation
                                withAnimation(.linear(duration: 36).repeatForever(autoreverses: false)) {
                                    ringRotation = .degrees(360)
                                }
                            }
                    )
                    
                    PhaseStrip(
                        fertile: vm.fertileWindowText,
                        ovulation: vm.ovulationDateText,
                        currentDay: 7
                    )
                    .padding(.horizontal, 22)

                    // Metrics cards
                    HStack(spacing: 16) {
                        MetricCard(
                            icon: "moonphase.waxing.gibbous.inverse",
                            value: "23",//"Cycle Avg",
                            context: "average cycle", //vm.averageCycleLengthText,
                            gradient: [.purple, .blue]
                        )
                        MetricCard(
                            icon: "drop.fill",
                            value: "5",//Period Avg",
                            context: "average period", //vm.averagePeriodLengthText,
                            gradient: [.pink, .orange]
                        )
                    }
                    .padding(.horizontal, 22)

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 36).repeatForever(autoreverses: false)) {
                ringRotation = .degrees(360)
            }
        }
    }
}

private struct UniverseHeader: View {
    let lastText: String

    var body: some View {
        ZStack {
            OrbitingPlanet(size: 120, xOffset: 0, yOffset: -70, period: 21, colors: [.yellow.opacity(0.3), .yellow, .orange, .red])
            OrbitingPlanet(size: 70, xOffset: 10, yOffset: 360, period: 45, colors: [.blue, .indigo, .indigo])
            OrbitingPlanet(size: 46, xOffset: 40, yOffset: -20, period: 13, colors: [.green, .cyan, .yellow])
            OrbitingPlanet(size: 30, xOffset: 20, yOffset: 160, period: 7, colors: [.purple, .blue, .indigo])


            VStack(alignment: .leading, spacing: 6) {
                Text("Your Cycle\nUniverse")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                    .shadow(radius: 6)
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text(lastText.isEmpty ? "Add your last period to begin" : lastText)
                }
                .font(.callout.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
    }
}

// MARK: - Ring

private struct PeriodRing: View {
    let title: String
    let subtitle: String
    @Binding var ringRotation: Angle
    
    var body: some View {
        ZStack {
            // Animated gradient ring
            Circle()
//                .trim(from: 0, to: 0.9999)
                .stroke(AngularGradient(
                    gradient: Gradient(colors: [
                        .pink, .orange, .yellow, .green, .mint, .teal, .blue, .purple, .pink,
//                        .white, .purple, .indigo, .gray, .black, .white
                    ]),
                    center: .center
                ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(ringRotation)
                .shadow(color: .white.opacity(0.25), radius: 8, x: 0, y: 0)
                .padding(16)
                

            VStack(spacing: 6) {
                Text(title)
                    .font(.headline.smallCaps())
                    .foregroundStyle(.white.opacity(0.9))
                Text(subtitle.replacingOccurrences(of: "Next period: ", with: ""))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("until next period")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(height: 280)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
    }
}

// MARK: - Phase strip

private struct PhaseStrip: View {
    let fertile: String
    let ovulation: String
    let currentDay: Int
        private let phases = [
            "moonphase.new.moon",
            "moonphase.waxing.crescent",
            "moonphase.first.quarter",
            "moonphase.waxing.gibbous",
            "moonphase.full.moon",
            "moonphase.waning.gibbous",
            "moonphase.last.quarter",
            "moonphase.waning.crescent"
            
        ]
    
    private func phaseSymbol(for index: Int) -> String {
            let adjusted = min(index / 2, phases.count - 1)
            return phases[adjusted]
        }
    
    var body: some View {
            VStack(spacing: 14) {
                HStack(spacing: 8) {
                    ForEach(0..<14, id: \.self) { i in
                        let isToday = i == currentDay
                        Image(systemName: phaseSymbol(for: i))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(
                                isToday ? .yellow : .white.opacity(0.85),
                                .white.opacity(0.25)
                            )
                            .font(.system(size: 14, weight: .semibold))
                    }

                    Spacer(minLength: 0)
                }
                .padding(.top, 6)

                GlassCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Label(fertile, systemImage: "sparkles")
                            .font(.callout.weight(.medium))
                        Label(ovulation, systemImage: "circle.dotted.and.circle")
                            .font(.callout.weight(.medium))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
}

// MARK: - Metric card

private struct MetricCard: View {
    let icon: String
    let value: String   // "23 Days"
    let context: String // "Average cycle length"
    let gradient: [Color]

    var body: some View {
        GlassCard {
            VStack(spacing: 8) {
                // Data point with leading icon
                HStack(alignment: .center, spacing: 6) {
                    Image(systemName: icon)
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .font(.system(size: 28, weight: .semibold))
                    
                    Text(value)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Text(context.uppercased())
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Reusable glass card

struct GlassCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.08))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
    }
}


private struct OrbitingPlanet: View {
    let size: CGFloat
    let xOffset: CGFloat
    let yOffset: CGFloat
    let period: Double
    let colors: [Color]

    @State private var rotate = false

    var body: some View {
        Circle()
            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: size, height: size)
            .blur(radius: 0.5)
            .opacity(Double.random(in: 0...1))
            .clipShape(.circle)
            .shadow( 
                color: colors.last!.opacity(0.3),
                radius: 10, x: 7, y: 7)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(rotate ? .degrees(360) : .degrees(0), anchor: .center)
            .animation(
                .linear(duration: period)
                .repeatForever(autoreverses: false),
                value: rotate
            )
            .onAppear { rotate = true }
    }
}

//#Preview {
//    CycleOverviewView(
//        vm: CycleOverviewViewModel(
//            periodService: PeriodOverviewService(
//                tracker: CycleTracker(),
//                repository: PrimaryPeriodRepository(
//                    store: UserDefaultsPeriodStore(userDefaults: .standard)
//                )
//            )
//        )
//    )
//
//}


// MARK: - Preview

#if DEBUG
import BloomCore
final class PreviewPeriodService: PeriodOverviewProtocol {
    private let baseDate = ISO8601DateFormatter().date(from: "2025-08-21T00:00:00Z")!

    func getAllPeriods() -> [Period] {
        [
            Period(startDate: baseDate),
            Period(startDate: Calendar.current.date(byAdding: .day, value: -30, to: baseDate)!),
            Period(startDate: Calendar.current.date(byAdding: .day, value: -60, to: baseDate)!)
        ]
    }
    func predictNextPeriod(fromDate date: Date) throws -> Date {
        Calendar.current.date(byAdding: .day, value: 29, to: date)!
    }
    func getFertileWindow(forDate currentDate: Date) throws -> (start: Date, end: Date) {
        let start = Calendar.current.date(byAdding: .day, value: -4, to: currentDate)!
        let end   = Calendar.current.date(byAdding: .day, value: 4, to: currentDate)!
        return (start, end)
    }
    func getAverageCycleLength(maxRecentCycles: Int?) -> Int { 23 }
    func getAveragePeriodLength() throws -> Int { 8 }
    func getOvulationDate(forDate currentDate: Date) throws -> Date {
        Calendar.current.date(byAdding: .day, value: 3, to: currentDate)!
    }
}

struct CycleOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CycleOverviewView(vm: CycleOverviewViewModel(periodService: PreviewPeriodService()))
                .preferredColorScheme(.light)
                .previewDisplayName("Celestial")
            CycleOverviewView(vm: CycleOverviewViewModel(periodService: PreviewPeriodService()))
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 15 Pro")
        }
    }
}
#endif
