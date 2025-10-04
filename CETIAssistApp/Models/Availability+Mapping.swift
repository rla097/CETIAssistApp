//
//  Availability+Mapping.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 04/10/25.
//

import Foundation
import FirebaseFirestore

extension Availability {
    /// Construye Availability desde doc con `start`/`end` (Timestamp) + compat.
    static func from(document: DocumentSnapshot) -> Availability? {
        let data = document.data() ?? [:]

        // Requiere `start: Timestamp`
        guard let startTS = data["start"] as? Timestamp else { return nil }
        let start = startTS.dateValue()

        // `end` si existe; si no, calcula con `duration` en minutos, si está
        let end: Date = {
            if let endTS = data["end"] as? Timestamp { return endTS.dateValue() }
            if let dur = (data["duration"] as? Int) ?? (data["duracion"] as? Int) {
                return Calendar.current.date(byAdding: .minute, value: dur, to: start) ?? start
            }
            return start
        }()

        // Formateadores para tu `Availability` (strings)
        let day = DateFormatter()
        day.calendar = Calendar(identifier: .gregorian)
        day.locale   = Locale(identifier: "en_US_POSIX")
        day.timeZone = TimeZone(secondsFromGMT: 0)
        day.dateFormat = "yyyy-MM-dd"

        let hm = DateFormatter()
        hm.calendar = Calendar(identifier: .gregorian)
        hm.locale   = Locale(identifier: "en_US_POSIX")
        hm.timeZone = TimeZone.current
        hm.dateFormat = "HH:mm"

        let dateStr  = day.string(from: start)
        let startStr = hm.string(from: start)
        let endStr   = hm.string(from: end)

        let professorId   = (data["professorId"] as? String) ?? (data["profesorId"] as? String) ?? ""
        let professorName = (data["professorName"] as? String)
                          ?? (data["profesorNombre"] as? String)
                          ?? (data["asesor"] as? String)
                          ?? "Profesor"
        let isAvailable   = (data["isAvailable"] as? Bool) ?? true

        return Availability(
            id: document.documentID,
            professorId: professorId,
            professorName: professorName,
            date: dateStr,          // "yyyy-MM-dd"
            startTime: startStr,    // "HH:mm"
            endTime: endStr,        // "HH:mm"
            isAvailable: isAvailable
        )
    }
}
