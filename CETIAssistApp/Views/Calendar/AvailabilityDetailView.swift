//
//  AvailabilityDetailView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI
import FirebaseAuth

struct AvailabilityDetailView: View {
    let availability: Availability
    @ObservedObject var availabilityVM: AvailabilityViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var isBooking: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
        Form {
            Section("Materia") {
                Text(availability.subject).font(.headline)
            }
            Section("Horario") {
                Text("\(availability.date)")
                Text("\(availability.startTime) – \(availability.endTime)")
            }
            Section("Modalidad") {
                HStack {
                    Text("Tipo")
                    Spacer()
                    Text(availability.modality.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(Capsule())
                }
                if availability.modality == .presencial, let aula = availability.aula, !aula.isEmpty {
                    HStack {
                        Text("Aula")
                        Spacer()
                        Text(aula)
                    }
                }
            }

            Section {
                Button {
                    book()
                } label: {
                    if isBooking { ProgressView() }
                    else { Text("Agendar asesoría") }
                }
                .disabled(isBooking || !availability.isAvailable) // por seguridad
            }
        }
        .navigationTitle("Detalle de asesoría")
        .navigationBarTitleDisplayMode(.inline)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {
                if alertTitle == "Éxito" { dismiss() }
            }
        } message: {
            Text(alertMessage)
        }
    }

    private func book() {
        guard let user = Auth.auth().currentUser else {
            show("Error", "Debes iniciar sesión para agendar.")
            return
        }
        isBooking = true
        availabilityVM.markAsBooked(id: availability.id, studentId: user.uid) { ok, error in
            isBooking = false
            if let e = error {
                show("Error", e.localizedDescription)
            } else if ok {
                show("Éxito", "La asesoría fue agendada.")
            } else {
                show("Error", "No se pudo agendar la asesoría.")
            }
        }
    }

    private func show(_ title: String, _ message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    let sample = Availability(
        id: "demo",
        professorId: "p1",
        professorName: "Profa. Demo",
        date: "2025-10-10",
        startTime: "10:00",
        endTime: "11:00",
        isAvailable: true,
        subject: "Cálculo I",
        modality: .presencial,
        aula: "Aula 205"
    )
    return NavigationView {
        AvailabilityDetailView(availability: sample, availabilityVM: AvailabilityViewModel())
    }
}
