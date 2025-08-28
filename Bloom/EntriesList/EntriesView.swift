//
//  EntriesView.swift
//  Bloom
//
//  Created by Himanshu on 27/08/25.
//

import SwiftUI

struct EntriesView: View {
    @State private var isListView = false
    
    @State private var selectedEntry: Entry? = nil
    @State private var showDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            viewToggle
            
            Divider().background(Color.white.opacity(0.2))
            
            if isListView {
                entriesList
            } else {
                OrbitCalendarView()
            }
        }
        .background(
            NebulaBackgroundView()
        )
        .sheet(isPresented: $showDetail) {
            if let entry = selectedEntry {
                EntryDetailView(entry: entry)
            }
        }
    }
    
    // MARK: - Toggle
    private var viewToggle: some View {
        HStack {
            CapsuleButton(
                label: "Orbit View",
                isSelected: !isListView
            ) { isListView = false }
            
            CapsuleButton(
                label: "List View",
                isSelected: isListView
            ) { isListView = true }
        }
        .padding()
    }
    
    // MARK: - Orbit Calendar (placeholder for now)
    private var orbitMonthView: some View {
        VStack(spacing: 20) {
            Text("🌌 Orbit Calendar")
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
                .padding()
            
            Spacer()
            Text("Planetary orbit for the month goes here ✨")
                .foregroundColor(.white.opacity(0.7))
            Spacer()
        }
    }
    
    private var entriesList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(sampleEntries) { entry in
                    entryCard(entry)
                        .onTapGesture {
                            selectedEntry = entry
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showDetail = true
                            }
                        }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Entry Card
    private func entryCard(_ entry: Entry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.date, style: .date)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text(entry.flow)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(
                        LinearGradient(colors: [.pink.opacity(0.7)],
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
            }

            if !entry.symptoms.isEmpty {
                Text("\(entry.symptoms.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }

            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.75))
            }
        }
        .padding(16)
        .background(
            LinearGradient(colors: [
                Color.white.opacity(0.012),
                Color.white.opacity(0.05)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(colors: [.white.opacity(0.3), .clear],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
        .shadow(color: .purple.opacity(0.25), radius: 10, x: 0, y: 6)
    }

}

struct OrbitCalendarView: View {
    @State private var currentMonthOffset = 0
    
    private var currentDate: Date {
        Calendar.current.date(byAdding: .month, value: currentMonthOffset, to: Date())!
    }
    
    private var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: currentDate)?.count ?? 30
    }
    
    var body: some View {
        ZStack {
            Color.clear
            
            VStack(spacing: 32) {
                
                // MARK: Header with navigation
                HStack {
                    Button(action: { currentMonthOffset -= 1 }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text(monthName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { currentMonthOffset += 1 }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                ZStack {
                    ForEach(1...daysInMonth, id: \.self) { day in
                        let angle = Angle.degrees(Double(day) / 30 * 360)
                        let radius: CGFloat = 140
                        let x = cos(angle.radians) * radius
                        let y = sin(angle.radians) * radius
                        
                        Circle()
                            .fill(colorForStage(stageForDay(day)))
                            .frame(width: 12, height: 12)
                            .offset(x: x, y: y)
                    }
                    
                    Circle()
                        .fill(.gray.opacity(0.6))
//                            LinearGradient(
//                                colors: [.blue, .purple],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
                        .frame(width: 60, height: 60)
//                        .overlay(
//                            Image(systemName: "globe.americas.fill")
//                                .foregroundColor(.white)
//                                .font(.title2)
//                        )
                }
                .frame(maxHeight: .infinity)
                
                Spacer()
                
                HStack(spacing: 12) {
                    legendRow(color: colorForStage(.period), label: "Period:", dateString: "Aug 5–9")
                    legendRow(color: colorForStage(.fertile), label: "Fertile:", dateString: "Aug 10–15")
                    legendRow(color: colorForStage(.safe), label: "Safe:", dateString: "Aug 16–31")
                }
                .padding(.bottom, 40)
            }
            .padding(.vertical)
        }
        .ignoresSafeArea()
    }
    
//    private func shiftMonth(by value: Int) {
//        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
//            currentMonth = newDate
//        }
//    }
    
    // MARK: Legend Row
    private func legendRow(color: LinearGradient, label: String, dateString: String) -> some View {
        HStack(alignment: .top) {
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .foregroundColor(.white)
                    .font(.caption)
                Text(dateString)
                    .foregroundColor(.white)
                    .font(.caption2)
            }
        }
    }
    
    // MARK: Stage mapping
    private func stageForDay(_ day: Int) -> PeriodStageColorGradient {
        switch day {
        case 4...8: return .period
        case 9...14: return .fertile
        case 12: return .ovulation
        case 15...29: return .safe
        default: return .regular
        }
    }
    
    private func colorForStage(_ periodStage: PeriodStageColorGradient) -> LinearGradient {
        switch periodStage {
        case .period:
            return LinearGradient(
                colors: [Color.pink.opacity(0.9), Color.red.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .fertile:
            return LinearGradient(
                colors: [Color.green.opacity(0.8), Color.teal.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ovulation:
            return LinearGradient(
                colors: [Color.yellow.opacity(0.9), Color.orange.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .safe:
            return LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.indigo.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .regular:
            return LinearGradient(
                colors: [Color.white.opacity(0.7), Color.gray.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    enum PeriodStageColorGradient {
        case period, fertile, ovulation, safe, regular
    }
}



//MARK: entries
struct EntryDetailView: View {
    let entry: Entry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            NebulaBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)

                Spacer()

                VStack(spacing: 16) {
                    Text(entry.date, style: .date)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)

                    Text(entry.flow)
                        .font(.headline)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    if !entry.symptoms.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Symptoms")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white.opacity(0.9))
                            Text(entry.symptoms.joined(separator: ", "))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if !entry.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Notes")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white.opacity(0.9))
                            Text(entry.notes)
                                .foregroundColor(.white.opacity(0.75))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(
                    LinearGradient(colors: [Color.white.opacity(0.15),
                                            Color.white.opacity(0.05)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                    .background(.ultraThinMaterial)
                )
                .cornerRadius(20)
                .padding(.horizontal, 24)

                Spacer()

                Button(action: { dismiss() }) {
                    Text("Close")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [.pink, .purple],
                                                     startPoint: .leading,
                                                     endPoint: .trailing))
                        )
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 40)
            }
        }
    }
}


struct Entry: Identifiable {
    let id = UUID()
    let date: Date
    let flow: String
    let symptoms: [String]
    let notes: String
}

private let sampleEntries: [Entry] = [
    Entry(date: Date(), flow: "Medium", symptoms: ["Cramps", "Headache"], notes: "Felt tired"),
    Entry(date: Date().addingTimeInterval(-86400), flow: "Light", symptoms: [], notes: "All good"),
    Entry(date: Date().addingTimeInterval(-172800), flow: "Heavy", symptoms: ["Back Pain"], notes: "")
]

#Preview{
    EntriesView()
}
