//
//  CalendarViewModel.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation
import FirebaseFirestore

class CalendarViewModel: ObservableObject {
    @Published var availabilityList: [Availability] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let db = FirebaseManager.shared.firestore

    func fetchAvailability(for role: UserRole?) {
        isLoading = true
        errorMessage = nil

        db.collection("availability")
            .order(by: "date", descending: false)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    self.isLoading = false

                    if let error = error {
                        self.errorMessage = "Error al cargar asesorías: \(error.localizedDescription)"
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        self.errorMessage = "No se encontraron documentos."
                        return
                    }

                    var tempList: [Availability] = []

                    for doc in documents {
                        let data = doc.data()
                        guard
                            let professorId = data["professorId"] as? String,
                            let professorName = data["professorName"] as? String,
                            let date = data["date"] as? String,
                            let startTime = data["startTime"] as? String,
                            let endTime = data["endTime"] as? String,
                            let isAvailable = data["isAvailable"] as? Bool
                        else {
                            continue
                        }

                        // Mostrar solo las disponibles a los alumnos
                        if role == .alumno && !isAvailable {
                            continue
                        }

                        let availability = Availability(
                            id: doc.documentID,
                            professorId: professorId,
                            professorName: professorName,
                            date: date,
                            startTime: startTime,
                            endTime: endTime,
                            isAvailable: isAvailable
                        )

                        tempList.append(availability)
                    }

                    self.availabilityList = tempList
                }
            }
    }
}
