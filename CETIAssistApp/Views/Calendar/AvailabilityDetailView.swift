//
//  AvailabilityDetailView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct AvailabilityDetailView: View {
    let availability: Availability
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var reservationViewModel = ReservationViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Profesor: \(availability.professorName ?? "Desconocido")")
                .font(.title2)
            
            Text("Fecha: \(availability.date)")
            Text("Hora: \(availability.startTime) - \(availability.endTime)")
            
            if availability.isBooked {
                Text("Esta asesoría ya está reservada")
                    .foregroundColor(.red)
            } else {
                if isLoading {
                    ProgressView()
                } else {
                    Button("Reservar asesoría") {
                        reservarAsesoria()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Detalles de asesoría")
    }

    private func reservarAsesoria() {
        guard let studentId = authViewModel.user?.uid else {
            errorMessage = "No se pudo obtener el ID del alumno."
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        reservationViewModel.reserve(availability: availability, studentId: studentId) { success in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    dismiss()
                } else {
                    errorMessage = reservationViewModel.errorMessage ?? "Error desconocido al reservar."
                }
            }
        }
    }
}
