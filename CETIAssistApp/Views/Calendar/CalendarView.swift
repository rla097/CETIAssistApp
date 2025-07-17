//
//  CalendarView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = CalendarViewModel()

    var body: some View {
        VStack {
            Text("Calendario de asesorías")
                .font(.title2)
                .bold()
                .padding(.top)

            if viewModel.isLoading {
                ProgressView("Cargando asesorías...")
                    .padding()
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error, retryAction: {
                    viewModel.fetchAvailability(for: authViewModel.userRole)
                })
            } else if viewModel.availabilityList.isEmpty {
                EmptyStateView(
                    title: "Sin asesorías disponibles",
                    message: "Actualmente no hay horarios publicados para asesorías.",
                    iconName: "calendar.badge.exclamationmark"
                )
            } else {
                List(viewModel.availabilityList) { availability in
                    NavigationLink(destination: AvailabilityDetailView(availability: availability)) {
                        VStack(alignment: .leading) {
                            Text("Fecha: \(availability.date)")
                            Text("Hora: \(availability.startTime) - \(availability.endTime)")
                            Text("Profesor: \(availability.professorName)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchAvailability(for: authViewModel.userRole)
        }
    }
}
