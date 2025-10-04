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
    private var listener: ListenerRegistration?

    // Inicia una suscripción en tiempo real
    func startListening(alsoDeletePast: Bool = false) {
        stopListening() // evita duplicados

        isLoading = true
        errorMessage = nil

        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayTS = Timestamp(date: todayStart)

        let query = db.collection("asesorias")
            .whereField("start", isGreaterThanOrEqualTo: todayTS)
            .order(by: "start", descending: false)

        listener = query.addSnapshotListener { [weak self] snapshot, err in
            guard let self = self else { return }

            if let err = err {
                self.errorMessage = err.localizedDescription
                self.isLoading = false
                return
            }

            let docs = snapshot?.documents ?? []
            var list: [Availability] = []
            for doc in docs {
                if let a = Availability.from(document: doc) {
                    list.append(a)
                }
            }

            self.availabilities = list.sorted {
                if $0.date == $1.date { return $0.startTime < $1.startTime }
                return $0.date < $1.date
            }

            self.isLoading = false

            // (Opcional) limpieza de pasadas periódica (no dentro del listener para no encadenar commits)
            if alsoDeletePast {
                self.cleanupPast(before: todayTS)
            }
        }
    }

    // Detiene la suscripción (llamar en onDisappear si lo deseas)
    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // Limpieza opcional (no bloquea la UI)
    private func cleanupPast(before cutoff: Timestamp) {
        db.collection("asesorias")
            .whereField("start", isLessThan: cutoff)
            .limit(to: 500)
            .getDocuments(source: .server) { [weak self] snapshot, err in
                guard let self = self else { return }
                if let err = err {
                    print("Error listando pasadas: \(err.localizedDescription)")
                    return
                }
                let docs = snapshot?.documents ?? []
                if docs.isEmpty { return }

                let batch = self.db.batch()
                docs.forEach { batch.deleteDocument($0.reference) }
                batch.commit { batchErr in
                    if let batchErr = batchErr {
                        print("Error al borrar pasadas: \(batchErr.localizedDescription)")
                        return
                    }
                    // si quedan más de 500 se puede reintentar, pero no es crítico para la UI en vivo
                }
            }
    }
}
