//
//  ReservationViewModel.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation
import FirebaseFirestore

class ReservationViewModel: ObservableObject {
    private let db = FirebaseManager.shared.firestore

    @Published var isReserving = false
    @Published var errorMessage: String?

    func reserveAvailability(
        availabilityId: String,
        studentId: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        isReserving = true
        errorMessage = nil

        let reservationData: [String: Any] = [
            "availabilityId": availabilityId,
            "studentId": studentId,
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("reservations").addDocument(data: reservationData) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isReserving = false
                    self.errorMessage = error.localizedDescription
                    completion(false, error)
                }
                return
            }

            // Actualizar estado de la disponibilidad
            self.db.collection("availability").document(availabilityId).updateData([
                "isAvailable": false
            ]) { updateError in
                DispatchQueue.main.async {
                    self.isReserving = false
                    if let updateError = updateError {
                        self.errorMessage = updateError.localizedDescription
                        completion(false, updateError)
                    } else {
                        completion(true, nil)
                    }
                }
            }
        }
    }
}
