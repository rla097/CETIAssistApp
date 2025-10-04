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

    // Fecha y horas
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)

    // Materia (obligatoria)
    @State private var selectedSubject: String? = nil

    // Estado UI
    @State private var isSaving = false
    @State private var errorMessage: String?

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Fecha
                Section("Fecha") {
                    DatePicker("Día", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                // MARK: - Horario
                Section("Horario") {
                    DatePicker("Inicio", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("Fin", selection: $endTime, displayedComponents: .hourAndMinute)
                }

                // MARK: - Materia
                Section("Materia") {
                    let subjects = authViewModel.professorSubjects

                    if subjects.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Aún no tienes materias registradas.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Ve a tu registro o perfil para agregarlas.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Picker("Selecciona una", selection: Binding(
                            get: { selectedSubject ?? subjects.first },
                            set: { selectedSubject = $0 }
                        )) {
                            ForEach(subjects, id: \.self) { s in
                                Text(s).tag(Optional(s))
                            }
                        }
                        .pickerStyle(.menu)
                        .onAppear {
                            // Preselecciona la primera si no hay selección previa
                            if selectedSubject == nil { selectedSubject = subjects.first }
                        }
                    }
                }

                if let error = errorMessage, !error.isEmpty {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .navigationTitle("Nueva disponibilidad")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveAvailability()
                    } label: {
                        if isSaving { ProgressView() } else { Text("Guardar") }
                    }
                    .disabled(isSaving || !canSave)
                }
            }
        }
    }

    // MARK: - Validaciones
    private var canSave: Bool {
        guard authViewModel.user != nil else { return false }
        guard let subject = selectedSubject, !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        // Horas coherentes
        return endTime > startTime
    }

    // MARK: - Guardar
    private func saveAvailability() {
        guard let professorId = authViewModel.user?.uid else {
            errorMessage = "No se encontró tu sesión."
            return
        }

        let professorName = authViewModel.user?.displayName ?? "Profesor"

        // Formatos requeridos por el backend actual
        let dfDate = DateFormatter()
        dfDate.locale = .current
        dfDate.timeZone = .current
        dfDate.dateFormat = "yyyy-MM-dd"

        let dfTime = DateFormatter()
        dfTime.locale = .current
        dfTime.timeZone = .current
        dfTime.dateFormat = "HH:mm"

        let dateString  = dfDate.string(from: selectedDate)
        let startString = dfTime.string(from: startTime)
        let endString   = dfTime.string(from: endTime)

        guard endTime > startTime else {
            errorMessage = "La hora de inicio debe ser anterior a la de fin."
            return
        }
        guard let subject = selectedSubject, !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Selecciona una materia."
            return
        }

        isSaving = true
        errorMessage = nil

        availabilityViewModel.publishAvailability(
            professorId: professorId,
            professorName: professorName,
            date: dateString,
            startTime: startString,
            endTime: endString,
            subject: subject                   // NEW
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

struct NewAvailabilityView_Previews: PreviewProvider {
    static var previews: some View {
        NewAvailabilityView()
            .environmentObject(AuthViewModel())
    }
}
