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
            // Encabezado
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Asesorías disponibles")
                        .font(.title2).bold()
                    if let error = calendarViewModel.errorMessage, !error.isEmpty {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
                Spacer()
                Button {
                    calendarViewModel.startListening(alsoDeletePast: true)
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .imageScale(.large)
                        .padding(8)
                }
                .accessibilityLabel("Actualizar")
            }
            .padding(.horizontal)

            // Contenido
            Group {
                if calendarViewModel.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Cargando asesorías…")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                } else if calendarViewModel.availabilities.isEmpty {
                    EmptyStateView(
                        title: "No hay asesorías por ahora",
                        message: "Vuelve a intentar más tarde o actualiza."
                    )
                    .padding(.horizontal)
                } else {
                    List(calendarViewModel.availabilities) { item in
                        AvailabilityRow(item: item)
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        calendarViewModel.startListening(alsoDeletePast: true)
                    }
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
            // Profesor
            Text(item.professorName)
                .font(.headline)

            // NEW: Materia
            Text(item.subject)
                .font(.subheadline)
                .bold()

            // Fecha y horario
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
