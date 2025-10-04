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

    // Cambia a false si NO quieres que el cliente intente borrar asesorías pasadas.
    private let alsoDeletePast = true

    var body: some View {
        NavigationView {
            VStack {
                Text("Bienvenido, Profesor")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // Lista de asesorías propias (en vivo)
                if calendarViewModel.isLoading {
                    ProgressView("Cargando asesorías...")
                        .padding()
                } else if let error = calendarViewModel.errorMessage {
                    ErrorView(message: error) {
                        // Extra: acción de reintento manual (no necesaria con listener, pero útil)
                        calendarViewModel.startListening(alsoDeletePast: alsoDeletePast)
                    }
                } else if calendarViewModel.availabilities.isEmpty {
                    EmptyStateView(
                        title: "Sin asesorías publicadas",
                        message: "Publica tu disponibilidad para asesorar a los alumnos.",
                        iconName: "calendar.badge.plus"
                    )
                } else {
                    List(calendarViewModel.availabilities, id: \.id) { availability in
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
                    .listStyle(.insetGrouped)
                }

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        isPresentingNewAvailability = true
                    } label: {
                        Label("Nueva disponibilidad", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button {
                        authViewModel.signOut()
                    } label: {
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
                // 🔴 Suscripción en tiempo real
                calendarViewModel.startListening(alsoDeletePast: alsoDeletePast)
            }
            .onDisappear {
                // 🟢 Liberar listener para evitar fugas
                calendarViewModel.stopListening()
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
