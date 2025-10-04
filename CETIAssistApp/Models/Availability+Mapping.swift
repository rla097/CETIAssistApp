//
//  Availability+Mapping.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 04/10/25.
//

import Foundation
import FirebaseFirestore

private extension DateFormatter {
    static let ymd: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "es_MX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    static let hm: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "es_MX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "HH:mm"
        return f
    }()
}

extension Availability {
    /// Mapeo tolerante: acepta `subject` o `subjectName`, y convierte `isBooked` → `isAvailable`.
    static func from(document: DocumentSnapshot) -> Availability? {
        let data = document.data() ?? [:]

        // Identidad profesor
        let professorId   = (data["professorId"] as? String) ?? ""
        let professorName = (data["professorName"] as? String) ?? "Profesor"

        // Materia (acepta dos nombres)
        let subjectAny = (data["subject"] as? String) ?? (data["subjectName"] as? String)
        let subject    = (subjectAny?.isEmpty == false) ? subjectAny! : "Sin materia"

        // Disponibilidad: prioridad a isAvailable; si no existe, usa !isBooked; si ninguno, true
        let isAvailable: Bool = {
            if let v = data["isAvailable"] as? Bool { return v }
            if let booked = data["isBooked"] as? Bool { return !booked }
            return true
        }()

        // Hora/fecha
        var dateStr  = data["date"] as? String
        var startStr = data["startTime"] as? String
        var endStr   = data["endTime"] as? String

        if let startTS = data["start"] as? Timestamp,
           let endTS   = data["end"] as? Timestamp {
            let start = startTS.dateValue()
            let end   = endTS.dateValue()
            dateStr  = DateFormatter.ymd.string(from: start)
            startStr = DateFormatter.hm.string(from: start)
            endStr   = DateFormatter.hm.string(from: end)
        }

        // Necesitamos estos tres para renderizar
        guard let date = dateStr, let start = startStr, let end = endStr else {
            return nil
        }

        // Modalidad / aula (con defaults)
        let modalityRaw = (data["modality"] as? String) ?? "virtual"
        let modality    = Modality(rawValue: modalityRaw) ?? .virtual
        let aulaValue   = data["aula"] as? String
        let aula        = (modality == .presencial) ? aulaValue : nil

        return Availability(
            id: document.documentID,
            professorId: professorId,
            professorName: professorName,
            date: date,
            startTime: start,
            endTime: end,
            isAvailable: isAvailable,
            subject: subject,
            modality: modality,
            aula: aula
        )
    }
}
