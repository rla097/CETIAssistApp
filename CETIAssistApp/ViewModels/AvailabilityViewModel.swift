//
//  AvailabilityViewModel.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import Foundation
import FirebaseFirestore

class AvailabilityViewModel: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var availabilities: [Availability] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Carga todas las disponibilidades de Firestore (puedes filtrar por profesor si quieres)
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
                    self?.errorMessage = "Error cargando disponibilidades: \(error.localizedDescription)"
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

    // Agregar nueva disponibilidad para profesor
    func addAvailability(_ availability: Availability, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        let newAvailabilityData: [String: Any] = [
            "professorId": availability.professorId,
            "professorName": availability.professorName ?? "",
            "date": availability.date,
            "startTime": availability.startTime,
            "endTime": availability.endTime,
            "isBooked": availability.isBooked,
            "studentId": availability.studentId as Any
        ]
        
        db.collection("availabilities").addDocument(data: newAvailabilityData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Error al agregar disponibilidad: \(error.localizedDescription)"
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }

    // Eliminar una disponibilidad
    func deleteAvailability(_ availabilityId: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        db.collection("availabilities").document(availabilityId).delete { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Error al eliminar disponibilidad: \(error.localizedDescription)"
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
