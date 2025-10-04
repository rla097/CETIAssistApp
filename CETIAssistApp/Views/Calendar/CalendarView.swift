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

                // Recargar manualmente
                Button {
                    calendarViewModel.fetchAvailability(
                        for: authViewModel.userRole,
                        alsoDeletePast: true   // o false si no quieres borrar desde cliente
                    )
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Recargar asesorías")
            }

            if calendarViewModel.isLoading {
                HStack {
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
                // 👇 OJO: sin '$' y usando 'availabilities' (no 'availabilityList')
                List(calendarViewModel.availabilities, id: \.id) { item in
                    AvailabilityRow(item: item)
                }
                .listStyle(.insetGrouped)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Celda/Row de ejemplo (ajústala a tu diseño)
private struct AvailabilityRow: View {
    let item: Availability

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Asumo que tu Availability tiene estas propiedades:
            // professorName (String), date (String "yyyy-MM-dd"), startTime (String ISO), endTime (String ISO), isAvailable (Bool)
            Text(item.professorName)
                .font(.headline)

            Text("\(item.date) • \(hora(from: item.startTime)) – \(hora(from: item.endTime))")
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

    // Extrae solo la hora de un ISO, p. ej. "10:30"
    private func hora(from isoString: String) -> String {
        // Intenta parsear ISO8601 → Date
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: isoString) {
            let f = DateFormatter()
            f.locale = Locale.current
            f.timeStyle = .short
            f.dateStyle = .none
            return f.string(from: date)
        }
        // Si falla el parseo, regresa el string crudo
        return isoString
    }
}
