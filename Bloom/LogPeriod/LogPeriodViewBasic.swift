//
//  LogPeriodViewBasic.swift
//  Bloom
//
//  Created by Himanshu on 27/08/25.
//


import SwiftUI

struct LogPeriodViewBasic: View {
    @State private var selectedDate = Date()
    @State private var flowIntensity = 2
    @State private var notes = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    DateSection(selectedDate: $selectedDate)
                    FlowIntensitySection(flowIntensity: $flowIntensity)
                    NotesSection(notes: $notes)

                    SaveButton {
                        print("Saved period log: \(selectedDate), intensity: \(flowIntensity), notes: \(notes)")
                    }
                }
                .padding()
            }
            .navigationTitle("Log Period")
        }
    }
}

// MARK: - Subviews

private struct DateSection: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Date")
                .font(.headline)
            DatePicker("",
                       selection: $selectedDate,
                       displayedComponents: [.date])
                .datePickerStyle(.graphical)
        }
    }
}

private struct FlowIntensitySection: View {
    @Binding var flowIntensity: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Flow Intensity")
                .font(.headline)
            
            HStack {
                ForEach(1...5, id: \.self) { level in
                    Circle()
                        .fill(flowIntensity == level ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 36, height: 36)
                        .overlay(Text("\(level)").foregroundColor(.white))
                        .onTapGesture {
                            flowIntensity = level
                        }
                }
            }
        }
    }
}

private struct NotesSection: View {
    @Binding var notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            TextEditor(text: $notes)
                .frame(height: 120)
                .padding(8)
//                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

private struct SaveButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Save Entry")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.pink)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}


#Preview {
    LogPeriodViewBasic()
}
