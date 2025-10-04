//
//  AvailabilityViewModel.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation
import FirebaseFirestore

final class AvailabilityViewModel: ObservableObject {
    private let db = Firestore.firestore()

    /// Publica disponibilidad guardando `start` y `end` como Timestamp + strings de compatibilidad.
    /// Ahora requiere `subject` (materia) obligatoria.
    func publishAvailability(
        professorId: String,
        professorName: String,
        date: String,        // "yyyy-MM-dd"
        startTime: String,   // "HH:mm"
        endTime: String,     // "HH:mm"
        subject: String,     // NEW
        completion: @escaping (Bool, Error?) -> Void
    ) {
        // Validaciones mínimas
        guard !professorId.isEmpty else {
            completion(false, NSError(domain: "Availability", code: -1, userInfo: [NSLocalizedDescriptionKey: "Falta professorId"]))
            return
        }
        guard !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(false, NSError(domain: "Availability", code: -2, userInfo: [NSLocalizedDescriptionKey: "Selecciona una materia"]))
            return
        }

        // Construir fechas
        let dfDate = DateFormatter()
        dfDate.locale = .current
        dfDate.timeZone = .current
        dfDate.dateFormat = "yyyy-MM-dd"

        let dfTime = DateFormatter()
        dfTime.locale = .current
        dfTime.timeZone = .current
        dfTime.dateFormat = "HH:mm"

        guard let baseDate = dfDate.date(from: date),
              let startHour = dfTime.date(from: startTime),
              let endHour   = dfTime.date(from: endTime) else {
            completion(false, NSError(domain: "Availability", code: -3, userInfo: [NSLocalizedDescriptionKey: "Formato de fecha/hora inválido"]))
            return
        }

        // Combinar fecha + horas
        let cal = Calendar.current
        let start = cal.date(
            bySettingHour: cal.component(.hour, from: startHour),
            minute: cal.component(.minute, from: startHour),
            second: 0,
            of: baseDate
        ) ?? baseDate

        let end = cal.date(
            bySettingHour: cal.component(.hour, from: endHour),
            minute: cal.component(.minute, from: endHour),
            second: 0,
            of: baseDate
        ) ?? baseDate.addingTimeInterval(3600)

        guard end > start else {
            completion(false, NSError(domain: "Availability", code: -4, userInfo: [NSLocalizedDescriptionKey: "La hora de fin debe ser posterior a la de inicio"]))
            return
        }

        let duration = Int(end.timeIntervalSince(start) / 60.0) // minutos

        let doc: [String: Any] = [
            "professorId": professorId,
            "professorName": professorName,
            "start": Timestamp(date: start),
            "end": Timestamp(date: end),

            // Compatibilidad con vistas existentes
            "date": date,
            "startTime": startTime,
            "endTime": endTime,

            "isAvailable": true,

            // NEW: materia
            "subject": subject,
            "subjectLower": subject.lowercased(),

            // Extra útil
            "duration": duration
        ]

        db.collection("asesorias").addDocument(data: doc) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
}
