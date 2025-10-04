//
//  Availability+Mapping.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 04/10/25.
//

import Foundation
import FirebaseFirestore

extension Availability {
    /// Construye Availability desde doc con `start`/`end` (Timestamp) + compatibilidad de strings.
    static func from(document: DocumentSnapshot) -> Availability? {
        let data = document.data() ?? [:]

        // Requiere `start: Timestamp`
        guard let startTS = data["start"] as? Timestamp,
              let endTS   = data["end"] as? Timestamp else {
            return nil
        }

        let startDate = startTS.dateValue()
        let endDate   = endTS.dateValue()

        let dfDate  = DateFormatter()
        dfDate.locale = .current
        dfDate.timeZone = .current
        dfDate.dateFormat = "yyyy-MM-dd"

        let dfTime  = DateFormatter()
        dfTime.locale = .current
        dfTime.timeZone = .current
        dfTime.dateFormat = "HH:mm"

        // Prioriza campos string si existen (compat)
        let dateStr  = (data["date"] as? String) ?? dfDate.string(from: startDate)
        let startStr = (data["startTime"] as? String) ?? dfTime.string(from: startDate)
        let endStr   = (data["endTime"] as? String) ?? dfTime.string(from: endDate)

        let professorId   = (data["professorId"] as? String) ?? ""
        let professorName = (data["professorName"] as? String) ?? "Profesor"
        let isAvailable   = (data["isAvailable"] as? Bool) ?? true
        let subject       = (data["subject"] as? String) ?? "Sin materia" // NEW

        return Availability(
            id: document.documentID,
            professorId: professorId,
            professorName: professorName,
            date: dateStr,          // "yyyy-MM-dd"
            startTime: startStr,    // "HH:mm"
            endTime: endStr,        // "HH:mm"
            isAvailable: isAvailable,
            subject: subject        // NEW
        )
    }
}
