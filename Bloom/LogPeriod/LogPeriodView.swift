//
//  LogPeriodView.swift
//  Bloom
//
//  Created by Himanshu on 27/08/25.
//


import SwiftUI

struct LogPeriodView: View {
    @StateObject var viewModel: LogPeriodViewModel

    init(viewModel: LogPeriodViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            NebulaBackgroundView()

            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        PlanetHeader()
                        DateSection(selectedDate: $viewModel.selectedDate)
                        FlowLevelSection(flowLevel: $viewModel.flowLevel)
                        SymptomsSection(allSymptoms: viewModel.allSymptoms,
                                        symptoms: $viewModel.symptoms,
                                        toggle: viewModel.toggleSymptom)
                        MoodSection(allMoods: viewModel.allMoods,
                                    moods: $viewModel.moods,
                                    toggle: viewModel.toggleMood)
                        ActivitiesSection(allActivities: viewModel.allActivities,
                                          activities: $viewModel.activities,
                                          toggle: viewModel.toggleActivity)
                        JournalSection(journal: $viewModel.journal)
                    }
                }
                .padding(.horizontal)

                SaveButtonSection(
                    saveAction: viewModel.save
                )
                    .padding()
            }
        }
    }
}

private struct PlanetHeader: View {
    var body: some View {
        VStack {
            Text("Log Period")
                .font(.title.bold())
                .foregroundStyle(.white)
        }
    }
}

private struct DateSection: View {
    @Binding var selectedDate: Date

    var body: some View {
        DatePicker("", selection: $selectedDate, displayedComponents: .date)
            .datePickerStyle(.graphical)
            .colorScheme(.dark)
            .tint(.white)
    }
}

private struct FlowLevelSection: View {
    @Binding var flowLevel: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Flow Level")
                .font(.headline)
                .foregroundStyle(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(1..<5) { level in
                        Circle()
                            .fill(
                                flowLevel == level ?
                                LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors:[Color.white.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 40, height: 40)
                            .overlay(Text("\(level)")
                                .foregroundColor(.white))
                            .shadow(color: flowLevel == level ? .pink.opacity(0.6) : .clear, radius: 8)
                            .onTapGesture { flowLevel = level }
                    }
                }
            }
        }
    }
}

private struct SymptomsSection: View {
    let allSymptoms: [String]
    @Binding var symptoms: Set<String>
    let toggle: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Symptoms")
                .font(.headline)
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(allSymptoms, id: \.self) { symptom in
                        CapsuleButton(
                            label: symptom,
                            isSelected: symptoms.contains(symptom),
                            action: {
                                toggle(symptom)
                            }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}


private struct MoodSection: View {
    let allMoods: [String]
    @Binding var moods: Set<String>
    let toggle: (String) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood")
                .font(.headline)
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(allMoods, id: \.self) { mood in
                        CapsuleButton(label: mood, isSelected: moods.contains(mood)) {
                            toggle(mood)
                        }
                    }
                }
            }
        }
    }
}

private struct ActivitiesSection: View {
    let allActivities: [String]
    @Binding var activities: Set<String>
    let toggle: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activities")
                .font(.headline)
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(allActivities, id: \.self) { activity in
                        CapsuleButton(label: activity, isSelected: activities.contains(activity)) {
                            toggle(activity)
                        }
                    }
                }
            }
        }
    }
}

private struct JournalSection: View {
    @Binding var journal: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Journal")
                .font(.headline)
                .foregroundStyle(.white)

            TextEditor(text: $journal)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 320)
                .padding(12)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )

        }
    }
}


struct CapsuleButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(label)
            .font(.callout.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected
                ? LinearGradient(colors: [.pink.opacity(0.7), .purple.opacity(0.7)],
                                 startPoint: .topLeading,
                                 endPoint: .bottomTrailing)
                : LinearGradient(colors: [Color.white.opacity(0.12)],
                                 startPoint: .topLeading,
                                 endPoint: .bottomTrailing)
            )
            .foregroundColor(.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
            .shadow(color: isSelected ? .pink.opacity(0.5) : .clear, radius: 8)
            .onTapGesture { action() }
    }
}

private struct SaveButtonSection: View {
    let saveAction: () -> Void

    var body: some View {
        Button(action: saveAction) {
            Text("Save Entry")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(colors: [.pink, .purple],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .cornerRadius(14)
                .shadow(color: .pink.opacity(0.6), radius: 12, x: 0, y: 4)
        }
    }
}

//#Preview {
//    NavigationView {
//        LogPeriodView()
//    }
//}
