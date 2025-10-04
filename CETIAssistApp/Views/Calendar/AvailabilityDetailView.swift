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
        VStack(alignment: .leading, spacing: 16) {
            // Profesor
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 42))
                    .foregroundColor(.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text(availability.professorName)
                        .font(.title3).bold()
                    Text("Asesoría individual")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            // NEW: Materia
            VStack(alignment: .leading, spacing: 4) {
                Text("Materia")
                    .font(.headline)
                Text(availability.subject)
                    .font(.body)
            }

            // Fecha y hora
            VStack(alignment: .leading, spacing: 4) {
                Text("Fecha y hora")
                    .font(.headline)
                Text("\(availability.date) • \(availability.startTime) – \(availability.endTime)")
                    .font(.body)
            }

            if let error = reservationViewModel.errorMessage, !error.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(error).font(.footnote)
                }
                .foregroundColor(.red)
                .padding(.top, 4)
            }

            Spacer()

            // Botón reservar
            Button {
                reserve()
            } label: {
                HStack {
                    if reservationViewModel.isReserving { ProgressView().tint(.white) }
                    Text("Reservar asesoría").bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(reservationViewModel.isReserving)
        }
        .padding()
        .navigationTitle("Detalle de asesoría")
        .navigationBarTitleDisplayMode(.inline)
        .alert("¡Listo!", isPresented: $showSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Tu asesoría ha sido reservada correctamente.")
        }
    }

    // MARK: - Reservar
    private func reserve() {
        guard let studentId = authViewModel.user?.uid else {
            reservationViewModel.errorMessage = "No se pudo obtener el usuario actual."
            return
        }

        reservationViewModel.reserveAvailability(
            availabilityId: availability.id,
            studentId: studentId
        ) { success, _ in
            if success {
                showSuccessAlert = true
            }
        }
    }
}

struct AvailabilityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AvailabilityDetailView(
                availability: Availability(
                    id: "demo",
                    professorId: "prof1",
                    professorName: "Dra. García",
                    date: "2025-10-04",
                    startTime: "10:00",
                    endTime: "11:00",
                    isAvailable: true,
                    subject: "Cálculo diferencial"
                )
            )
            .environmentObject(AuthViewModel())
        }
    }
}
