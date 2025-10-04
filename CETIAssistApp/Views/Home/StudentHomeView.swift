//
//  StudentHomeView.swift
//  CETIAssistApp
//
//  Created by Rolando Ernel Loza Aréchiga on 12/07/25.
//

import SwiftUI

struct StudentHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var calendarViewModel = CalendarViewModel()

    // Cambia a false si NO quieres que el cliente intente borrar asesorías pasadas.
    private let alsoDeletePast = true

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Bienvenido, Alumno")
                    .font(.largeTitle.bold())
                    .padding(.top)

                // Indicadores simples de carga / error
                if calendarViewModel.isLoading {
                    ProgressView("Cargando asesorías...")
                        .padding(.vertical)
                } else if let error = calendarViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Tu calendario/listado
                CalendarView()
                    .environmentObject(authViewModel)
                    .environmentObject(calendarViewModel)

                Spacer()

                Button {
                    authViewModel.signOut()
                } label: {
                    Text("Cerrar sesión")
                        .foregroundColor(.red)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Inicio Alumno")
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

struct StudentHomeView_Previews: PreviewProvider {
    static var previews: some View {
        StudentHomeView()
            .environmentObject(AuthViewModel())
    }
}
