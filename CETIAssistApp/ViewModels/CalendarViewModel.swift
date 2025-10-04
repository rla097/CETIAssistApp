//
//  CalendarViewModel.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation
import FirebaseFirestore

@MainActor
final class CalendarViewModel: ObservableObject {

    @Published var availabilities: [Availability] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    /// Lista asesorías desde hoy 00:00 usando `start` (Timestamp).
    /// Si `alsoDeletePast` es true, borra pasadas (start < hoy).
    func fetchAvailability(for role: UserRole?, alsoDeletePast: Bool = false) {
        isLoading = true
        errorMessage = nil

        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayTS = Timestamp(date: todayStart)

        db.collection("asesorias")
            .whereField("start", isGreaterThanOrEqualTo: todayTS)  // clave canónica
            .order(by: "start", descending: false)
            .getDocuments(source: .server) { [weak self] snapshot, err in
                guard let self = self else { return }

                if let err = err {
                    self.errorMessage = err.localizedDescription
                    self.isLoading = false
                    return
                }

                guard let docs = snapshot?.documents else {
                    self.isLoading = false
                    return
                }

                var list: [Availability] = []
                for doc in docs {
                    if let a = Availability.from(document: doc) {
                        list.append(a)
                    }
                }

                // Orden estable por (date, startTime) — ambos Strings
                self.availabilities = list.sorted {
                    if $0.date == $1.date { return $0.startTime < $1.startTime }
                    return $0.date < $1.date
                }

                if alsoDeletePast {
                    self.deletePastAvailabilities(before: todayTS) {
                        self.isLoading = false
                    }
                } else {
                    self.isLoading = false
                }
            }
    }

    private func deletePastAvailabilities(before cutoff: Timestamp, completion: @escaping () -> Void) {
        db.collection("asesorias")
            .whereField("start", isLessThan: cutoff) // borra por start (Timestamp)
            .limit(to: 500)
            .getDocuments(source: .server) { [weak self] snapshot, err in
                guard let self = self else { return }

                if let err = err {
                    print("Error listando pasadas: \(err.localizedDescription)")
                    completion()
                    return
                }

                let docs = snapshot?.documents ?? []
                if docs.isEmpty {
                    completion()
                    return
                }

                let batch = self.db.batch()
                docs.forEach { batch.deleteDocument($0.reference) }

                batch.commit { batchErr in
                    if let batchErr = batchErr {
                        print("Error al borrar pasadas: \(batchErr.localizedDescription)")
                        completion()
                        return
                    }
                    // Repite si hay más de 500
                    self.deletePastAvailabilities(before: cutoff, completion: completion)
                }
            }
    }
}
