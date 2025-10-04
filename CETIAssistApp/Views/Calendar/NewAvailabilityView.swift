//
//  NewAvailabilityView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI
import FirebaseAuth

struct NewAvailabilityView: View {
    // Ya no dependemos de AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var availabilityVM = AvailabilityViewModel()

    // Materias (si pasas lista, Picker; si no, TextField)
    let availableSubjects: [String]
    @State private var selectedSubjectIndex: Int = 0
    @State private var subjectText: String = ""

    // Fecha y horas
    @State private var selectedDate: Date = Date()
    @State private var startTime: Date = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var endTime: Date = Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date()) ?? Date()

    // Modalidad / Aula
    @State private var modality: Modality = .virtual
    @State private var aula: String = ""

    // UI state
    @State private var isSaving: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    init(availableSubjects: [String] = []) {
        self.availableSubjects = availableSubjects
    }

    var body: some View {
        NavigationView {
            Form {
                // Materia
                Section("Materia") {
                    if availableSubjects.isEmpty {
                        TextField("Nombre de la materia", text: $subjectText)
                            .textInputAutocapitalization(.words)
                    } else {
                        Picker("Selecciona materia", selection: $selectedSubjectIndex) {
                            ForEach(availableSubjects.indices, id: \.self) { idx in
                                Text(availableSubjects[idx]).tag(idx)
                            }
                        }
                    }
                }

                // Fecha y horario
                Section("Fecha y horario") {
                    DatePicker("Fecha", selection: $selectedDate, displayedComponents: .date)
                    DatePicker("Inicio", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("Fin", selection: $endTime, displayedComponents: .hourAndMinute)
                }

                // Modalidad
                Section("Modalidad") {
                    Picker("Modalidad", selection: $modality) {
                        Text("Virtual").tag(Modality.virtual)
                        Text("Presencial").tag(Modality.presencial)
                    }
                    .pickerStyle(.segmented)

                    if modality == .presencial {
                        TextField("Aula", text: $aula)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(false)
                    }
                }

                // Error del VM (si existe)
                if let vmError = availabilityVM.errorMessage, !vmError.isEmpty {
                    Section {
                        Text(vmError)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Nueva asesoría")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: publish) {
                        if isSaving { ProgressView() } else { Text("Publicar") }
                    }
                    .disabled(isSaving)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") { if alertTitle == "Listo" { dismiss() } }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        var cal = Calendar(identifier: .gregorian)
        let tz = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        cal.timeZone = tz
        let c = cal.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 1970, c.month ?? 1, c.day ?? 1)
    }

    private func formatTime(_ date: Date) -> String {
        var cal = Calendar(identifier: .gregorian)
        let tz = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        cal.timeZone = tz
        let c = cal.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", c.hour ?? 0, c.minute ?? 0)
    }

    // MARK: - Publicar
    private func publish() {
        // ✅ Tomamos el usuario directo de FirebaseAuth
        guard let user = Auth.auth().currentUser else {
            show("Error", "No hay sesión iniciada.")
            return
        }
        let uid = user.uid
        let profName = user.displayName ?? "Profesor"

        let subjectChosen: String = availableSubjects.isEmpty
        ? subjectText.trimmingCharacters(in: .whitespacesAndNewlines)
        : availableSubjects[selectedSubjectIndex]

        if subjectChosen.isEmpty {
            show("Falta información", "Selecciona o escribe una materia.")
            return
        }
        if modality == .presencial && aula.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            show("Falta el aula", "Ingresa el aula para asesorías presenciales.")
            return
        }

        // Protege fin > inicio
        var start = startTime
        var end = endTime
        if end <= start, let plusHour = Calendar.current.date(byAdding: .hour, value: 1, to: start) {
            end = plusHour
        }

        let dateStr = formatDate(selectedDate)
        let startStr = formatTime(start)
        let endStr = formatTime(end)

        isSaving = true
        availabilityVM.publishAvailability(
            professorId: uid,
            professorName: profName,
            date: dateStr,
            startTime: startStr,
            endTime: endStr,
            subject: subjectChosen,
            modality: modality,
            aula: modality == .presencial ? aula : nil
        ) { ok, error in
            isSaving = false
            if let error = error {
                show("Error", error.localizedDescription)
            } else if ok {
                show("Listo", "La asesoría se publicó correctamente.")
            } else {
                show("Error", "No se pudo publicar la asesoría.")
            }
        }
    }

    private func show(_ title: String, _ message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}
