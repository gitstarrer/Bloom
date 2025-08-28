//
//  LogPeriodView.swift
//  Bloom
//
//  Created by Himanshu on 27/08/25.
//


import SwiftUI

struct LogPeriodView: View {
    @State private var selectedDate = Date()
    @State private var flowLevel: Int = 1
    @State private var symptoms: Set<String> = []
    @State private var moods: Set<String> = []
    @State private var activities: Set<String> = []
    @State private var journal: String = ""

    let allSymptoms = ["Cramps", "Headache", "Mood Swings", "Fatigue", "Bloating", "Nausea"]
    let allMoods = ["Happy", "Sad", "Anxious", "Irritable", "Calm", "Energetic"]
    let allActivities = ["Exercise", "Sex", "Travel", "Work", "Relax", "Social"]

    var body: some View {
        ZStack {
            NebulaBackgroundView()

            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        PlanetHeader()
                        DateSection(selectedDate: $selectedDate)
                        FlowLevelSection(flowLevel: $flowLevel)
                        SymptomsSection(allSymptoms: allSymptoms, symptoms: $symptoms)
                        MoodSection(allMoods: allMoods, moods: $moods)
                        ActivitiesSection(allActivities: allActivities, activities: $activities)
                        JournalSection(journal: $journal)
                    }
                }
                .padding(.horizontal)

                SaveButtonSection(
                    date: selectedDate,
                    flow: flowLevel,
                    symptoms: symptoms,
                    moods: moods,
                    activities: activities,
                    journal: journal
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
                                toggleSymptom(symptom)
                            }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func toggleSymptom(_ symptom: String) {
        if symptoms.contains(symptom) {
            symptoms.remove(symptom)
        } else {
            symptoms.insert(symptom)
        }
    }
}


private struct MoodSection: View {
    let allMoods: [String]
    @Binding var moods: Set<String>

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

    private func toggle(_ mood: String) {
        if moods.contains(mood) {
            moods.remove(mood)
        } else {
            moods.insert(mood)
        }
    }
}

private struct ActivitiesSection: View {
    let allActivities: [String]
    @Binding var activities: Set<String>

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

    private func toggle(_ activity: String) {
        if activities.contains(activity) {
            activities.remove(activity)
        } else {
            activities.insert(activity)
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
    let date: Date
    let flow: Int
    let symptoms: Set<String>
    let moods: Set<String>
    let activities: Set<String>
    let journal: String

    var body: some View {
        Button(action: {
            print("Saved: \(date)")
            print("Flow: \(flow)")
            print("Symptoms: \(symptoms)")
            print("Moods: \(moods)")
            print("Activities: \(activities)")
            print("Journal: \(journal)")
        }) {
            Text("Save Entry")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(14)
                .shadow(color: .pink.opacity(0.6), radius: 12, x: 0, y: 4)
        }
    }
}

#Preview {
    NavigationView {
        LogPeriodView()
    }
}
