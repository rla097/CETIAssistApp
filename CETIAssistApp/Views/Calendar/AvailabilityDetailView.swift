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
    @StateObject private var reservationViewModel = ReservationViewModel()

    @Environment(\.dismiss) var dismiss
    @State private var showSuccessAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Asesoría con \(availability.professorName)")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 10) {
                Text("📅 Fecha: \(availability.date)")
                Text("🕒 Hora: \(availability.startTime) - \(availability.endTime)")
                Text("📌 Estado: \(availability.isAvailable ? "Disponible" : "Reservada")")
                    .foregroundColor(availability.isAvailable ? .green : .gray)
            }
            .padding()

            if let error = reservationViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            if availability.isAvailable {
                Button(action: reserve) {
                    if reservationViewModel.isReserving {
                        ProgressView()
                    } else {
                        Text("Reservar asesoría")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            } else {
                Text("Esta asesoría ya ha sido reservada.")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
        .navigationTitle("Detalle de Asesoría")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Éxito"),
                message: Text("Asesoría agendada exitosamente."),
                dismissButton: .default(Text("OK")) {
                    dismiss()
                }
            )
        }
    }

    private func reserve() {
        guard let studentId = authViewModel.user?.uid else {
            reservationViewModel.errorMessage = "No se pudo obtener el usuario actual."
            return
        }

        reservationViewModel.reserveAvailability(
            availabilityId: availability.id,
            studentId: studentId
        ) { success, error in
            if success {
                showSuccessAlert = true
            }
        }
    }
}
