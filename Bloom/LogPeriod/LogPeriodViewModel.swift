//
//  LogPeriodViewModel.swift
//  Bloom
//
//  Created by Himanshu on 28/08/25.
//

import SwiftUI
import BloomApplication

@MainActor
final class LogPeriodViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var flowLevel: Int = 1
    @Published var symptoms: Set<String> = []
    @Published var moods: Set<String> = []
    @Published var activities: Set<String> = []
    @Published var journal: String = ""

    let allSymptoms = ["Cramps", "Headache", "Mood Swings", "Fatigue", "Bloating", "Nausea"]
    let allMoods = ["Happy", "Sad", "Anxious", "Irritable", "Calm", "Energetic"]
    let allActivities = ["Exercise", "Sex", "Travel", "Work", "Relax", "Social"]

    let logPeriodService: LogPeriodService
    
    init(logPeriodService: LogPeriodService) {
        self.logPeriodService = logPeriodService
    }
    
    func toggleSymptom(_ symptom: String) {
        if symptoms.contains(symptom) {
            symptoms.remove(symptom)
        } else {
            symptoms.insert(symptom)
        }
    }

    func toggleMood(_ mood: String) {
        if moods.contains(mood) {
            moods.remove(mood)
        } else {
            moods.insert(mood)
        }
    }

    func toggleActivity(_ activity: String) {
        if activities.contains(activity) {
            activities.remove(activity)
        } else {
            activities.insert(activity)
        }
    }

    func save() {
        // Replace with repository call later
        print("Saved entry")
        print("Date: \(selectedDate)")
        print("Flow: \(flowLevel)")
        print("Symptoms: \(symptoms)")
        print("Moods: \(moods)")
        print("Activities: \(activities)")
        print("Journal: \(journal)")
    }
}
