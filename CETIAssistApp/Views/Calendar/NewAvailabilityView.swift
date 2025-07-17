//
//  NewAvailabilityView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct NewAvailabilityView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var availabilityViewModel = AvailabilityViewModel()

    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)

    @State private var errorMessage: String?
    @State private var isSaving = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Fecha")) {
                    DatePicker("Selecciona la fecha", selection: $selectedDate, displayedComponents: .date)
                }

                Section(header: Text("Hora de inicio")) {
                    DatePicker("Inicio", selection: $startTime, displayedComponents: .hourAndMinute)
                }

                Section(header: Text("Hora de fin")) {
                    DatePicker("Fin", selection: $endTime, displayedComponents: .hourAndMinute)
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }

                Section {
                    Button(action: saveAvailability) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Publicar disponibilidad")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle("Nueva asesoría")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveAvailability() {
        guard let professorId = authViewModel.user?.uid else {
            errorMessage = "No se encontró tu sesión."
            return
        }

        let professorName = authViewModel.user?.displayName ?? "Profesor"

        guard startTime < endTime else {
            errorMessage = "La hora de inicio debe ser anterior a la de fin."
            return
        }

        errorMessage = nil
        isSaving = true

        // Formatear fecha
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)

        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH:mm"
        let startString = hourFormatter.string(from: startTime)
        let endString = hourFormatter.string(from: endTime)

        // Publicar disponibilidad
        availabilityViewModel.publishAvailability(
            professorId: professorId,
            professorName: professorName,
            date: dateString,
            startTime: startString,
            endTime: endString
        ) { success, error in
            DispatchQueue.main.async {
                isSaving = false
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    dismiss()
                }
            }
        }
    }
}
