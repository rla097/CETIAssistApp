//
//  AvailabilityViewModel.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation
import Combine
import FirebaseFirestore

final class AvailabilityViewModel: ObservableObject {

    @Published var items: [Availability] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private let collectionName = "asesorias"
    private var listener: ListenerRegistration?

    deinit { stopListening() }

    func startListening(professorId: String? = nil) {
        stopListening()
        isLoading = true
        errorMessage = nil

        var query: Query = db.collection(collectionName)

        // No filtramos por start/isAvailable aquí; lo hacemos en memoria.
        if let pid = professorId, !pid.isEmpty {
            query = query.whereField("professorId", isEqualTo: pid)
        }
        query = query.order(by: "start", descending: false)

        listener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                self.errorMessage = error.localizedDescription
                self.items = []
                return
            }

            let docs = snapshot?.documents ?? []
            let mapped = docs.compactMap { Availability.from(document: $0) }

            // Filtro en memoria: FUTURO + SOLO DISPONIBLES
            let now = Date()

            func parseStart(_ a: Availability) -> Date? {
                var comps = DateComponents()
                let d = a.date.split(separator: "-").compactMap { Int($0) }
                let t = a.startTime.split(separator: ":").compactMap { Int($0) }
                guard d.count == 3, t.count >= 2 else { return nil }
                comps.year = d[0]; comps.month = d[1]; comps.day = d[2]
                comps.hour = t[0]; comps.minute = t[1]; comps.second = 0
                return Calendar(identifier: .gregorian).date(from: comps)
            }

            let future = mapped.filter { a in
                guard let sd = parseStart(a) else { return false }
                return sd >= now
            }

            let onlyAvailable = future.filter { $0.isAvailable }
            self.items = onlyAvailable
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // publicar (se asegura que isAvailable sea true)
    func publishAvailability(
        professorId: String,
        professorName: String,
        date: String,
        startTime: String,
        endTime: String,
        subject: String,
        modality: Modality,
        aula: String?,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        // validaciones básicas
        guard !professorId.isEmpty else {
            completion(false, NSError(domain: "Availability", code: -1, userInfo: [NSLocalizedDescriptionKey: "Falta professorId"]))
            return
        }
        guard !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(false, NSError(domain: "Availability", code: -2, userInfo: [NSLocalizedDescriptionKey: "Selecciona una materia"]))
            return
        }
        if modality == .presencial {
            let aulaVal = (aula ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !aulaVal.isEmpty else {
                completion(false, NSError(domain: "Availability", code: -3, userInfo: [NSLocalizedDescriptionKey: "Ingresa el aula para asesorías presenciales"]))
                return
            }
        }

        func combine(_ d: String, _ t: String) -> Date? {
            var comps = DateComponents()
            let dparts = d.split(separator: "-").compactMap { Int($0) }
            let tparts = t.split(separator: ":").compactMap { Int($0) }
            guard dparts.count == 3, tparts.count >= 2 else { return nil }
            comps.year = dparts[0]; comps.month = dparts[1]; comps.day = dparts[2]
            comps.hour = tparts[0]; comps.minute = tparts[1]; comps.second = 0
            return Calendar(identifier: .gregorian).date(from: comps)
        }

        guard let startDate = combine(date, startTime),
              let endDate = combine(date, endTime),
              endDate > startDate else {
            completion(false, NSError(domain: "Availability", code: -4, userInfo: [NSLocalizedDescriptionKey: "El horario de fin debe ser posterior al de inicio"]))
            return
        }

        let startTS = Timestamp(date: startDate)
        let endTS   = Timestamp(date: endDate)
        let duration = Int(endDate.timeIntervalSince(startDate) / 60.0)

        var doc: [String: Any] = [
            "professorId": professorId,
            "professorName": professorName,
            "start": startTS,
            "end": endTS,
            "date": date,
            "startTime": startTime,
            "endTime": endTime,
            "isAvailable": true,                // 🔵 aseguramos disponible al crear
            "subject": subject,
            "subjectLower": subject.lowercased(),
            "modality": modality.rawValue,
            "duration": duration
        ]

        if modality == .presencial {
            doc["aula"] = (aula ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            doc["aula"] = FieldValue.delete()
        }

        db.collection(collectionName).addDocument(data: doc) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    // (si tienes flujo de reserva, recuerda setear isAvailable=false y opcionalmente studentId)
    func markAsBooked(id: String, studentId: String, completion: @escaping (Bool, Error?) -> Void) {
        let patch: [String: Any] = [
            "isAvailable": false,
            "studentId": studentId
        ]
        db.collection(collectionName).document(id).setData(patch, merge: true) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
}
