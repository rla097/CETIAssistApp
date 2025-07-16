//
//  ReservationViewModel.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation
import FirebaseFirestore

class ReservationViewModel: ObservableObject {
    private let db = Firestore.firestore()

    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Reserva una disponibilidad para el alumno actual
    func reserve(availability: Availability, studentId: String, completion: @escaping (Bool) -> Void) {
        guard !availability.isBooked else {
            self.errorMessage = "Esta asesoría ya está reservada."
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Referencia al documento de la disponibilidad en Firestore
        let availabilityRef = db.collection("availabilities").document(availability.id)
        
        // Actualizar la disponibilidad: marcar como reservada y asignar studentId
        availabilityRef.updateData([
            "isBooked": true,
            "studentId": studentId
        ]) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Error al reservar: \(error.localizedDescription)"
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    // Opcional: cancelar una reserva
    func cancelReservation(availability: Availability, completion: @escaping (Bool) -> Void) {
        guard availability.isBooked else {
            self.errorMessage = "Esta asesoría no está reservada."
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let availabilityRef = db.collection("availabilities").document(availability.id)
        
        availabilityRef.updateData([
            "isBooked": false,
            "studentId": NSNull()  // Elimina el campo studentId
        ]) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Error al cancelar la reserva: \(error.localizedDescription)"
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
