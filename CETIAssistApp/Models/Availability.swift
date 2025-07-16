//
//  Availability.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation

struct Availability: Identifiable, Codable {
    var id: String                // ID del documento en Firestore
    var professorId: String       // ID del profesor que publicó la disponibilidad
    var professorName: String?    // Nombre del profesor (opcional)
    var date: String              // Fecha en formato "yyyy-MM-dd"
    var startTime: String         // Hora de inicio, ej. "14:00"
    var endTime: String           // Hora de fin, ej. "15:00"
    var isBooked: Bool            // Indica si la disponibilidad está reservada
    var studentId: String?        // ID del alumno que reservó (si aplica)
    
    // Inicializador personalizado para evitar errores de orden de argumentos
    init(id: String,
         professorId: String,
         professorName: String?,
         date: String,
         startTime: String,
         endTime: String,
         isBooked: Bool,
         studentId: String?) {
        self.id = id
        self.professorId = professorId
        self.professorName = professorName
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.isBooked = isBooked
        self.studentId = studentId
    }
    
    // Propiedades computadas para convertir a Date
    var startDateTime: Date? {
        return Availability.dateFrom(date: date, time: startTime)
    }

    var endDateTime: Date? {
        return Availability.dateFrom(date: date, time: endTime)
    }

    // Función auxiliar para convertir strings en Date
    static func dateFrom(date: String, time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: "\(date) \(time)")
    }
}
