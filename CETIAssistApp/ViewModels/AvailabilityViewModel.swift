//
//  AvailabilityViewModel.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation
import FirebaseFirestore

class AvailabilityViewModel: ObservableObject {
    private let db = FirebaseManager.shared.firestore

    @Published var isPublishing = false
    @Published var errorMessage: String?

    func publishAvailability(
        professorId: String,
        professorName: String,
        date: String,
        startTime: String,
        endTime: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        isPublishing = true
        errorMessage = nil

        let data: [String: Any] = [
            "professorId": professorId,
            "professorName": professorName,
            "date": date,
            "startTime": startTime,
            "endTime": endTime,
            "isAvailable": true,
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("availability").addDocument(data: data) { error in
            DispatchQueue.main.async {
                self.isPublishing = false

                if let error = error {
                    self.errorMessage = "Error al publicar: \(error.localizedDescription)"
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        }
    }
}
