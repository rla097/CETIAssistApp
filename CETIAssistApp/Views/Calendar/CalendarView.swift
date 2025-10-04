//
//  CalendarView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var calendarViewModel: CalendarViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Asesorías disponibles")
                    .font(.title3.weight(.semibold))
                Spacer()
                Button {
                    // Reinicia la suscripción (seguro: startListening ya hace stopListening internamente)
                    calendarViewModel.startListening(alsoDeletePast: true) // o false si no quieres borrar pasadas desde cliente
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Recargar asesorías")
            }

            if calendarViewModel.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Cargando asesorías…")
                }
                .padding(.vertical, 8)
            } else if let error = calendarViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.callout)
            } else if calendarViewModel.availabilities.isEmpty {
                Text("No hay asesorías disponibles desde hoy.")
                    .foregroundColor(.secondary)
                    .font(.callout)
            } else {
                List(calendarViewModel.availabilities, id: \.id) { item in
                    AvailabilityRow(item: item)
                }
                .listStyle(.insetGrouped)
                // Pull to refresh (opcional):
                .refreshable {
                    calendarViewModel.startListening(alsoDeletePast: true)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Celda de lista
private struct AvailabilityRow: View {
    let item: Availability

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Ajustado a tu struct Availability
            Text(item.professorName)
                .font(.headline)

            Text("\(item.date) • \(item.startTime) – \(item.endTime)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if !item.isAvailable {
                Text("No disponible")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}
