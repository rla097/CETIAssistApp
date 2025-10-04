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

    /// Publica disponibilidad guardando `start` y `end` como Timestamp + strings de compatibilidad
    func publishAvailability(
        professorId: String,
        professorName: String,
        date: String,        // "yyyy-MM-dd"
        startTime: String,   // "HH:mm"
        endTime: String,     // "HH:mm"
        completion: @escaping (Bool, Error?) -> Void
    ) {
        // Combinar `date` + `startTime` / `endTime` a Date
        let day = DateFormatter()
        day.calendar = Calendar(identifier: .gregorian)
        day.locale   = Locale(identifier: "en_US_POSIX")
        day.timeZone = TimeZone(secondsFromGMT: 0) // día en UTC para que la fecha sea estable
        day.dateFormat = "yyyy-MM-dd"

        let hm = DateFormatter()
        hm.calendar = Calendar(identifier: .gregorian)
        hm.locale   = Locale(identifier: "en_US_POSIX")
        hm.timeZone = TimeZone.current             // hora local del profesor
        hm.dateFormat = "HH:mm"

        guard let baseDay = day.date(from: date),
              let sHM = hm.date(from: startTime),
              let eHM = hm.date(from: endTime) else {
            completion(false, NSError(domain: "format", code: 0, userInfo: [NSLocalizedDescriptionKey: "Fecha u hora inválida"]))
            return
        }

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current

        // Mezcla día (UTC) + horas (local) → fechas locales correctas
        var sComp = cal.dateComponents([.year, .month, .day], from: baseDay)
        let tComp = cal.dateComponents([.hour, .minute], from: sHM)
        sComp.hour = tComp.hour
        sComp.minute = tComp.minute
        guard let start = cal.date(from: sComp) else {
            completion(false, NSError(domain: "compose", code: 0, userInfo: [NSLocalizedDescriptionKey: "No se pudo construir fecha de inicio"]))
            return
        }

        var eComp = cal.dateComponents([.year, .month, .day], from: baseDay)
        let teComp = cal.dateComponents([.hour, .minute], from: eHM)
        eComp.hour = teComp.hour
        eComp.minute = teComp.minute
        let end = cal.date(from: eComp) ?? start

        // También guarda duración por si te sirve (minutos)
        let duration = Int(end.timeIntervalSince(start) / 60)

        let doc: [String: Any] = [
            // Campos canónicos (consulta SIEMPRE por aquí)
            "start": Timestamp(date: start),
            "end":   Timestamp(date: end),

            // Compatibilidad con tu UI actual
            "date": date,                // "yyyy-MM-dd"
            "startTime": startTime,      // "HH:mm"
            "endTime": endTime,          // "HH:mm"

            // Profesor
            "professorId": professorId,
            "professorName": professorName,

            // Estado
            "isAvailable": true,

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
