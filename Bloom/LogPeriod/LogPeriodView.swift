import SwiftUI

struct LogPeriodView: View {
    @State private var selectedDate = Date()
    @State private var flowIntensity = 2
    @State private var notes = ""

    var body: some View {
        ZStack {
            // Background (same nebula + stars as overview)
            NebulaGradient()
                .ignoresSafeArea()
            StarfieldLayer(starCount: 300, speedRange: 0.5...1.5)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Cosmic header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Log Your Cycle")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Record today’s details in your universe")
                                .font(.callout.weight(.medium))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        Spacer()
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(radius: 6)
                    }
                    .padding(.horizontal, 22)

                    // Date Picker inside glass card
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Select Date", systemImage: "calendar")
                                .font(.headline)
                                .foregroundStyle(.white)

                            DatePicker(
                                "",
                                selection: $selectedDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .accentColor(.pink)
                        }
                    }

                    // Flow intensity (cosmic orbs)
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Flow Intensity", systemImage: "drop.fill")
                                .font(.headline)
                                .foregroundStyle(.white)

                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { level in
                                    Circle()
                                        .fill(flowIntensity == level ?
                                              AngularGradient(colors: [.pink, .orange], center: .center)
                                              : Color.white.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Text("\(level)")
                                                .font(.subheadline.weight(.bold))
                                                .foregroundColor(.white)
                                        )
                                        .shadow(color: flowIntensity == level ? .pink.opacity(0.6) : .clear,
                                                radius: 8, x: 0, y: 0)
                                        .onTapGesture { flowIntensity = level }
                                }
                            }
                        }
                    }

                    // Notes
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Notes", systemImage: "square.and.pencil")
                                .font(.headline)
                                .foregroundStyle(.white)

                            TextEditor(text: $notes)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                    }

                    // Save button — glowing planet style
                    Button {
                        print("Saved: \(selectedDate), intensity \(flowIntensity), notes: \(notes)")
                    } label: {
                        Text("Save Entry")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.pink, .purple, .indigo],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(16)
                            .foregroundStyle(.white)
                            .shadow(color: .pink.opacity(0.5), radius: 12, x: 0, y: 0)
                    }
                    .padding(.top, 12)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
    }
}
