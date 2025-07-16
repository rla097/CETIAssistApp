//
//  CalendarViewModel.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation
import FirebaseFirestore

class CalendarViewModel: ObservableObject {
    private let db = Firestore.firestore()

    @Published var availabilities: [Availability] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Cargar todas las disponibilidades o las filtradas por profesor (opcional)
    func fetchAvailabilities(professorId: String? = nil) {
        isLoading = true
        errorMessage = nil

        var query: Query = db.collection("availabilities")

        if let professorId = professorId {
            query = query.whereField("professorId", isEqualTo: professorId)
        }

        query.getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Error al cargar disponibilidades: \(error.localizedDescription)"
                    self?.availabilities = []
                    return
                }

                guard let documents = snapshot?.documents else {
                    self?.availabilities = []
                    return
                }

                self?.availabilities = documents.compactMap { doc -> Availability? in
                    let data = doc.data()
                    guard
                        let professorId = data["professorId"] as? String,
                        let date = data["date"] as? String,
                        let startTime = data["startTime"] as? String,
                        let endTime = data["endTime"] as? String,
                        let isBooked = data["isBooked"] as? Bool
                    else {
                        return nil
                    }

                    return Availability(
                        id: doc.documentID,
                        professorId: professorId,
                        professorName: data["professorName"] as? String,
                        date: date,
                        startTime: startTime,
                        endTime: endTime,
                        isBooked: isBooked,
                        studentId: data["studentId"] as? String
                    )
                }
            }
        }
    }
}
