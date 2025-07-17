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

    var body: some View {
        NavigationView {
            VStack {
                Text("Bienvenido, Alumno")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // Calendario de asesorías
                CalendarView()
                    .environmentObject(authViewModel)
                    .environmentObject(calendarViewModel)

                Spacer()

                Button(action: {
                    authViewModel.signOut()
                }) {
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
                calendarViewModel.fetchAvailability(for: authViewModel.userRole)
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
