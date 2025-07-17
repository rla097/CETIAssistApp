//
//  ProfessorHomeView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct ProfessorHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var isPresentingNewAvailability = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Bienvenido, Profesor")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // Lista de asesorías propias
                if calendarViewModel.isLoading {
                    ProgressView("Cargando asesorías...")
                        .padding()
                } else if let error = calendarViewModel.errorMessage {
                    ErrorView(message: error) {
                        calendarViewModel.fetchAvailability(for: authViewModel.userRole)
                    }
                } else if calendarViewModel.availabilityList.isEmpty {
                    EmptyStateView(
                        title: "Sin asesorías publicadas",
                        message: "Publica tu disponibilidad para asesorar a los alumnos.",
                        iconName: "calendar.badge.plus"
                    )
                } else {
                    List(calendarViewModel.availabilityList) { availability in
                        NavigationLink(destination: AvailabilityDetailView(availability: availability)) {
                            VStack(alignment: .leading) {
                                Text("Fecha: \(availability.date)")
                                Text("Hora: \(availability.startTime) - \(availability.endTime)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Estado: \(availability.isAvailable ? "Disponible" : "Reservada")")
                                    .foregroundColor(availability.isAvailable ? .green : .gray)
                                    .font(.caption)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Spacer()

                HStack {
                    Button(action: {
                        isPresentingNewAvailability = true
                    }) {
                        Label("Nueva disponibilidad", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Inicio Profesor")
            .sheet(isPresented: $isPresentingNewAvailability) {
                NewAvailabilityView()
                    .environmentObject(authViewModel)
            }
            .onAppear {
                calendarViewModel.fetchAvailability(for: authViewModel.userRole)
            }
        }
    }
}

struct ProfessorHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ProfessorHomeView()
            .environmentObject(AuthViewModel())
    }
}
