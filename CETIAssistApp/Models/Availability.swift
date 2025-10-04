//
//  Availability.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation

enum Modality: String, Codable, CaseIterable, Identifiable {
    case virtual
    case presencial

    var id: String { rawValue }
    var displayName: String { self == .virtual ? "Virtual" : "Presencial" }
}

struct Availability: Identifiable {
    let id: String
    let professorId: String
    let professorName: String
    let date: String
    let startTime: String
    let endTime: String
    let isAvailable: Bool
    let subject: String

    // NUEVO
    let modality: Modality
    let aula: String?     // solo si modality == .presencial

    init(
        id: String,
        professorId: String,
        professorName: String,
        date: String,
        startTime: String,
        endTime: String,
        isAvailable: Bool,
        subject: String,
        modality: Modality = .virtual,
        aula: String? = nil
    ) {
        self.id = id
        self.professorId = professorId
        self.professorName = professorName
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.isAvailable = isAvailable
        self.subject = subject
        self.modality = modality
        self.aula = modality == .presencial ? (aula ?? "") : nil
    }
}
